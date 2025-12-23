<#
Start-emulator.ps1
Usage: run from PowerShell
    .\start-emulator.ps1 -AvdName "Pixel_6_API_35" -WipeData:$false
This script reads `local.properties` to find the Android SDK and launches an emulator with recommended flags.
#>
param(
    [string]$AvdName = "",
    [switch]$WipeData = $false,
    [int]$WaitSeconds = 60
)

# Resolve sdk.dir from local.properties (android/local.properties)
$localProps = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "..\local.properties" | Resolve-Path -ErrorAction SilentlyContinue
if (-not $localProps) {
    $localProps = Join-Path -Path (Get-Location) -ChildPath "local.properties"
}

[string]$sdkDir = $null
if (Test-Path $localProps) {
    Get-Content $localProps | ForEach-Object {
        if ($_ -match '^sdk.dir\s*=\s*(.+)$') { $sdkDir = $matches[1].Trim() }
    }
}

if (-not $sdkDir) {
    Write-Host "Could not find sdk.dir in local.properties. Please set ANDROID_SDK_ROOT or edit android/local.properties." -ForegroundColor Yellow
    if ($env:ANDROID_SDK_ROOT) { $sdkDir = $env:ANDROID_SDK_ROOT }
    else { throw "Android SDK path not found." }
}

$env:ANDROID_SDK_ROOT = $sdkDir
$env:PATH = "$sdkDir\platform-tools;$sdkDir\emulator;$env:PATH"

# List available AVDs
$avds = & "$sdkDir\emulator\emulator.exe" -list-avds 2>&1
if ($avds -is [array] -and $avds.Count -gt 0) { Write-Host "Available AVDs:`n$($avds -join "`n")" }
else { Write-Host "No AVDs found. Use create-avd.ps1 or AVD Manager to create one." -ForegroundColor Yellow }

if (-not $AvdName) {
    # pick first AVD if not provided
    $AvdName = ($avds | Select-Object -First 1) -as [string]
}

if (-not $AvdName) { throw "No AVD specified and none found." }

# Build emulator args
$emulatorArgs = "-avd `"$AvdName`" -netdelay none -netspeed full -gpu host -no-boot-anim -no-snapshot-load -verbose"
if ($WipeData) { $emulatorArgs += " -wipe-data" }

Write-Host "Starting emulator: $AvdName (this may take 30-120s)." -ForegroundColor Cyan
Start-Process -NoNewWindow -FilePath "$sdkDir\emulator\emulator.exe" -ArgumentList $emulatorArgs

# Wait and poll adb for device
$elapsed = 0
while ($elapsed -lt $WaitSeconds) {
    Start-Sleep -Seconds 3
    $elapsed += 3
    $devices = & "$sdkDir\platform-tools\adb.exe" devices | Select-Object -Skip 1 | Where-Object { $_ -match '\S' }
    if ($devices) {
        Write-Host "adb devices:`n$devices" -ForegroundColor Green
        break
    }
    else { Write-Host "Waiting for emulator to appear in adb... ($elapsed s)" -NoNewline; Write-Host "`r" }
}

if (-not $devices) {
    Write-Host "Emulator didn't connect within $WaitSeconds seconds. Check emulator window and logs." -ForegroundColor Red
    Write-Host "To see emulator logs: $sdkDir\emulator\emulator.exe -avd `"$AvdName`" -verbose > `%USERPROFILE%\\emulator-log.txt` 2>&1" -ForegroundColor Yellow
}
else {
    Write-Host "Emulator appears online. You can run: flutter run" -ForegroundColor Green
}
