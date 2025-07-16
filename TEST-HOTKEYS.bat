@echo off
setlocal enabledelayedexpansion
REM Testing Video Organization Workflow - Debug Version

set MPV_PATH=C:\Users\tylan\Downloads\Compressed\mpv-x86_64-v3-20250714-git-bd21180\mpv.exe
set CONFIG_DIR=D:\video-organization-workflow\mpv-config
set WORKING_DIR=D:\VideoTriage\Inbox

title TESTING Video Organization Workflow

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
echo TESTING VIDEO ORGANIZATION WORKFLOW
echo ================================================
echo Working Directory: %WORKING_DIR%
echo Config Directory: %CONFIG_DIR%
echo.

REM Count total video files
set count=0
for %%f in (*.mp4 *.mkv *.avi *.mov *.wmv *.m4v *.ts *.flv *.webm) do (
    set /a count+=1
)

echo Found %count% videos to organize
echo.

REM Test with just one video file for debugging
echo ================================================
echo TESTING WITH SINGLE VIDEO FILE
echo ================================================
echo Controls:
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
echo Press any key to start test...
pause > nul

REM Launch MPV with just the first video for testing
for %%f in (*.mp4 *.mkv *.avi *.mov *.wmv *.m4v *.ts *.flv *.webm) do (
    echo Testing with file: %%f
    "%MPV_PATH%" --config-dir="%CONFIG_DIR%" --msg-level=all=info --pause "%%f"
    goto :done
)

:done
echo.
echo ================================================
echo TEST COMPLETE
echo ================================================
echo Check if hotkeys worked correctly.
echo.
pause
exit /b 0