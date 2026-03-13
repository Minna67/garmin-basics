import Toybox.Sensor;
import Toybox.FitContributor;
import Toybox.System;
import Toybox.Lang;

/**
 * CombinedSensorsManager handles beat-to-beat heart rate interval data and pulse oxygen saturation data.
 * 
 * Stores up to 5 raw R-R intervals per second for HRV research.
 * Each interval is stored in its own FIT field to preserve raw data.
 * 
 * Typical intervals per second based on heart rate:
 * - 60 BPM = ~1 interval/sec
 * - 120 BPM = ~2 intervals/sec  
 * - 180 BPM = ~3 intervals/sec
 * 
 * 5 fields covers most cases including high heart rates.
 *
 *
 */
class SensorManager {
    // FIT field IDs (must be unique within your app)
    // Using IDs 3-9 (assuming 0-2 are used by other managers)
    private const HBI_BASE_FIELD_ID = 3;
    private const HBI_COUNT_FIELD_ID = 8;
    private const MAX_INTERVALS = 5;
    private const PULSE_OX_FIELD_ID = 9;
    
    // Array of FIT fields for raw intervals
    private var _hbiFields = null;
    // Field to store count of valid intervals this second
    private var _hbiCountField = null;
    private var _lastIntervals = null;

    // Field to store pulse ox saturation percentage
    private var _pulseOxField = null;
    private var _lastOxygenSaturation = null;
    
    private var _isEnabled = false;

    
    /**
     * Initialize the manager
     */
    public function initialize() {
        _hbiFields = new [MAX_INTERVALS];
        _lastIntervals = [];
        Sensor.setEnabledSensors([
            Sensor.SENSOR_HEARTRATE, 
            Sensor.SENSOR_PULSE_OXIMETRY
        ]);
    }
    
    /**
     * Enable heart beat interval monitoring
     * Creates 5 FIT fields for raw intervals + 1 count field
     * @param session The FIT recording session
     */
    public function enable(session) {
        if (_isEnabled) {
            System.println("HBI: Already enabled");
            System.println("Pulse Oxygen: Already enabled");
            return;
        }
        
        if (session == null) {
            throw new Lang.InvalidValueException("Session cannot be null");
        }
        
        try {
            // Create 5 fields for raw intervals (hbi_0 through hbi_4)
            for (var i = 0; i < MAX_INTERVALS; i++) {
                _hbiFields[i] = session.createField(
                    "hbi_" + i,
                    HBI_BASE_FIELD_ID + i,
                    FitContributor.DATA_TYPE_UINT16,
                    {
                        :mesgType => FitContributor.MESG_TYPE_RECORD,
                        :units => "ms"
                    }
                );
                _hbiFields[i].setData(0);
            }
            
            // Create field to store count of valid intervals
            _hbiCountField = session.createField(
                "hbi_count",
                HBI_COUNT_FIELD_ID,
                FitContributor.DATA_TYPE_UINT8,
                {
                    :mesgType => FitContributor.MESG_TYPE_RECORD,
                    :units => ""
                }
            );
            _hbiCountField.setData(0);

            //field to store oxygen saturation percentage
            _pulseOxField = session.createField(
                "pulseOx",
                PULSE_OX_FIELD_ID,
                FitContributor.DATA_TYPE_UINT8,
                {
                    :mesgType => FitContributor.MESG_TYPE_RECORD,
                    :units => "%"
                }
            );
            _pulseOxField.setData(0);
            
            // Register for heart beat interval and pulse oxygen data
            var options = {
                :period => 1,
                :heartBeatIntervals => { :enabled => true },
                :oxygenSaturation => { :enabled => true }
		    };
            
            Sensor.registerSensorDataListener(self.method(:onSensorData), options);
            
            _isEnabled = true;
            System.println("HBI: Enabled with " + MAX_INTERVALS + " interval fields");
            System.println("Pulse Oxygen: Enabled");
            
        } catch (ex) {
            System.println("HBI/Pulse Oxygen: Failed to enable - " + ex.getErrorMessage());
            _cleanup();
            throw ex;
        }
    }
    
    /**
     * Callback when sensor data is received
     * Stores all raw intervals in separate FIT fields
     */
    public function onSensorData(sensorData as Sensor.SensorData) as Void {
        if (!_isEnabled || sensorData == null) {
            return;
        }
        
        var hrData = sensorData.heartRateData;
        if (hrData == null) {
            _writeEmptyBBRecord();
            System.println("HBI: null data");
            return;
        }

        
        var intervals = hrData.heartBeatIntervals;
        if (intervals == null || intervals.size() == 0) {
            _writeEmptyBBRecord();
            return;
        }
        // Store for external access
        _lastIntervals = intervals;
        System.println("hbi: " + intervals);
        
        // Write each interval to its own field
        var count = intervals.size();
        if (count > MAX_INTERVALS) {
            count = MAX_INTERVALS;
            System.println("HBI: Warning - received " + intervals.size() + " intervals, only storing " + MAX_INTERVALS);
        }

        // System.println("HBI: Writing " + intervals.toString());
        
        // Write intervals to fields
        for (var i = 0; i < MAX_INTERVALS; i++) {
            if (i < count) {
                _hbiFields[i].setData(intervals[i]);
            } else {
                _hbiFields[i].setData(0);
            }
        }
        
        // Write count of valid intervals
        _hbiCountField.setData(count);

        var pulseOx = null;
		if (Activity has :getActivityInfo and Activity.getActivityInfo() has :currentOxygenSaturation) {
			pulseOx = Activity.getActivityInfo().currentOxygenSaturation;
		}

        if (pulseOx == null){
            _writeEmptyPulseOxRecord();
            System.println("Pulse Oxygen: null data");
            return;
        }
        _pulseOxField.setData(pulseOx);
        // Store for external access
        _lastOxygenSaturation = pulseOx;
    }
    
    /**
     * Write zeros when no data is available
     */
    private function _writeEmptyBBRecord() {
        for (var i = 0; i < MAX_INTERVALS; i++) {
            if (_hbiFields[i] != null) {
                _hbiFields[i].setData(0);
            }
        }
        if (_hbiCountField != null) {
            _hbiCountField.setData(0);
        }
    }

    /**
     * Write zeros when no data is available
     */
    private function _writeEmptyPulseOxRecord() {
        if (_pulseOxField != null) {
            _pulseOxField.setData(0);
        }
    }
    
    /**
     * Disable heart beat interval monitoring
     */
    public function disable() {
        if (!_isEnabled) {
            return;
        }
        
        try {
            Sensor.unregisterSensorDataListener();
            System.println("HBI: Disabled");
            System.println("PulseOx: Disabled");
        } catch (ex) {
            System.println("HBI/PulseOx: Error during disable - " + ex.getErrorMessage());
        }
        
        _cleanup();
    }
    
    /**
     * Get the last received intervals array
     */
    public function getLastIntervals() {
        return _lastIntervals;
    }
    
    /**
     * Get the last received pulseOx
     */
    public function getLastPulseOx() {
        return _lastOxygenSaturation;
    }

    /**
     * Check if monitoring is enabled
     */
    public function isEnabled() {
        return _isEnabled;
    }
    
    /**
     * Clean up resources
     */
    public function cleanup() {
        disable();
    }
    
    /**
     * Internal cleanup helper
     */
    private function _cleanup() {
        for (var i = 0; i < MAX_INTERVALS; i++) {
            _hbiFields[i] = null;
        }
        _hbiCountField = null;
        _isEnabled = false;
        _lastIntervals = [];

        _pulseOxField = null;
        _isEnabled = false;
        _lastOxygenSaturation = null;
    }
}