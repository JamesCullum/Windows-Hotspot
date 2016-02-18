@echo off

:start
cls
echo Choose an action below by entering its number.
echo [1] Activate Hotspot
echo [2] Deactivate Hotspot
echo [3] List connected devices
set /p choice=
if %choice%==1 goto activate
if %choice%==2 goto deactivate
if %choice%==3 goto manage
echo Unknown action, please just enter the number.
pause
goto start

:activate
netsh wlan stop hostednetwork >NUL
echo Enter the SSID of the hotspot
set /p set_ssid=
echo Enter the password for accessing the hotspot (8 characters minimum)
set /p set_pass=
netsh wlan set hostednetwork mode=allow ssid="%set_ssid%" key="%set_pass%"
netsh wlan start hostednetwork
netsh wlan show hostednetwork setting=security
pause
goto start

:deactivate
netsh wlan stop hostednetwork
pause
goto start

:manage
@echo off 
set hasClients=0
arp -a | findstr /r "192\.168\.[0-9][0-9][0-9]\.[0-9][0-9][^0-9]" >test.tmp
for /F "tokens=1,2,3" %%i in (test.tmp) do call :process %%i %%j %%k
del test.tmp
echo Connected Clients
echo ------------------
if %hasClients%==0 echo No device is currently connected to your hotspot
if %hasClients%==1 (
	type result.tmp
	del result.tmp
)
echo ------------------
pause
goto start

:process
set VAR1=%1
ping -a %VAR1% -n 1 | findstr Pinging > loop1.tmp
for /F "tokens=1,2,3" %%i in (loop1.tmp) do call :process2 %%i %%j %%k
del loop1.tmp
goto :EOF

:process2 
SET VAR2=%2
SET VAR3=%3
set hasClients=1
echo %VAR2% %VAR3% >>result.tmp
goto :EOF 

:EOF


