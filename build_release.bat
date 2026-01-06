@echo off
echo ===============================================
echo   Where Is Kenny - Release Build Script
echo ===============================================
echo.
echo Package: com.eried.whereiskenny
echo Version: 1.0.0
echo.

REM Check if key.properties exists
if not exist "android\key.properties" (
    echo [ERROR] android\key.properties not found!
    echo.
    echo Please create android\key.properties with:
    echo   storePassword=YOUR_PASSWORD
    echo   keyPassword=YOUR_PASSWORD
    echo   keyAlias=whereiskenny
    echo   storeFile=C:/Path/To/whereiskenny-release-key.jks
    echo.
    echo See RELEASE_GUIDE.md for detailed instructions.
    pause
    exit /b 1
)

echo [*] Cleaning previous build...
call flutter clean

echo.
echo [*] Getting dependencies...
call flutter pub get

echo.
echo [*] Building Android App Bundle (AAB)...
call flutter build appbundle --release

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ===============================================
    echo   BUILD SUCCESSFUL!
    echo ===============================================
    echo.
    echo Output: build\app\outputs\bundle\release\app-release.aab
    echo.
    echo Next steps:
    echo 1. Go to https://play.google.com/console
    echo 2. Upload app-release.aab to Internal Testing
    echo 3. Get your testing link
    echo.
    echo See RELEASE_GUIDE.md for detailed instructions.
    echo.
) else (
    echo.
    echo ===============================================
    echo   BUILD FAILED!
    echo ===============================================
    echo.
    echo Check the error messages above.
    echo.
)

pause
