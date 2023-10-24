@ECHO OFF
SETlocal EnableExtensions
SETlocal EnableDelayedExpansion

SET "ScriptTitle=PotPlayer 3D"
SET "ScriptVersion=1.1"
SET "ScriptTitleVersion=!ScriptTitle! !ScriptVersion!"
SET "OutputMode=NVIDIA 3D Vision"

reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && SET "WindowsArchitectureBits=32" || SET "WindowsArchitectureBits=64"
SET "ProgramFilesPath=!ProgramFiles!"
IF "!WindowsArchitectureBits!"=="32" (
    SET "ProgramFiles32BitPath=!ProgramFiles!"
    SET "DLLFolderPath32=!WINDIR!\System32"
    SET "WindowsArchitecture=32-bit"
    SET "WindowsArchitecturexBits=x86"
    SET "RegistrySoftwarePath=HKEY_LOCAL_MACHINE\SOFTWARE"
    ) ELSE (
    SET "ProgramFiles32BitPath=!ProgramFiles(x86)!"
    SET "ProgramFiles64BitPath=!ProgramFiles!"
    SET "DLLFolderPath32=!WINDIR!\SysWOW64"
    SET "DLLFolderPath64=!WINDIR!\System32"
    SET "WindowsArchitecture=64-bit"
    SET "WindowsArchitecturexBits=x64"
    SET "RegistrySoftwarePath=HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node"
    )
SET "PotPlayer32BitPath=!ProgramFiles32BitPath!\DAUM\PotPlayer"
SET "SVP32BitPath=!ProgramFiles32BitPath!\SVP\SVPMgr.exe"

net session 1>NUL 2>&1 2>&1
IF !ERRORLEVEL! == 0 (goto :Begin)

