<#
create-avd.ps1
Usage: Run from PowerShell as administrator if sdkmanager/avdmanager need elevated rights.
This script installs a system image for API 35 (x86_64) and creates an AVD named `Medium_Phone_API_35`.
#>
param(
    [string]$AvdName = "Medium_Phone_API_35",
    [string]$ApiLevel = "35",
    [string]$Image = "google_apis/x86_64",
    [string]$Device = "pixel_4"
)

# resolve sdk dir
$localProps = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "..\local.properties" | Resolve-Path -ErrorAction SilentlyContinue
if (Test-Path $localProps) {
    $props = Get-Content $localProps
    foreach ($line in $props) { if ($line -match '^sdk.dir\s*=\s*(.+)$') { $sdkDir = $matches[1].Trim() } }
}
if (-not $sdkDir) { if ($env:ANDROID_SDK_ROOT) { $sdkDir = $env:ANDROID_SDK_ROOT } else { throw "Android SDK not found." } }

$env:PATH = "$sdkDir\tools\bin;$sdkDir\platform-tools;$sdkDir\emulator;$env:PATH"

# Install system image (accept licenses automatically)
Write-Host "Installing system image: system-images;android-$ApiLevel;$Image" -ForegroundColor Cyan
& "$sdkDir\tools\bin\sdkmanager" "system-images;android-$ApiLevel;$Image" --install --verbose

# Create AVD
Write-Host "Creating AVD: $AvdName" -ForegroundColor Cyan
& "$sdkDir\tools\bin\avdmanager" create avd -n "$AvdName" -k "system-images;android-$ApiLevel;$Image" -d $Device --force

Write-Host "AVD $AvdName created. You can start it with start-emulator.ps1 -AvdName '$AvdName'" -ForegroundColor Green
