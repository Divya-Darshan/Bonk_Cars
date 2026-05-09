@echo off
setlocal

set "ADB=.\pt\adb.exe"
set "PACKAGE_NAME=com.darshnidev.bonk_cars"

for /f "delims=" %%A in ('%ADB% shell cmd package resolve-activity --brief %PACKAGE_NAME% 2^>nul ^| findstr /r /v "^$"') do set "COMPONENT=%%A"

if not defined COMPONENT (
    echo Could not resolve launcher activity.
    exit /b 1
)

%ADB% shell am force-stop %PACKAGE_NAME%
%ADB% shell am start -n %COMPONENT%