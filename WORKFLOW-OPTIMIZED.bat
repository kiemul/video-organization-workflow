@echo off
setlocal enabledelayedexpansion
REM OPTIMIZED Video Organization Workflow - Terminal Flash Fix
REM This is the RECOMMENDED way to run the workflow efficiently

set MPV_PATH=C:\Users\tylan\Downloads\Compressed\mpv-x86_64-v3-20250714-git-bd21180\mpv.exe
set CONFIG_DIR=D:\video-organization-workflow\mpv-config
set WORKING_DIR=D:\VideoTriage\Inbox

title OPTIMIZED Video Organization Workflow

REM Check if MPV exists
if not exist "%MPV_PATH%" (
    echo ERROR: MPV not found at %MPV_PATH%
    pause
    exit /b 1
)

REM Change to working directory
if exist "%WORKING_DIR%" (
    cd /d "%WORKING_DIR%"
) else (
    echo ERROR: Working directory not found: %WORKING_DIR%
    pause
    exit /b 1
)

echo ================================================
echo OPTIMIZED VIDEO ORGANIZATION WORKFLOW
echo ================================================
echo Working Directory: %WORKING_DIR%
echo.

REM Count total video files
set count=0
for %%f in (*.mp4 *.mkv *.avi *.mov *.wmv *.m4v *.ts *.flv *.webm) do (
    set /a count+=1
)

if %count%==0 (
    echo ================================================
    echo NO VIDEOS TO PROCESS
    echo ================================================
    echo No video files found in the directory!
    echo.
    echo Place video files in: %WORKING_DIR%
    pause
    exit /b 0
)

echo Found %count% videos to organize
echo.
echo ================================================
echo PLAYLIST CONTROLS - NO MORE TERMINAL FLASHING!
echo ================================================
echo K = Keep video (move to _Keep folder)
echo F = Favourite video (move to _Favourite folder)  
echo D = Delete video (move to _TrashReview folder)
echo S = Skip video (go to next without organizing)
echo C = Copy to Downloads (keeps original)
echo Ctrl+Z = Undo last operation
echo.
echo Q/ESC = Quit entire session
echo LEFT/RIGHT = Seek backward/forward 15%%
echo SPACE = Pause/Play
echo.
echo EFFICIENCY IMPROVEMENTS:
echo - Instant video switching (no terminal flashing)
echo - All videos loaded in playlist at once
echo - Hotkeys work immediately
echo - No delay between videos
echo ================================================
echo.
echo Starting MPV with ALL videos in playlist...
echo Press any key to continue...
pause > nul

REM Launch MPV with ALL video files in playlist - OPTIMIZED APPROACH
"%MPV_PATH%" --config-dir="%CONFIG_DIR%" --really-quiet --msg-level=all=no --playlist-start=0 *.mp4 *.mkv *.avi *.mov *.wmv *.m4v *.ts *.flv *.webm

echo.
echo ================================================
echo SESSION COMPLETE
echo ================================================
echo All videos have been processed or session ended.
echo Check the organized folders for your sorted videos.
echo.
echo Statistics:
echo - Keep: %WORKING_DIR%\..\\_Keep
echo - Favourite: %WORKING_DIR%\..\\_Favourite  
echo - TrashReview: %WORKING_DIR%\..\\_TrashReview
echo.
pause
exit /b 0