ECHO [90m::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[0m
ECHO [90m:::::::::::::::::::::::::::::::::::::::::::::::::::[0m[1m !ScriptTitleVersion! [0m[90m:::::::::::::::::::::::::::::::::::::::::::::::::::[0m
ECHO [90m::::::::::::::::::::::::::::::::::::::::::: By 3DJ - github.com/ThreeDeeJay ::::::::::::::::::::::::::::::::::::::::::::[0m
ECHO.
ECHO [90mThe following will be installed:[0m
ECHO     [1mPotPlayer         [90m- Feature-rich media player[0m
ECHO     [1m    OpenCodec     [90m- Adds decoders like ffmpeg and MVC (Blu-ray 3D)[0m
ECHO     [1m    madVR         [90m- Upscales video that's lower resolution than the display[0m
ECHO     [1mSVP               [90m- Makes video motion smoother (optional)[0m
ECHO     [1mAviSynth          [90m- Makes SVP more efficient with multithreading[0m
ECHO.
ECHO Settings:
CD "%~dp0Resources/PotPlayer/Settings"
FOR %%R IN (*.reg) Do (
    ECHO     [1m%%~nR[0m
    )
CD "%~dp0"
ECHO.

If "!OutputMode!"=="NVIDIA 3D Vision" (
ECHO Display output mode: [92m!OutputMode![0m
) else (
ECHO Display output mode: [94m!OutputMode![0m
)
PAUSE

::Check for admin privileges
net session 1>NUL 2>&1 2>&1
IF NOT !ERRORLEVEL! == 0 (goto :Elevate)

:Begin
cls
echo.

::PotPlayer
SET /P var=[0mInstalling: [0m[1mPotPlayer... <NUL
CALL "%~dp0Resources\PotPlayer\PotPlayerSetup.exe" /S 1>NUL 2>&1
Call :ErrorCheck

::OpenCodec
SET /P var=[0mInstalling: [0m[1mOpenCodec... <NUL
CALL "%~dp0Resources\PotPlayer\OpenCodecSetup.exe" /S 1>NUL 2>&1
Call :ErrorCheck

::MVC decoder
SET /P var=[0mInstalling: [0m[1mMVC decoder... <NUL
If exist "!DLLFolderPath32!\libmfxhw32.dll" (
    SET libmfxhw32.dllExists=True
    MOVE /Y "!DLLFolderPath32!\libmfxhw32.dll" "!DLLFolderPath32!\libmfxhw32.dll.bak" 1>>NUL 2>&1
    )
"%~dp0Resources\7-Zip\7z.exe" x "%~dp0Resources\PotPlayer\OpenCodecSetup.exe" -aoa -y -o"!PotPlayer32BitPath!" 1>> NUL 2>&1
Call :ErrorCheck
CD "%~dp0"

::Settings
SET /P var=[0mInstalling: [0m[1mPotPlayer settings... <NUL
CD "%~dp0Resources/PotPlayer/Settings"
FOR %%R IN (*.reg) Do (
    reg import "%%R" 1>NUL 2>&1
    )
Call :ErrorCheck
CD "%~dp0"

::Driver profile
If "!OutputMode!"=="NVIDIA 3D Vision" (
    SET /P var=[0mInstalling: [0m[1mPotPlayer driver profile... <NUL
    "%~dp0Resources/NVIDIA Profile Inspector/nvidiaProfileInspector.exe" -silent "%~dp0Resources/NVIDIA Profile Inspector/Profiles/DaumPot Player.nip"
    Call :ErrorCheck
    CD "%~dp0"
    )

::SVP
SET /P var=[0mInstalling: [0m[1mSVP... <NUL
CALL "%~dp0Resources\SVP\SVP.exe" 1>NUL 2>&1
taskkill /im SVPMgr.exe /T /F 1>NUL 2>&1
ECHO [92m[Done][0m
SET /P var=[0mInstalling: [0m[1mSVP Configuration... <NUL
IF EXIST "!PROGRAMDATA!\SVP 3.1\Profiles" (
    RMDIR /s /q "!PROGRAMDATA!\SVP 3.1\Profiles" 1>NUL 2>&1
    )
XCOPY "%~dp0Resources\SVP\PROGRAMDATA\SVP 3.1" "!PROGRAMDATA!\SVP 3.1" /s /i /y 1>NUL 2>&1
ECHO [92m[Done][0m

::AviSynth
SET /P var=[0mInstalling: [0m[1mAviSynth... <NUL
CALL "%~dp0Resources\AviSynth\AviSynth.exe" /S 1>NUL 2>&1
XCOPY "%~dp0Resources\AviSynth\WINDIR\SysWOW64\avisynth.dll" "!WINDIR!\SysWOW64\avisynth.dll" /Y 1>NUL 2>&1
ECHO [92m[Done][0m
ECHO.

::Finish
ECHO [92mSetup complete.[0m
ECHO Notes:
ECHO     - To uninstall everything, run Resources/Uninstall.bat
ECHO     - PotPlayer 3D mode is set to Auto. For videos that aren't detected as 3D, click the 3D icon then Enable 3D Video Mode
ECHO     - If you didn't set SVP to run at startup, you'll have to run it manually if you want smooth motion.
If "!OutputMode!"=="NVIDIA 3D Vision" (
    ECHO     - Set a 3D Vision-compatible refresh rate like 120hz
    )
IF "!libmfxhw32.dllExists!"=="True" (
    ECHO     [93m- "!DLLFolderPath32!\libmfxhw32.dll" has been renamed to "libmfxhw32.dll.bak" because hardware decoding is unstable.[0m
    ECHO       If you'd like to restore it, just remove the .bak extension
    )
ECHO To run PotPlayer with SVP press Enter. Otherwise, close this window.
PAUSE>NUL

CALL :Execute "!SVP32BitPath!"
CALL :Execute "!PotPlayer32BitPath!\PotPlayerMini.exe"
EXIT/B

:Execute
explorer "%~1"
EXIT /B

:Elevate
set "elevate=!temp!\elevate.vbs"
net file 1>NUL 2>NUL || (
    if "%~1" neq "ELEVATE" (
        Echo "Requesting administrative privileges..."
        >"!elevate!" echo CreateObject^("Shell.Application"^).ShellExecute "!comspec!", "/c """"%~0"" ""!ExecutableFilePath!"" ""%~1""""", "", "runas", 1
        start "" "wscript" /B /NOLOGO "!elevate!"
        exit /B 1
    ) else (
        del "!elevate!" 1>NUL 2>&1
        <nul set /P "=Could not auto elevate, please rerun as administrator..."
        pause 1>NUL 2>&1
        exit /B 9001
    )
)
shift
del "!elevate!" 1>NUL 2>&1
cd /d "!CD!"

:ErrorCheck
IF !ERRORLEVEL! == 0 (
    Echo [92m[Done][0m
    ) else (
    Echo: [91m[Failed][0m Error: !ERRORLEVEL!
    )
Exit /B