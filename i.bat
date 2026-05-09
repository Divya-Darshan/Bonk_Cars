@echo off
setlocal

set "GODOT=..\Godot.exe"
set "ADB=.\pt\adb.exe"
set "APK_PATH=.\app\app.apk"
set "PACKAGE_NAME=com.darshnidev.bonk_cars"
set "EXPORT_PRESET=Android"


%GODOT% --headless --export-debug "%EXPORT_PRESET%" "%APK_PATH%"
if errorlevel 1 exit /b 1

%ADB% install -r -t "%APK_PATH%"
if errorlevel 1 exit /b 1

for /f "delims=" %%A in ('%ADB% shell cmd package resolve-activity --brief %PACKAGE_NAME% 2^>nul ^| findstr /r /v "^$"') do set "RESOLVED=%%A"

if not defined RESOLVED (
    echo Could not resolve launcher activity.
    exit /b 1
)

for %%A in (%RESOLVED%) do set "COMPONENT=%%A"
%ADB% shell am start -n %COMPONENT%
exit /b 0