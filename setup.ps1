#!/usr/bin/env pwsh
# LinguaTranslate — Setup Script for Windows PowerShell
# Run: .\setup.ps1

Write-Host ""
Write-Host "🌐 LinguaTranslate — Flutter App Setup" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# 1. Check Flutter
Write-Host "✅ Checking Flutter installation..." -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version 2>&1 | Select-Object -First 1
    Write-Host "   $flutterVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Flutter not found! Please install Flutter first:" -ForegroundColor Red
    Write-Host "   https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Blue
    exit 1
}

# 2. Create asset directories
Write-Host ""
Write-Host "📁 Creating asset directories..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "assets\images" | Out-Null
New-Item -ItemType Directory -Force -Path "assets\animations" | Out-Null
New-Item -ItemType Directory -Force -Path "assets\fonts" | Out-Null
Write-Host "   ✅ assets/images, assets/animations, assets/fonts" -ForegroundColor Green

# 3. Fonts notice
Write-Host ""
Write-Host "⚠️  FONTS NOTICE:" -ForegroundColor Magenta
Write-Host "   Download Poppins from: https://fonts.google.com/specimen/Poppins" -ForegroundColor White
Write-Host "   Place these files in assets/fonts/:" -ForegroundColor White
Write-Host "     - Poppins-Regular.ttf" -ForegroundColor Gray
Write-Host "     - Poppins-Medium.ttf" -ForegroundColor Gray
Write-Host "     - Poppins-SemiBold.ttf" -ForegroundColor Gray
Write-Host "     - Poppins-Bold.ttf" -ForegroundColor Gray
Write-Host ""
Write-Host "   OR: Remove the 'fonts:' section from pubspec.yaml to use system font." -ForegroundColor Yellow

# 4. flutter pub get
Write-Host ""
Write-Host "📦 Installing Flutter packages..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ flutter pub get failed!" -ForegroundColor Red
    exit 1
}
Write-Host "   ✅ Packages installed!" -ForegroundColor Green

# 5. List connected devices
Write-Host ""
Write-Host "📱 Connected devices:" -ForegroundColor Yellow
flutter devices

# 6. Final instructions
Write-Host ""
Write-Host "🚀 Setup Complete!" -ForegroundColor Cyan
Write-Host ""
Write-Host "Run commands:" -ForegroundColor White
Write-Host "  flutter run                   # Run on default device" -ForegroundColor Green
Write-Host "  flutter run -d android        # Run on Android" -ForegroundColor Green
Write-Host "  flutter run -d ios            # Run on iOS (Mac only)" -ForegroundColor Green
Write-Host "  flutter build apk --release   # Build Android APK" -ForegroundColor Green
Write-Host "  flutter build ios --release   # Build iOS IPA (Mac only)" -ForegroundColor Green
Write-Host ""
Write-Host "📖 See README.md for full documentation." -ForegroundColor Cyan
