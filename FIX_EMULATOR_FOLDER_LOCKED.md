# Fix "Failed to delete package location" Error

## Problem
Android Studio can't uninstall the emulator because the folder `C:\Users\HP\AppData\Local\Android\Sdk\emulator` is locked or in use.

## Solution: Manual Cleanup

### Step 1: Close All Processes
1. **Close Android Studio completely**
2. **Close any running emulators** (check Task Manager)
3. **Close Cursor/VS Code** (if it's using the emulator)
4. **Check Task Manager** for:
   - `qemu-system-i386.exe`
   - `emulator.exe`
   - `adb.exe`
   - Kill any of these if running

### Step 2: Delete Emulator Folder Manually

**Option A: Using File Explorer (Easier)**
1. Open File Explorer
2. Navigate to: `C:\Users\HP\AppData\Local\Android\Sdk\emulator`
3. **Right-click** the `emulator` folder
4. **Delete** it (or rename it to `emulator_old` as backup)
5. If it says "in use", restart your computer and try again

**Option B: Using PowerShell (If File Explorer fails)**
```powershell
# Stop any adb processes
taskkill /F /IM adb.exe 2>$null
taskkill /F /IM qemu-system-i386.exe 2>$null
taskkill /F /IM emulator.exe 2>$null

# Wait a moment
Start-Sleep -Seconds 2

# Delete the folder
Remove-Item -Path "C:\Users\HP\AppData\Local\Android\Sdk\emulator" -Recurse -Force -ErrorAction SilentlyContinue
```

### Step 3: Reinstall Emulator in Android Studio
1. **Open Android Studio**
2. **Tools → SDK Manager → SDK Tools**
3. **Check "Android Emulator"**
4. **Click "Apply"**
5. Wait for installation to complete

### Step 4: Verify Installation
```bash
flutter emulators
```

You should see your emulators listed without errors.

## Alternative: Use Command Line SDK Manager

If Android Studio GUI continues to fail:

```powershell
cd C:\Users\HP\AppData\Local\Android\Sdk\cmdline-tools\latest\bin

# Uninstall (force)
.\sdkmanager --uninstall "emulator"

# Install fresh
.\sdkmanager "emulator"
```

## If Still Having Issues

1. **Restart your computer** (clears all locks)
2. **Run Android Studio as Administrator**
3. **Try the manual deletion again**
4. **Reinstall via SDK Manager**

