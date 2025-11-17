@echo off
setlocal enabledelayedexpansion

:: =======================================================
:: 1. SCRIPT BASE DIRECTORY
:: =======================================================
rem Folder where this .bat resides (with trailing backslash)
set "BASE_DIR=%~dp0"
echo Script base folder: "%BASE_DIR%"

:: =======================================================
:: 2. ALICEVISION DISCOVERY (ENV/PATH)
:: =======================================================

rem If ALICEVISION_ROOT is not defined in the environment, try to infer it
rem from aliceVision_split360Images.exe found on PATH.
if not defined ALICEVISION_ROOT (
    echo ALICEVISION_ROOT not defined, trying to infer from aliceVision_split360Images.exe...

    for /f "delims=" %%I in ('where aliceVision_split360Images.exe 2^>nul') do (
        rem %%I = full path to aliceVision_split360Images.exe
        set "ALICEVISION_BIN=%%~dpI"
        rem ALICEVISION_ROOT is the parent of the bin folder
        for %%D in ("%%~dpI..") do set "ALICEVISION_ROOT=%%~fD"
        goto :AV_FOUND
    )
)

:AV_FOUND

if not defined ALICEVISION_ROOT (
    echo ERROR: ALICEVISION_ROOT is not defined and could not be inferred.
    echo AliceVision tools may fail (e.g. OCIO config / sensor DB not found).
    echo Please set ALICEVISION_ROOT to your AliceVision install folder.
    pause
    exit /b 1
)

if not defined ALICEVISION_BIN (
    set "ALICEVISION_BIN=%ALICEVISION_ROOT%\bin"
)

rem Ensure AliceVision bin is in PATH
set "PATH=%ALICEVISION_BIN%;%PATH%"

echo Using ALICEVISION_ROOT=%ALICEVISION_ROOT%
echo Using ALICEVISION_BIN=%ALICEVISION_BIN%

:: =======================================================
:: 3. PROJECT FOLDERS (RELATIVE TO SCRIPT)
:: =======================================================

set "INPUT_DIR=%BASE_DIR%frames"
set "TMP_DIR=%INPUT_DIR%\splits_tmp"
set "FLAT_DIR=%INPUT_DIR%\splits_flat"
set "OUTPUT_DIR=%INPUT_DIR%\splits_final"

if not exist "%INPUT_DIR%" (
    echo ERROR: INPUT_DIR does not exist: %INPUT_DIR%
    echo Put your source .jpeg frames into this folder.
    pause
    exit /b 1
)

if not exist "%TMP_DIR%" mkdir "%TMP_DIR%"
if not exist "%FLAT_DIR%" mkdir "%FLAT_DIR%"
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

:: =======================================================
:: 4. SPLIT 360 IMAGES TO 1920x1920 FACES
:: =======================================================

echo =======================================================
echo  Splitting 360 images from:
echo    %INPUT_DIR%
echo  Temporary splits in:
echo    %TMP_DIR%
echo =======================================================

for %%F in ("%INPUT_DIR%\*.jpeg") do (
    set "FRAME_SUBDIR=%TMP_DIR%\%%~nF"
    if not exist "!FRAME_SUBDIR!" mkdir "!FRAME_SUBDIR!"
    start "" /B "%ALICEVISION_BIN%\aliceVision_split360Images.exe" ^
        --input "%%F" ^
        --output "!FRAME_SUBDIR!" ^
        --splitMode equirectangular ^
        --equirectangularNbSplits 6 ^
        --equirectangularSplitResolution 1920 ^
        --fov 90.0 ^
        --outSfMData "!FRAME_SUBDIR!\%%~nF.sfm"
)

rem Simple wait for all background splits to finish
echo Waiting for split jobs to complete...
timeout /t 180

:: =======================================================
:: 5. FLATTEN AND RENAME SPLITS
:: =======================================================

echo =======================================================
echo  Collecting and renaming splits into:
echo    %FLAT_DIR%
echo =======================================================

for /d %%F in ("%TMP_DIR%\*") do (
    for /L %%N in (0,1,7) do (
        for %%I in ("%%F\rig\%%N\*.jpeg") do (
            set "FRAMENAME=%%~nF"
            set "SPLITNUM=%%N"
            setlocal enabledelayedexpansion
            copy "%%I" "%FLAT_DIR%\image_!FRAMENAME!_!SPLITNUM!.jpeg" >nul
            endlocal
        )
    )
)

:: =======================================================
:: 6. GAMMA CORRECTION (IMAGEMAGICK)
:: =======================================================

echo =======================================================
echo  Gamma correcting splits into:
echo    %OUTPUT_DIR%
echo  (Requires ImageMagick 'magick' in PATH)
echo =======================================================

for %%S in ("%INPUT_DIR%\*.jpeg") do (
    set "SRCFRAME=%%~nS"
    for %%J in ("%FLAT_DIR%\image_!SRCFRAME!_*.jpeg") do (
        magick "%%J" -gamma 2.2 "%OUTPUT_DIR%\%%~nxJ"
    )
)

:: =======================================================
:: 7. OPTIONAL CLEANUP
:: =======================================================

rem Uncomment if you want to remove intermediates automatically:
rem rmdir /s /q "%TMP_DIR%"
rem rmdir /s /q "%FLAT_DIR%"

echo.
echo All splits created at 1920x1920 and gamma corrected to match source images.
echo Output folder: %OUTPUT_DIR%
pause
