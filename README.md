# Stingray Warning iOS App

A security awareness iOS app that monitors cellular network conditions to detect potential IMSI catchers and other cellular security threats.

## Features

- **Real-time Network Monitoring**: Continuously monitors cellular radio technology and carrier information
- **2G Detection**: Alerts users when connected to potentially vulnerable 2G networks
- **Anomaly Detection**: Identifies suspicious network behavior patterns
- **Background Monitoring**: Runs monitoring in the background with battery optimization
- **Educational Content**: Provides information about cellular security threats

## Technical Details

- **Platform**: iOS 14.0+
- **Frameworks**: CoreTelephony, UserNotifications, CoreLocation, BackgroundTasks
- **Architecture**: SwiftUI with MVVM pattern
- **Privacy**: No personal data collection, local analysis only

## Development Status

This project is currently in active development. See `TODO.md` for detailed implementation progress.

## Disclaimer

This app is designed as a security awareness tool with significant limitations. It should not be solely relied upon for protection against sophisticated cellular attacks. Detection capabilities are limited compared to dedicated SDR hardware.

## Privacy

This app does not collect, store, or transmit any personal information. All analysis is performed locally on the device.
