<#
PowerShell helper to copy exported Figma assets into the Flutter project's assets/images folder.
Usage:
  .\import_figma_assets.ps1 -SourceDir C:\path\to\figma-exports

This script will:
 - copy all supported image files (png, jpg, svg) from SourceDir into `assets/images/`
 - optionally rename files according to a mapping if you provide a mapping file
 - run `flutter pub get` afterwards
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$SourceDir,
    [string]$ProjectRoot = "$PSScriptRoot\..",
    [switch]$RunPubGet
)

$source = Resolve-Path $SourceDir
$dest = Resolve-Path (Join-Path $ProjectRoot 'assets/images')

if (-not (Test-Path $source)) {
    Write-Error "Source directory '$SourceDir' does not exist"
    exit 1
}

if (-not (Test-Path $dest)) {
    Write-Host "Creating assets/images directory at $dest"
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
}

$allowed = @('*.png','*.jpg','*.jpeg','*.svg')
foreach ($pattern in $allowed) {
    Get-ChildItem -Path $source -Filter $pattern -File -Recurse | ForEach-Object {
        $target = Join-Path $dest $_.Name
        Copy-Item -Path $_.FullName -Destination $target -Force
        Write-Host "Copied $($_.Name) -> $target"
    }
}

if ($RunPubGet) {
    Write-Host "Running flutter pub get..."
    Push-Location $ProjectRoot
    flutter pub get
    Pop-Location
}

Write-Host "Done. Place assets into $dest and run 'flutter pub get' if you didn't use -RunPubGet."
