@echo off

:init
setlocal DisableDelayedExpansion
set "batchPath=%~0"
for %%k in (%0) do set batchName=%%~nk
set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
setlocal EnableDelayedExpansion

:checkPrivileges
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
ECHO.
ECHO **************************************
ECHO Invoking UAC for Privilege Escalation
ECHO **************************************

ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
ECHO args = "ELEV " >> "%vbsGetPrivileges%"
ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
ECHO Next >> "%vbsGetPrivileges%"
ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
"%SystemRoot%\System32\WScript.exe" "%vbsGetPrivileges%" %*
exit /B

:gotPrivileges
setlocal & pushd .
cd /d %~dp0
if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)

:::::::::::::::::::::::::::::::::::
::START::
::::::::::::::::::::::::::::::::::
:START
cls
echo.
echo.
echo [32m***** Program Created by Eng.Moath alkhateeb ******
echo ******* Mak.2033@yahoo.com , +962780235959 ********[0m
echo.
echo ***************************************************
echo ***                                             ***
echo ***       Choose one of the following ...       *** 
echo ***                                             ***
echo *** 1. Create file to Delete all temprory files ***
echo ***                                             ***
echo *** 2. Create scheduled task make a shadow copy ***
echo ***                                             ***
echo *** 3. Exit                                     ***
echo ***                                             ***
echo ***************************************************

:choose
set /p choice=Please choose 1, 2, or 3 to exit: 
if not defined choice (
echo You did not enter a number.
goto START
) else if %choice%==1 (
  cls
  call :deleteTempFiles
) else if %choice%==2 (
  cls
  msg * "Enable system protuction first for all driver want to make a shadow copy"
  control sysdm.cpl,,4
  @REM echo Please press any key to continu...
  pause
  call :createShadowCopy
) else if %choice%==3 (
  exit
) else if %choice%=="" (
  echo  [32mPlease choose one of the above [0m
  call :choose
) else  (
  echo  [32mThe entered value is invalid please choose one of the above [0m
  call :choose
)
call :choose

:deleteTempFiles
del /q /f "%temp%\b64"  >nul 2>nul
del /q /f "%temp%\decoded"  >nul 2>nul
echo QGVjaG8gb2ZmDQpwYXRoPSIldGVtcCUiLCAiJXdpbmRpciUvdGVtcCIsICIlYXBwZGF0YSVcTWljcm9zb2Z0XFdvcmQiLCAiJWFwcGRhdGElXE1pY3Jvc29mdFxQb3dlclBvaW50Ig0KZm9yIC9kICUlZCBpbiAoJXBhdGglKSBkbyAoDQogIGVjaG8gRGVsZXRpbmcgZmlsZXMgaW4gJSVkDQogIHB1c2hkICUlZA0KICByZCAvcyAvcSAuIDI+bnVsDQopDQo= >"%temp%\b64"
certutil /decode "%temp%\b64" "%temp%\delete_temp_files.bat" >nul 2>nul
move "%temp%\delete_temp_files.bat" "%systemdrive%\"
schtasks /create /tn "Del_temp_files" /sc onlogon /rl highest /f /tr "%systemdrive%\delete_temp_files.bat"
del /q /f "%temp%\b64"  >nul 2>nul
del /q /f "%temp%\decoded"  >nul 2>nul
cls
echo.
echo [32Finshed...[0m
echo Please press any key to continue...
pause
set choice=""
goto :START

:createShadowCopy
echo.
set /p drives=Enter drive letters separated by commas (e.g. C,D,E):
if not defined drives (
echo You did not enter a letter.
pause
goto :createShadowCopy
)
for %%a in (%drives%) do (
  if exist %%a:\ (
::    wmic shadowcopy call create Volume=%%a:\
    schtasks /create /tn "Shadow partition %%a" /sc onlogon /rl highest /f /tr "wmic shadowcopy call create Volume=%%a:\\"
  ) else (
    echo [31mWARNING: Drive %%a does not exist. Skipping...[0m
    pause
  )
)
cls
echo.
echo [32 Finshed...[0m
echo.
echo Please press any key to continue...
pause
set choice=""
goto :START
