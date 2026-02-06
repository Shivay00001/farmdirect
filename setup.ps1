# Flutter Setup and Build Script for FarmDirect

Write-Host "FarmDirect - Setup and Build" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green

cd c:\VisionQuantech-Projects\farmdirect

# Check Flutter
Write-Host "`nChecking Flutter installation..." -ForegroundColor Cyan
flutter --version

# Clean previous builds
Write-Host "`nCleaning previous builds..." -ForegroundColor Cyan
flutter clean

# Get dependencies
Write-Host "`nGetting dependencies..." -ForegroundColor Cyan
flutter pub get

# Analyze code
Write-Host "`nAnalyzing code..." -ForegroundColor Cyan
flutter analyze

Write-Host "`n✓ FarmDirect setup complete!" -ForegroundColor Green
Write-Host "`nAvailable commands:" -ForegroundColor Yellow
Write-Host "  flutter run -d chrome        # Run in web browser" -ForegroundColor White
Write-Host "  flutter build apk           # Build Android APK" -ForegroundColor White
Write-Host "  flutter build web           # Build for web" -ForegroundColor White
