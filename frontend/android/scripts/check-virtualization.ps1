<#
check-virtualization.ps1
Checks common Windows virtualization settings and suggests actions for HAXM/WHPX.
#>
Write-Host "Checking virtualization features and Hyper-V status..." -ForegroundColor Cyan

# Check if CPU virtualization is enabled via systeminfo (may require admin)
try {
    $si = systeminfo
    if ($si -match 'Hyper-V Requirements:\s+VM Monitor Mode Extensions:\s+Yes') { Write-Host "CPU supports VM Monitor Mode Extensions" -ForegroundColor Green }
    if ($si -match 'Hyper-V Requirements:\s+Virtualization Enabled In Firmware:\s+Yes') { Write-Host "Virtualization enabled in firmware (BIOS)" -ForegroundColor Green }
} catch {
    Write-Host "Unable to run systeminfo; run PowerShell as admin to get full details." -ForegroundColor Yellow
}

# Check Hyper-V feature
$hv = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -ErrorAction SilentlyContinue
if ($hv) {
    if ($hv.State -eq 'Enabled') { Write-Host "Hyper-V is Enabled. Using WHPX is recommended (or disable Hyper-V for HAXM)." -ForegroundColor Yellow }
    else { Write-Host "Hyper-V is not enabled." -ForegroundColor Green }
}

# Check Windows Hypervisor Platform
$whpx = Get-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform" -ErrorAction SilentlyContinue
if ($whpx) {
    Write-Host "VirtualMachinePlatform state: $($whpx.State)" -ForegroundColor Cyan
}

Write-Host "If you have an Intel CPU and prefer Intel HAXM, ensure Hyper-V is disabled and install HAXM via SDK Manager or from Intel." -ForegroundColor Yellow
Write-Host "If you use Hyper-V or WSL2, enable 'Windows Hypervisor Platform' and run x86_64 system images with WHPX." -ForegroundColor Yellow
