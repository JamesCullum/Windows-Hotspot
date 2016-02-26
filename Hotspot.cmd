@echo off

:start
cls
echo Choose an action below by entering its number.
echo [1] Setup or Modify
echo [2] Activate Hotspot
echo [3] Deactivate Hotspot
echo [4] List connected devices
set /p choice=
if %choice%==1 goto setup
if %choice%==2 goto activate
if %choice%==3 goto deactivate
if %choice%==4 goto manage
echo Unknown action, please just enter the number.
pause
goto start

:setup
netsh wlan stop hostednetwork >NUL
echo Enter the SSID of the hotspot
set /p set_ssid=
echo Enter the password for accessing the hotspot (8 characters minimum)
set /p set_pass=
echo Create a [t]emporary or [p]ermanent hotspot?
echo Temporary hotspots vanish after a restart
echo Enter the marked letter of your prefered option
set /p set_permanent=
netsh wlan set hostednetwork mode=allow ssid="%set_ssid%" key="%set_pass%"
netsh wlan start hostednetwork
netsh wlan show hostednetwork setting=security
if "%set_permanent%"=="p" (
	echo netsh wlan start hostednetwork > "%AppData%\Microsoft\Windows\Start Menu\Programs\Startup\permanent_hotspot.cmd"
	echo Hotspot set to permanent mode
)
if "%set_permanent%"=="t" (
	del /f /q "%AppData%\Microsoft\Windows\Start Menu\Programs\Startup\permanent_hotspot.cmd" >NUL
	echo Hotspot set to temporary mode
)
echo ------------------
echo If this is your first setup you need to open up the adapter settings in the Network and Sharing Center
echo Select your working internet connection, right click on it, go to Properties
echo Switch to the tab called Sharing, tick to share the connection and select your created hotspot
echo ------------------
pause
goto start

:activate
netsh wlan start hostednetwork
pause
goto start

:deactivate
netsh wlan stop hostednetwork
pause
goto start

:manage
@echo off 
set hasClients=0
arp -a | findstr /r "192\.168\.[0-9]*\.[2-9][^0-9] 192\.168\.[0-9]*\.[0-9][0-9][^0-9] 192\.168\.[0-9]*\.[0-1][0-9][0-9]" >test.tmp
arp -a | findstr /r "192\.168\.[0-9]*\.2[0-46-9][0-9] 192\.168\.[0-9]*\.25[0-4]" >>test.tmp
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


