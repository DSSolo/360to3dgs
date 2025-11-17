@echo off
setlocal enabledelayedexpansion

rem Get the folder where this .bat resides (with trailing backslash)
set "BASE_DIR=%~dp0"

echo Script base folder: "%BASE_DIR%"

rem -------------------------------------------------------------------
rem Ask user for FOV and split resolution (with defaults)
rem -------------------------------------------------------------------
set "FOV=90.0"
set "SPLIT_RES=768"

echo.
set /p "FOV=Enter FOV in degrees [default: 90.0]: "
if "%FOV%"=="" set "FOV=90.0"

set /p "SPLIT_RES=Enter split resolution per view (pixels, e.g. 768 or 1200) [default: 768]: "
if "%SPLIT_RES%"=="" set "SPLIT_RES=768"

echo.
echo Using FOV=%FOV%
echo Using equirectangularSplitResolution=%SPLIT_RES%
echo.

rem -------------------------------------------------------------------
rem Resolve ALICEVISION_ROOT / ALICEVISION_BIN
rem -------------------------------------------------------------------

rem If ALICEVISION_ROOT is not already defined in the environment,
rem try to infer it from aliceVision_split360Images.exe on PATH.
if not defined ALICEVISION_ROOT (
    echo ALICEVISION_ROOT not defined, trying to infer from aliceVision_split360Images.exe...

    for /f "delims=" %%I in ('where aliceVision_split360Images.exe 2^>nul') do (
        rem %%I = full path to aliceVision_split360Images.exe
        set "ALICEVISION_BIN=%%~dpI"
        rem ALICEVISION_ROOT is the parent of the bin folder
        for %%D in ("%%~dpI..") do set "ALICEVISION_ROOT=%%~fD"
        goto :AV_FOUND
    )

    echo ERROR: Could not find aliceVision_split360Images.exe in PATH or infer ALICEVISION_ROOT.
    echo Please ensure the AliceVision bin folder is in PATH and/or set ALICEVISION_ROOT.
    pause
    exit /b 1
)

:AV_FOUND

rem If ALICEVISION_BIN is still not set (e.g. ALICEVISION_ROOT came from env),
rem derive it from ALICEVISION_ROOT.
if not defined ALICEVISION_BIN (
    set "ALICEVISION_BIN=%ALICEVISION_ROOT%\bin"
)

rem Make sure AliceVision bin is in PATH for any other tools
set "PATH=%ALICEVISION_BIN%;%PATH%"

echo Using ALICEVISION_ROOT=%ALICEVISION_ROOT%
echo Using ALICEVISION_BIN=%ALICEVISION_BIN%

rem -------------------------------------------------------------------
rem Input / temp / output folders relative to script folder
rem -------------------------------------------------------------------
set "INPUT_DIR=%BASE_DIR%frames"
set "TMP_DIR=%INPUT_DIR%\splits_tmp"
set "FLAT_DIR=%INPUT_DIR%\splits_flat"
set "OUTPUT_DIR=%INPUT_DIR%\splits_final"

if not exist "%TMP_DIR%" mkdir "%TMP_DIR%"
if not exist "%FLAT_DIR%" mkdir "%FLAT_DIR%"
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

REM SPLIT ALL IMAGES IN PARALLEL
for %%F in ("%INPUT_DIR%\*.jpeg") do (
    set "FRAME_SUBDIR=%TMP_DIR%\%%~nF"
    if not exist "!FRAME_SUBDIR!" mkdir "!FRAME_SUBDIR!"
    start "" /B "%ALICEVISION_BIN%\aliceVision_split360Images.exe" ^
        --input "%%F" ^
        --output "!FRAME_SUBDIR!" ^
        --splitMode equirectangular ^
        --equirectangularNbSplits 8 ^
        --equirectangularSplitResolution %SPLIT_RES% ^
        --fov %FOV% ^
        --outSfMData "!FRAME_SUBDIR!\%%~nF.sfm"
)

REM WAIT FOR SPLITS TO FINISH
timeout /t 180

REM MOVE AND RENAME
for /d %%F in ("%TMP_DIR%\*") do (
    for /L %%N in (0,1,7) do (
        for %%I in ("%%F\rig\%%N\*.jpeg") do (
            set "FRAMENAME=%%~nF"
            set "SPLITNUM=%%N"
            setlocal enabledelayedexpansion
            copy "%%I" "%FLAT_DIR%\image_!FRAMENAME!_!SPLITNUM!.jpeg"
            endlocal
        )
    )
)

REM CORRECT GAMMA TO MATCH SOURCE (Default to 2.2)
for %%S in ("%INPUT_DIR%\*.jpeg") do (
    set "SRCFRAME=%%~nS"
    REM Find all splits for this frame and match gamma
    for %%J in ("%FLAT_DIR%\image_!SRCFRAME!_*.jpeg") do (
        magick "%%J" -gamma 2.2 "%OUTPUT_DIR%\%%~nxJ"
    )
)

REM OPTIONAL CLEANUP
REM rmdir /s /q "%TMP_DIR%"
REM rmdir /s /q "%FLAT_DIR%"

echo All splits gamma corrected to match source images.
pause
