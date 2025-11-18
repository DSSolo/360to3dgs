1. download ImageMagick and install it make the add to env path

2.download ffmpeg and add the bin folder to the env path

3.downalod alice vision and add the bin folder to the env path

4.download colmap+glomap and add the bin folder to the env path

5.put the 2 files (1.portableframeextractor.bat  ,  2.split 360.bat) to the folder with the mp4  ** in the first script you can change how many frames does the script extract. 

6.change the name of the mp4 to 1.mp4

7.run scripts one by one 

8.run the 3dgs 


In the portablextractor you can change  how many frames does the script extract.

@echo off
setlocal enabledelayedexpansion

:: =======================================================
:: --- 1. USER CONFIGURATION ---
:: =======================================================
:: Use ffmpeg from PATH instead of hardcoded location
set "FFMPEG=ffmpeg"
set "ALICEVISION_ROOT=D:\Video360To3DGS_vers1.3\aliceVision"
set "FRAME_RATE=1/2"  ( one frame every 2 seconds)


And in the second script you can change the number of splits , the resolution + fov

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



