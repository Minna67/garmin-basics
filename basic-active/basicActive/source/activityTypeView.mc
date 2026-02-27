// SecondaryView.mc - Example secondary screen
using Toybox.WatchUi;
using Toybox.Graphics;

class activityTypeView extends WatchUi.View {
    
    function initialize() {
        View.initialize();
    }
    
    function onLayout(dc) {
        // Simple layout - you can customize this
    }
    
    function onShow() {
        // Called when screen becomes visible
        WatchUi.requestUpdate();
    }
    
    function onUpdate(dc) {
        // Clear the screen
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Draw secondary screen content
        _drawSecondaryContent(dc);
    }
    
    // Separate drawing logic for better organization
    private function _drawSecondaryContent(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        // Title
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2, 
            height / 9, 
            Graphics.FONT_SMALL, 
            "Activity Type", 
            Graphics.TEXT_JUSTIFY_CENTER
        );
        
        _drawTrackingButtons(dc);
        
        dc.drawText(
            width / 2, 
            height * 0.85, 
            Graphics.FONT_SMALL, 
            "Swipe up to return", 
            Graphics.TEXT_JUSTIFY_CENTER
        );

    }

    private function _drawTrackingButtons(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        // Button dimensions
        var buttonWidth = width * 0.7;
        var buttonHeight = height * 0.12;
        var buttonSpacing = height * 0.2;
        
        // Sleep button
        var sleepButtonY = height * 0.3;
        _drawButton(dc, "Sleep", buttonWidth, buttonHeight, sleepButtonY, Graphics.COLOR_GREEN);
        
        // Exercise button  
        var exerciseButtonY = sleepButtonY + buttonSpacing;
        _drawButton(dc, "Exercise", buttonWidth, buttonHeight, exerciseButtonY, Graphics.COLOR_GREEN);

        // Stress button
        var stressButtonY = exerciseButtonY + buttonSpacing;
        _drawButton(dc, "Stress", buttonWidth, buttonHeight, stressButtonY, Graphics.COLOR_GREEN);

    }

    private function _drawButton(dc, text, buttonWidth, buttonHeight, buttonY, color) {
        var width = dc.getWidth();
        var buttonX = (width - buttonWidth) / 2;
        
        // Draw button background
        dc.setColor(color, color);
        dc.fillRoundedRectangle(buttonX, buttonY, buttonWidth, buttonHeight, 8);
        
        // Draw button border
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawRoundedRectangle(buttonX, buttonY, buttonWidth, buttonHeight, 8);
        
        // Draw button text
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2, 
            buttonY + buttonHeight / 2, 
            Graphics.FONT_MEDIUM, 
            text, 
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}