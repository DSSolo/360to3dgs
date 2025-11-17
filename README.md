1. download ImageMagick and install it make the add to env path

2.download ffmpeg and add the bin folder to the env path

3.downalod alice vision and add the bin folder to the env path

4.put the 2 files (1.portableframeextractor.bat  ,  2.split 360.bat) to the folder with the mp4  ** in the first script you can change how many frames does the script extract. 

5.change the name of the mp4 to 1.mp4

6.run scripts one by one 

7. now you can run the realityscan reconstruction 


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


and in the secons script you can change the number of splits , the resolution + fov

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
        --equirectangularNbSplits 6 ^           ****************** ( number of splits)
        --equirectangularSplitResolution 1920 ^  ****************** (resolution)
        --fov 90.0 ^                             *******************(fov)
        --outSfMData "!FRAME_SUBDIR!\%%~nF.sfm"





