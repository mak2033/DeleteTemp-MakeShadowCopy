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
echo *** 1. Delete all temprory files every login.   ***
echo ***                                             ***
echo *** 2. Make a shadow copy  every login.         ***
echo ***                                             ***
echo *** 3. AutoUpdate Windows time  every login.    ***
echo ***                                             ***
echo *** 4. Exit                                     ***
echo ***                                             ***
echo ***************************************************

:choose
set /p choice=Please choose one of the above or 4 to exit: 
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
  cls
  call :AutoUpdateTime
) else if %choice%==4 (
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
    echo [31m WARNING: Drive %%a does not exist. Skipping...[0m
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

:AutoUpdateTime
del /q /f "%temp%\b64"  >nul 2>nul
del /q /f "%temp%\decoded"  >nul 2>nul
sc config w32time start=auto
echo //48AD8AeABtAGwAIAB2AGUAcgBzAGkAbwBuAD0AIgAxAC4AMAAiACAAZQBuAGMAbwBkAGkAbgBnAD0AIgBVAFQARgAtADEANgAiAD8APgANAAoAPABUAGEAcwBrACAAdgBlAHIAcwBpAG8AbgA9ACIAMQAuADIAIgAgAHgAbQBsAG4AcwA9ACIAaAB0AHQAcAA6AC8ALwBzAGMAaABlAG0AYQBzAC4AbQBpAGMAcgBvAHMAbwBmAHQALgBjAG8AbQAvAHcAaQBuAGQAbwB3AHMALwAyADAAMAA0AC8AMAAyAC8AbQBpAHQALwB0AGEAcwBrACIAPgANAAoAIAAgADwAUgBlAGcAaQBzAHQAcgBhAHQAaQBvAG4ASQBuAGYAbwA+AA0ACgAgACAAIAAgADwARABhAHQAZQA+ADIAMAAxADAALQAwADMALQAzADAAVAAxADYAOgA1ADgAOgAwADkALgA3ADIAOQA0ADEANAA1ADwALwBEAGEAdABlAD4ADQAKACAAIAAgACAAPABBAHUAdABoAG8AcgA+AEEAZABtAGkAbgBpAHMAdAByAGEAdABvAHIAPAAvAEEAdQB0AGgAbwByAD4ADQAKACAAIAA8AC8AUgBlAGcAaQBzAHQAcgBhAHQAaQBvAG4ASQBuAGYAbwA+AA0ACgAgACAAPABUAHIAaQBnAGcAZQByAHMAPgANAAoAIAAgACAAIAA8AEwAbwBnAG8AbgBUAHIAaQBnAGcAZQByAD4ADQAKACAAIAAgACAAIAAgADwARQBuAGEAYgBsAGUAZAA+AHQAcgB1AGUAPAAvAEUAbgBhAGIAbABlAGQAPgANAAoAIAAgACAAIAA8AC8ATABvAGcAbwBuAFQAcgBpAGcAZwBlAHIAPgANAAoAIAAgADwALwBUAHIAaQBnAGcAZQByAHMAPgANAAoAIAAgADwAUAByAGkAbgBjAGkAcABhAGwAcwA+AA0ACgAgACAAIAAgADwAUAByAGkAbgBjAGkAcABhAGwAIABpAGQAPQAiAEEAdQB0AGgAbwByACIAPgANAAoAIAAgACAAIAAgACAAPABVAHMAZQByAEkAZAA+AEEAZABtAGkAbgBpAHMAdAByAGEAdABvAHIAPAAvAFUAcwBlAHIASQBkAD4ADQAKACAAIAAgACAAIAAgADwATABvAGcAbwBuAFQAeQBwAGUAPgBJAG4AdABlAHIAYQBjAHQAaQB2AGUAVABvAGsAZQBuADwALwBMAG8AZwBvAG4AVAB5AHAAZQA+AA0ACgAgACAAIAAgACAAIAA8AFIAdQBuAEwAZQB2AGUAbAA+AEgAaQBnAGgAZQBzAHQAQQB2AGEAaQBsAGEAYgBsAGUAPAAvAFIAdQBuAEwAZQB2AGUAbAA+AA0ACgAgACAAIAAgADwALwBQAHIAaQBuAGMAaQBwAGEAbAA+AA0ACgAgACAAPAAvAFAAcgBpAG4AYwBpAHAAYQBsAHMAPgANAAoAIAAgADwAUwBlAHQAdABpAG4AZwBzAD4ADQAKACAAIAAgACAAPABNAHUAbAB0AGkAcABsAGUASQBuAHMAdABhAG4AYwBlAHMAUABvAGwAaQBjAHkAPgBJAGcAbgBvAHIAZQBOAGUAdwA8AC8ATQB1AGwAdABpAHAAbABlAEkAbgBzAHQAYQBuAGMAZQBzAFAAbwBsAGkAYwB5AD4ADQAKACAAIAAgACAAPABEAGkAcwBhAGwAbABvAHcAUwB0AGEAcgB0AEkAZgBPAG4AQgBhAHQAdABlAHIAaQBlAHMAPgBmAGEAbABzAGUAPAAvAEQAaQBzAGEAbABsAG8AdwBTAHQAYQByAHQASQBmAE8AbgBCAGEAdAB0AGUAcgBpAGUAcwA+AA0ACgAgACAAIAAgADwAUwB0AG8AcABJAGYARwBvAGkAbgBnAE8AbgBCAGEAdAB0AGUAcgBpAGUAcwA+AHQAcgB1AGUAPAAvAFMAdABvAHAASQBmAEcAbwBpAG4AZwBPAG4AQgBhAHQAdABlAHIAaQBlAHMAPgANAAoAIAAgACAAIAA8AEEAbABsAG8AdwBIAGEAcgBkAFQAZQByAG0AaQBuAGEAdABlAD4AdAByAHUAZQA8AC8AQQBsAGwAbwB3AEgAYQByAGQAVABlAHIAbQBpAG4AYQB0AGUAPgANAAoAIAAgACAAIAA8AFMAdABhAHIAdABXAGgAZQBuAEEAdgBhAGkAbABhAGIAbABlAD4AdAByAHUAZQA8AC8AUwB0AGEAcgB0AFcAaABlAG4AQQB2AGEAaQBsAGEAYgBsAGUAPgANAAoAIAAgACAAIAA8AFIAdQBuAE8AbgBsAHkASQBmAE4AZQB0AHcAbwByAGsAQQB2AGEAaQBsAGEAYgBsAGUAPgBmAGEAbABzAGUAPAAvAFIAdQBuAE8AbgBsAHkASQBmAE4AZQB0AHcAbwByAGsAQQB2AGEAaQBsAGEAYgBsAGUAPgANAAoAIAAgACAAIAA8AEkAZABsAGUAUwBlAHQAdABpAG4AZwBzAD4ADQAKACAAIAAgACAAIAAgADwAUwB0AG8AcABPAG4ASQBkAGwAZQBFAG4AZAA+AHQAcgB1AGUAPAAvAFMAdABvAHAATwBuAEkAZABsAGUARQBuAGQAPgANAAoAIAAgACAAIAAgACAAPABSAGUAcwB0AGEAcgB0AE8AbgBJAGQAbABlAD4AZgBhAGwAcwBlADwALwBSAGUAcwB0AGEAcgB0AE8AbgBJAGQAbABlAD4ADQAKACAAIAAgACAAPAAvAEkAZABsAGUAUwBlAHQAdABpAG4AZwBzAD4ADQAKACAAIAAgACAAPABBAGwAbABvAHcAUwB0AGEAcgB0AE8AbgBEAGUAbQBhAG4AZAA+AHQAcgB1AGUAPAAvAEEAbABsAG8AdwBTAHQAYQByAHQATwBuAEQAZQBtAGEAbgBkAD4ADQAKACAAIAAgACAAPABFAG4AYQBiAGwAZQBkAD4AdAByAHUAZQA8AC8ARQBuAGEAYgBsAGUAZAA+AA0ACgAgACAAIAAgADwASABpAGQAZABlAG4APgBmAGEAbABzAGUAPAAvAEgAaQBkAGQAZQBuAD4ADQAKACAAIAAgACAAPABSAHUAbgBPAG4AbAB5AEkAZgBJAGQAbABlAD4AZgBhAGwAcwBlADwALwBSAHUAbgBPAG4AbAB5AEkAZgBJAGQAbABlAD4ADQAKACAAIAAgACAAPABXAGEAawBlAFQAbwBSAHUAbgA+AGYAYQBsAHMAZQA8AC8AVwBhAGsAZQBUAG8AUgB1AG4APgANAAoAIAAgACAAIAA8AEUAeABlAGMAdQB0AGkAbwBuAFQAaQBtAGUATABpAG0AaQB0AD4AUAAzAEQAPAAvAEUAeABlAGMAdQB0AGkAbwBuAFQAaQBtAGUATABpAG0AaQB0AD4ADQAKACAAIAAgACAAPABQAHIAaQBvAHIAaQB0AHkAPgA3ADwALwBQAHIAaQBvAHIAaQB0AHkAPgANAAoAIAAgADwALwBTAGUAdAB0AGkAbgBnAHMAPgANAAoAIAAgADwAQQBjAHQAaQBvAG4AcwAgAEMAbwBuAHQAZQB4AHQAPQAiAEEAdQB0AGgAbwByACIAPgANAAoAIAAgACAAIAA8AEUAeABlAGMAPgANAAoAIAAgACAAIAAgACAAPABDAG8AbQBtAGEAbgBkAD4AYwBtAGQALgBlAHgAZQA8AC8AQwBvAG0AbQBhAG4AZAA+AA0ACgAgACAAIAAgACAAIAA8AEEAcgBnAHUAbQBlAG4AdABzAD4ALwBjACAAbgBlAHQAIABzAHQAbwBwACAAdwAzADIAdABpAG0AZQAgACYAYQBtAHAAOwAgAG4AZQB0ACAAcwB0AGEAcgB0ACAAdwAzADIAdABpAG0AZQAgACYAYQBtAHAAOwAgAHcAMwAyAHQAbQAgAC8AcgBlAHMAeQBuAGMAIAAvAGYAbwByAGMAZQA8AC8AQQByAGcAdQBtAGUAbgB0AHMAPgANAAoAIAAgACAAIAA8AC8ARQB4AGUAYwA+AA0ACgAgACAAPAAvAEEAYwB0AGkAbwBuAHMAPgANAAoAPAAvAFQAYQBzAGsAPgA=> "%temp%\b64"
certutil /decode "%temp%\b64" "%temp%\Autoupdatetime.xml" >nul 2>nul
schtasks /create /xml "%temp%\Autoupdatetime.xml" /tn "AutoUpdateTime"
del /q /f "%temp%\b64"  >nul 2>nul
del /q /f "%temp%\Autoupdatetime.xml"  >nul 2>nul
cls
echo.
echo [32 Finshed...[0m
echo Please press any key to continue...
pause
set choice=""
goto :START