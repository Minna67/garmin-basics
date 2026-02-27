/**
 * SecondaryViewDelegate.mc - Simplified version without complex containers
 */
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

class activityTypeViewDelegate extends WatchUi.BehaviorDelegate {
    private var _screenManager;
    
    // Button area coordinates - calculated once
    private var _sleepButtonX, _sleepButtonY, _sleepButtonWidth, _sleepButtonHeight;
    private var _exerciseButtonX, _exerciseButtonY, _exerciseButtonWidth, _exerciseButtonHeight;
    private var _stressButtonX, _stressButtonY, _stressButtonWidth, _stressButtonHeight;
    
    function initialize(screenManager) {
        BehaviorDelegate.initialize();
        _screenManager = screenManager;
        System.println("DELEGATE: activityTypeViewDelegate initialized for secondary view");
        _calculateButtonAreas();
    }
    
    /**
     * Calculate button positions (matches SecondaryView layout)
     * Simple approach - no complex data structures
     */
    private function _calculateButtonAreas() {
        var deviceSettings = System.getDeviceSettings();
        var width = deviceSettings.screenWidth;
        var height = deviceSettings.screenHeight;
        
        var buttonWidth = width * 0.7;
        var buttonHeight = height * 0.12;
        var buttonSpacing = height * 0.2;
        var buttonX = (width - buttonWidth) / 2;
        
        // Cig button area
        _sleepButtonX = buttonX;
        _sleepButtonY = height * 0.3;
        _sleepButtonWidth = buttonWidth;
        _sleepButtonHeight = buttonHeight;
        
        // Exercise button area
        _exerciseButtonX = buttonX;
        _exerciseButtonY = _sleepButtonY + buttonSpacing;
        _exerciseButtonWidth = buttonWidth;
        _exerciseButtonHeight = buttonHeight;

        // Stress buton area
        _stressButtonX = buttonX;
        _stressButtonY = _exerciseButtonY + buttonSpacing;
        _stressButtonWidth = buttonWidth;
        _stressButtonHeight = buttonHeight;
    }
    
    /**
     * Handle touch/tap events - Direct start without confirmation
     */
    function onTap(clickEvent) {
        var coords = clickEvent.getCoordinates();
        var x = coords[0];
        var y = coords[1];
        
        System.println("INPUT: Tap detected on secondary view at (" + x + ", " + y + ")");
        
        // Check sleep button
        if (_isPointInButton(x, y, _sleepButtonX, _sleepButtonY, _sleepButtonWidth, _sleepButtonHeight)) {
            System.println("INPUT: Sleep button tapped");
            _startRecordingDirectly("sleep");
            return true;
        }
        
        // Check exercise button
        if (_isPointInButton(x, y, _exerciseButtonX, _exerciseButtonY, _exerciseButtonWidth, _exerciseButtonHeight)) {
            System.println("INPUT: Exercise button tapped");
            _startRecordingDirectly("exercise");
            return true;
        }

        //Check stress button
        if (_isPointInButton(x, y, _stressButtonX, _stressButtonY, _stressButtonWidth, _stressButtonHeight)) {
            System.println("INPUT: Stress button tapped");
            _startRecordingDirectly("stress");
            return true;
        }
        
        return false; // No button hit
    }
    
    /**
     * Simple point-in-rectangle check
     */
    private function _isPointInButton(x, y, buttonX, buttonY, buttonWidth, buttonHeight) {
        return x >= buttonX && 
               x <= buttonX + buttonWidth &&
               y >= buttonY && 
               y <= buttonY + buttonHeight;
    }

    /**
     * Start recording directly without confirmation
     */
    private function _startRecordingDirectly(activityType) {
        System.println("EVENT: Starting " + activityType + " recording directly");
        
        // Record the timestamp of start
        _screenManager.handleActivityStartEvent(activityType);
        
        // Show recording screen directly
        _screenManager.showRecordingScreen(activityType);
    }
    
    /**
     * Handle swipe up to return to main screen
     */
    function onSwipe(swipeEvent) {
        if (swipeEvent.getDirection() == WatchUi.SWIPE_UP) {
            System.println("INPUT: Swipe up detected on secondary view - returning to main");
            _screenManager.handleSwipeUp();
            return true;
        }
        return false;
    }
    
    /**
     * Handle back button
     */
    function onBack() {
        System.println("INPUT: Back button pressed on secondary view - returning to main");
        _screenManager.handleSwipeUp();
        return true;
    }

    function onKey(keyEvent) {
        var key = keyEvent.getKey();
        System.println("INPUT: Key pressed on secondary view: " + key);
        
        switch (key) {
                
            case WatchUi.KEY_DOWN:
                System.println("INPUT: KEY_DOWN - returning to main screen");
                _screenManager.handleSwipeUp();
                return true;
            
        }
        
        return false;
    }
}