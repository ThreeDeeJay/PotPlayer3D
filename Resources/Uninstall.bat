@ECHO OFF

::Check for admin privileges
net session 1>NUL 2>&1 2>&1
IF NOT %ERRORLEVEL% == 0 (goto :Elevate)


IF EXIST "C:\Program Files (x86)\DAUM\PotPlayer\uninstall.exe" (
    SET /P var=Uninstalling: PotPlayer... <NUL
    "C:\Program Files (x86)\DAUM\PotPlayer\uninstall.exe" /S 1>NUL 2>&1
    ECHO Done!
    )

IF EXIST "C:\Program Files (x86)\SVP\unins000.exe" (
    SET /P var=Uninstalling: SVP... <NUL
    "C:\Program Files (x86)\SVP\unins000.exe" /SILENT
    ECHO Done!
    )

IF EXIST "C:\Program Files (x86)\AviSynth\Uninstall.exe" (
    SET /P var=Uninstalling: AviSynth... <NUL
    "C:\Program Files (x86)\AviSynth\Uninstall.exe" /S
    ECHO Done!
    )

PAUSE
EXIT

:Elevate
set "elevate=%temp%\elevate.vbs"
net file 1>NUL 2>NUL || (
    if "%~1" neq "ELEVATE" (
        call :PrintAndLog "Requesting administrative privileges..."
        >"%elevate%" echo CreateObject^("Shell.Application"^).ShellExecute "%comspec%", "/c """"%~0"" ""!ExecutableFilePath!"" ""%~1""""", "", "runas", 1
        start "" "wscript" /B /NOLOGO "%elevate%"
        exit /B 1
    ) else (
        del "%elevate%" 1>NUL 2>&1
        <nul set /P "=Could not auto elevate, please rerun as administrator..."
        pause 1>NUL 2>&1
        exit /B 9001
    )
)
shift
del "%elevate%" 1>NUL 2>&1
cd /d "%CD%"