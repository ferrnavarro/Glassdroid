# Glass

A lightweight, native macOS GUI wrapper for [scrcpy](https://github.com/Genymobile/scrcpy) — mirror and control your Android device without touching the Terminal.

![macOS](https://img.shields.io/badge/platform-macOS%2014%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5-orange)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-purple)

## Features

- **Automatic Device Discovery** — Detects connected Android devices via `adb devices` with live polling every 3 seconds.
- **Device Aliases** — Right-click a device to give it a friendly name instead of seeing the serial number. Aliases persist across launches.
- **Configuration Dashboard** — No need to memorize CLI flags. Adjust everything from the UI:
  - Resolution (Original, 1080p, 720p)
  - Video bitrate (1–50 Mbps)
  - Framerate limit (Unlimited, 60, 30 FPS)
  - Window size (width & height sliders)
  - Always on Top
  - Stay Awake
  - Turn Screen Off (mirror with phone screen off)
  - Audio forwarding toggle
- **One-Click Start/Stop** — Prominent Play/Stop button to launch or kill the `scrcpy` process.
- **Console Log** — Collapsible panel showing live `scrcpy` output for troubleshooting.
- **Status Indicators** — Color-coded device status: green (Ready), orange (Unauthorized), red (Offline).
- **Dark Mode** — Follows the native macOS system appearance.
- **Secure** — All execution is local. No data is sent externally. Process spawning uses argument arrays (no shell injection).

## Prerequisites

Glass requires `scrcpy` and `adb` to be installed on your Mac. The easiest way is via [Homebrew](https://brew.sh):

```bash
brew install scrcpy
```

> This will also install `android-platform-tools` (which includes `adb`) as a dependency.

Make sure USB debugging is enabled on your Android device:
1. Go to **Settings → About phone** and tap **Build number** 7 times to enable Developer Options.
2. Go to **Settings → Developer options** and enable **USB debugging**.
3. Connect your device via USB and accept the RSA fingerprint prompt.

## Building & Running

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/Glass.git
   cd Glass
   ```
2. Open `Glass.xcodeproj` in Xcode.
3. Select the **Glass** scheme and your Mac as the run destination.
4. Press **⌘R** to build and run.

> **Note:** The App Sandbox is disabled so Glass can spawn `adb` and `scrcpy` processes. This is required for the app to function.

## Usage

1. **Connect** your Android device via USB (or set up wireless ADB).
2. **Launch** Glass — your device should appear in the sidebar within a few seconds.
3. **Configure** the mirroring settings in the detail panel (resolution, bitrate, window size, etc.).
4. **Click** the green **Start Mirroring** button — the `scrcpy` window will open.
5. **Click** the red **Stop Mirroring** button to end the session.

### Device Aliases

- **Right-click** a device in the sidebar and select **Rename…** to set a custom alias.
- Select **Clear Alias** to revert to showing the serial number.
- Aliases are saved locally and persist across app restarts.

## Architecture

Glass follows an **MVVM** pattern built with SwiftUI and the Observation framework:

```
Glass/
├── GlassApp.swift              # App entry point, window configuration
├── Glass.entitlements           # Sandbox disabled for process spawning
├── ContentView.swift            # NavigationSplitView layout
├── Models/
│   ├── Device.swift             # Device struct with serial, status, alias
│   └── ScrcpyConfiguration.swift # All scrcpy flags as typed properties
├── Services/
│   ├── ADBService.swift         # Executable discovery, adb devices parsing
│   └── ScrcpyService.swift      # Process lifecycle management
├── ViewModels/
│   ├── DeviceViewModel.swift    # Device polling, alias persistence
│   └── SessionViewModel.swift   # scrcpy session & console log
└── Views/
    ├── DeviceListView.swift     # Sidebar device list with inline renaming
    ├── ConfigurationView.swift  # Settings form & start/stop controls
    ├── ConsoleView.swift        # Collapsible console output
    └── ToolStatusBanner.swift   # Missing dependency warnings
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "adb not found" / "scrcpy not found" | Install via `brew install scrcpy` and click **Re-check** in the app. |
| Device shows as "Unauthorized" | Accept the RSA debugging prompt on your phone. |
| No devices appear | Ensure USB debugging is enabled and run `adb devices` in Terminal to verify. |
| scrcpy window doesn't open | Check the Console Log panel at the bottom of Glass for error output. |

## License

This project is provided as-is for personal use.

## Acknowledgments

- [scrcpy](https://github.com/Genymobile/scrcpy) by Genymobile — the brilliant tool that makes Android mirroring possible.
- [Homebrew](https://brew.sh) — for making installation painless.
