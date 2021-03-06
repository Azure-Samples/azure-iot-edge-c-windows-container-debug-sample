@echo off
SETLOCAL EnableDelayedExpansion

set PROJECT_PATH="%1"
set PROJECT_OUTPUT_PATH="%2"
set PROJECT_CONFIGURATION="%3"
set VS_CRT_REDIST_REL[0]="%VcToolsRedistDir%onecore\x64\Microsoft.VC141.CRT"
set VS_CRT_REDIST_REL[1]="%VcToolsRedistDir%onecore\x64\Microsoft.VC150.CRT"

set UCRT_DLL_PATH="%WindowsSdkVerBinPath%\x64\ucrt"

:: Check execution environment
if "%VSINSTALLDIR%" == "" (
    goto RunFromDevCmd
)

for /L %%n in (0,1,1) do (
    call robocopy.exe !VS_CRT_REDIST_REL[%%n]! %PROJECT_OUTPUT_PATH% /S /E >nul
    if !ERRORLEVEL! LEQ 8 (
        goto StageResistRelOk
    )
)
echo Error while staging debugger binaries. Exiting...
exit /b 1
:StageResistRelOk

call robocopy.exe %UCRT_DLL_PATH% %PROJECT_OUTPUT_PATH% /S /E >nul
if %ERRORLEVEL% GTR 8 (
    :: Non-fatal error, but debug binaries won't work
    echo Warning! Unable to stage UCRT dll, debug binaries will not run in the container.
)

echo Build project...
msbuild %PROJECT_PATH% /p:Configuration=%PROJECT_CONFIGURATION% /p:Platform="x64" /p:OutDir=%PROJECT_OUTPUT_PATH%

if ERRORLEVEL 1 (
    echo Encountered error while building %PROJECT_PATH% , exiting..
    goto :EOF
)

goto :EOF

:RunFromDevCmd
echo.
echo  Please run the script in a Visual Studio Developer Command Prompt 
echo.
goto :EOF

:Usage
echo.
echo Usage:
echo.
echo    NanoDockerBuild.cmd [full-path-to-test-binaries]
echo.
goto :EOF