@echo off
setlocal enabledelayedexpansion

:: =======================================================
:: --- 1. USER CONFIGURATION ---
:: =======================================================
:: Use ffmpeg from PATH instead of hardcoded location
set "FFMPEG=ffmpeg"
set "ALICEVISION_ROOT=D:\Video360To3DGS_vers1.3\aliceVision"
set "FRAME_RATE=1/2"

:: =======================================================
:: --- 2. SCRIPT-DERIVED PATHS ---
:: =======================================================
set "BASE_PROJECT_DIR=%~dp0"
set "PATH=%ALICEVISION_ROOT%\bin;%PATH%"
set "ALICEVISION_BIN=%ALICEVISION_ROOT%\bin"
set "VIDEO_FILE=%BASE_PROJECT_DIR%1.mp4"
set "INPUT_FRAMES_DIR=%BASE_PROJECT_DIR%frames"
set "TMP_DIR=%INPUT_FRAMES_DIR%\splits_tmp"
set "FLAT_DIR=%INPUT_FRAMES_DIR%\splits_flat"
set "OUTPUT_DIR=%INPUT_FRAMES_DIR%\splits_final"

:: =======================================================
:: --- STEP 0: CHECK FFMPEG IN PATH ---
:: =======================================================
echo =======================================================
echo  Checking for ffmpeg in PATH...
echo =======================================================

where /q %FFMPEG%
if errorlevel 1 (
    echo ERROR: ffmpeg not found in PATH.
    echo Make sure ffmpeg.exe is installed and its bin folder is added to PATH.
    echo Example: C:\ffmpeg\bin in system PATH.
    pause
    goto :eof
)

:: =======================================================
:: --- STEP 1: EXTRACT FRAMES (FFMPEG) ---
:: =======================================================
echo =======================================================
echo  Step 1: Extracting frames from 1.mp4...
echo  Source: %VIDEO_FILE%
echo =======================================================

:: --- CHECK: Does the video file exist? ---
if not exist "%VIDEO_FILE%" (
    echo ERROR: 1.mp4 not found in script directory!
    echo Checked path: %VIDEO_FILE%
    pause
    goto :eof
)

if not exist "%INPUT_FRAMES_DIR%" md "%INPUT_FRAMES_DIR%"

echo Running FFmpeg...
%FFMPEG% -i "%VIDEO_FILE%" -vf "fps=%FRAME_RATE%" -q:v 2 "%INPUT_FRAMES_DIR%\frame_%%04d.jpeg"

:: --- CHECK: Did FFmpeg create any frames? ---
if not exist "%INPUT_FRAMES_DIR%\frame_0001.jpeg" (
    echo.
    echo ******************************************************
    echo  ERROR: STEP 1 FAILED!
    echo  No frames (e.g., frame_0001.jpeg) were created.
    echo  This means FFmpeg failed. Check for errors above.
    echo ******************************************************
    pause
    goto :eof
)

echo Done extracting frames.
echo Script finished successfully.
pause
