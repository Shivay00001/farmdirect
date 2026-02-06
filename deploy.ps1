# FarmDirect Deployment Script
param(
    [ValidateSet("android", "ios", "web", "all")]
    [string]$Platform = "android",
    [switch]$Release = $false,
    [switch]$Install = $false,
    [switch]$Run = $false
)

$ErrorActionPreference = "Continue"
$FarmDirectDir = $PSScriptRoot

# Color functions
function Write-Success { param($msg) Write-Host "✓ $msg" -ForegroundColor Green }
function Write-Error-Custom { param($msg) Write-Host "✗ $msg" -ForegroundColor Red }
function Write-Info { param($msg) Write-Host "ℹ $msg" -ForegroundColor Cyan }
function Write-Warning-Custom { param($msg) Write-Host "⚠ $msg" -ForegroundColor Yellow }

Write-Host ""
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   FarmDirect - Agricultural Marketplace║" -ForegroundColor Cyan
Write-Host "║   Platform Deployment                  ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Check Flutter
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Error-Custom "Flutter SDK not found"
    Write-Info "Run: ..\install-flutter.ps1 to install"
    exit 1
}

$flutterVersion = flutter --version | Select-Object -First 1
Write-Success "Flutter: $flutterVersion"

cd $FarmDirectDir

# Install dependencies
if ($Install -or -not (Test-Path "$FarmDirectDir\.dart_tool")) {
    Write-Info "Installing dependencies..."
    flutter pub get
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Dependencies installed"
    }
    else {
        Write-Error-Custom "Failed to install dependencies"
        exit 1
    }
}

# Create .env if needed
if (-not (Test-Path "$FarmDirectDir\.env")) {
    if (Test-Path "$FarmDirectDir\.env.example") {
        Copy-Item "$FarmDirectDir\.env.example" "$FarmDirectDir\.env"
        Write-Success "Created .env file (please configure Supabase)"
    }
}

# Build mode
$buildMode = if ($Release) { "release" } else { "debug" }
Write-Info "Build mode: $buildMode"
Write-Host ""

# Platform-specific deployment
switch ($Platform) {
    "android" {
        Write-Info "Building for Android..."
        if ($Release) {
            flutter build apk --release
            if ($LASTEXITCODE -eq 0) {
                Write-Success "Android APK built successfully"
                Write-Info "APK location: build\app\outputs\flutter-apk\app-release.apk"
            }
        }
        else {
            if ($Run) {
                flutter run
            }
            else {
                flutter build apk --debug
                Write-Success "Android Debug APK built"
            }
        }
    }
    
    "ios" {
        Write-Info "Building for iOS..."
        if ($Release) {
            flutter build ios --release
            if ($LASTEXITCODE -eq 0) {
                Write-Success "iOS build complete"
                Write-Warning-Custom "Open ios/Runner.xcworkspace in Xcode to archive"
            }
        }
        else {
            if ($Run) {
                flutter run
            }
            else {
                flutter build ios --debug
            }
        }
    }
    
    "web" {
        Write-Info "Building for Web..."
        flutter build web
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Web build complete"
            Write-Info "Web files: build\web\"
            
            # Serve web build
            Write-Host ""
            Write-Info "Starting web server on port 3006..."
            cd build\web
            python -m http.server 3006
        }
    }
    
    "all" {
        Write-Info "Building for all platforms..."
        
        # Android
        flutter build apk --$buildMode
        Write-Success "Android build complete"
        
        # iOS
        if ($IsWindows) {
            Write-Warning-Custom "iOS build requires macOS"
        }
        else {
            flutter build ios --$buildMode
            Write-Success "iOS build complete"
        }
        
        # Web
        flutter build web
        Write-Success "Web build complete"
    }
}

Write-Host ""
Write-Host "═══════════════════════════════════════" -ForegroundColor Green
Write-Success "FarmDirect Deployment Complete"
Write-Host "═══════════════════════════════════════" -ForegroundColor Green
