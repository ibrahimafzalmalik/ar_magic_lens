# Fix Android Emulator DLL Errors

## Problem
The Android emulator is showing multiple DLL errors:
- `liblibprotobuf.dll`
- `libglib2_windows_msvc-x86_64.dll`
- `libandroid-emu-metrics.dll`
- `libandroid-emu-agents.dll`

These are QEMU/emulator dependencies that are missing or corrupted.

## Solution 1: Reinstall Emulator via Android Studio (Recommended)

1. **Open Android Studio**
2. **Go to**: Tools → SDK Manager (or File → Settings → Appearance & Behavior → System Settings → Android SDK)
3. **SDK Tools Tab**: 
   - Uncheck "Android Emulator"
   - Click "Apply" to uninstall
   - Wait for uninstallation
   - Check "Android Emulator" again
   - Click "Apply" to reinstall
4. **Also verify these are installed**:
   - ✅ Android Emulator
   - ✅ Android SDK Platform-Tools
   - ✅ Android SDK Build-Tools
5. **Restart Android Studio** after installation

## Solution 2: Reinstall via Command Line

```powershell
# Navigate to SDK location
cd C:\Users\HP\AppData\Local\Android\Sdk\cmdline-tools\latest\bin

# List installed packages
.\sdkmanager --list

# Uninstall emulator
.\sdkmanager --uninstall "emulator"

# Reinstall emulator
.\sdkmanager "emulator"

# Also reinstall platform-tools
.\sdkmanager "platform-tools"
```

## Solution 3: Use Android Studio's AVD Manager

1. **Open Android Studio**
2. **Go to**: Tools → Device Manager
3. **Delete existing emulators** (if any)
4. **Create a new emulator**:
   - Click "Create Device"
   - Choose a device (e.g., Pixel 7)
   - Download a system image if needed
   - Finish setup
5. **Launch from Android Studio** first to verify it works

## Solution 4: Check Windows Defender/Antivirus

Sometimes antivirus software blocks or removes DLL files:
1. **Add exception** for: `C:\Users\HP\AppData\Local\Android\Sdk\emulator\`
2. **Temporarily disable** antivirus and try again
3. **Re-enable** after testing

## Solution 5: Use Physical Device (Quick Alternative)

If emulator continues to have issues:
1. **Enable USB Debugging** on your Android phone
2. **Connect via USB**
3. **Run**: `flutter devices` (should see your phone)
4. **Run**: `flutter run -d <device-id>`

## Verify Fix

After reinstalling:
```bash
flutter emulators
flutter emulators --launch Pixel_7_Pro_API_27
flutter devices
```

The emulator should boot without DLL errors.

