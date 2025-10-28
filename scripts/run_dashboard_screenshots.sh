#!/bin/bash

# Screenshot Test Runner for Stingray Warning Dashboard
# This script runs the UI tests to capture dashboard screenshots

echo "🎯 Stingray Warning Dashboard Screenshot Tests"
echo "=============================================="

# Check if we're in the right directory
if [ ! -f "StingrayWarning.xcodeproj" ]; then
    echo "❌ Error: StingrayWarning.xcodeproj not found. Please run this script from the project root."
    exit 1
fi

# List available simulators
echo "📱 Available iOS Simulators:"
xcrun simctl list devices available | grep iPhone | head -5

echo ""
echo "🚀 Starting Dashboard Screenshot Tests..."
echo ""

# Try different simulator options
SIMULATORS=("iPhone 16" "iPhone 16 Pro" "iPhone 15" "iPhone 14" "iPhone 13")

for SIMULATOR in "${SIMULATORS[@]}"; do
    echo "🔄 Trying simulator: $SIMULATOR"
    
    # Run the dashboard screenshot test
    if xcodebuild test \
        -project StingrayWarning.xcodeproj \
        -scheme StingrayWarning \
        -destination "platform=iOS Simulator,name=$SIMULATOR" \
        -only-testing:StingrayWarningUITests/testTakeScreenshotOfDashboardTab \
        -only-testing:StingrayWarningUITests/testTakeScreenshotOfMonitoringStates \
        -quiet; then
        
        echo "✅ Screenshots captured successfully!"
        echo ""
        echo "📸 Screenshots saved to:"
        echo "   ~/Documents/Screenshots/"
        echo ""
        echo "📋 Screenshots taken:"
        echo "   • Dashboard initial state"
        echo "   • Dashboard before starting monitoring"
        echo "   • Dashboard with monitoring active"
        echo "   • Dashboard with monitoring stopped"
        echo "   • Status indicators and threat level badges"
        echo ""
        echo "🎉 Test completed successfully!"
        exit 0
    else
        echo "❌ Failed with $SIMULATOR, trying next..."
    fi
done

echo ""
echo "❌ All simulator attempts failed."
echo ""
echo "🔧 Troubleshooting tips:"
echo "   1. Make sure Xcode is installed and updated"
echo "   2. Check that iOS Simulator is available"
echo "   3. Try running: xcrun simctl list devices"
echo "   4. Make sure the app builds successfully first"
echo ""
echo "📖 Manual alternative:"
echo "   1. Open StingrayWarning.xcodeproj in Xcode"
echo "   2. Select a simulator (iPhone 15 or newer)"
echo "   3. Run the UI tests: Product > Test"
echo "   4. Check the test results for screenshots"

exit 1
