@echo off

pushd %~dp0

start /min inject -d -k mai2hook.dll amdaemon.exe -f -c config_common.json config_server.json config_client.json
sinmai -screen-fullscreen 0 -popupwindow -silent-crashes

taskkill /f /im amdaemon.exe > nul 2>&1

echo.
echo Game processes have terminated
pause