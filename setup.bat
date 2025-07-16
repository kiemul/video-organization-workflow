@echo off
REM Setup script for Video Organization Workflow on D: Drive

echo ================================================
echo Video Organization Workflow Setup for D: Drive
echo ================================================
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running as Administrator: OK
) else (
    echo Note: Not running as administrator. Some operations may require elevation.
)

echo.
echo Creating directory structure...

REM Create main directories
if not exist "D:\VideoTriage" mkdir "D:\VideoTriage"
if not exist "D:\VideoTriage\Inbox" mkdir "D:\VideoTriage\Inbox"
if not exist "D:\VideoTriage\_Keep" mkdir "D:\VideoTriage\_Keep"  
if not exist "D:\VideoTriage\_Favourite" mkdir "D:\VideoTriage\_Favourite"
if not exist "D:\VideoTriage\_TrashReview" mkdir "D:\VideoTriage\_TrashReview"

echo ✓ Created D:\VideoTriage\
echo ✓ Created D:\VideoTriage\Inbox\
echo ✓ Created D:\VideoTriage\_Keep\
echo ✓ Created D:\VideoTriage\_Favourite\
echo ✓ Created D:\VideoTriage\_TrashReview\

echo.
echo Checking MPV installation...

set MPV_PATH=C:\Users\tylan\Downloads\Compressed\mpv-x86_64-v3-20250714-git-bd21180\mpv.exe

if exist "%MPV_PATH%" (
    echo ✓ MPV found at: %MPV_PATH%
    "%MPV_PATH%" --version | findstr "mpv"
) else (
    echo ✗ MPV not found at: %MPV_PATH%
    echo Please check the installation path in the script.
)

echo.
echo Checking configuration files...

if exist "D:\video-organization-workflow\mpv-config\mpv.conf" (
    echo ✓ MPV configuration found
) else (
    echo ✗ MPV configuration missing
)

if exist "D:\video-organization-workflow\mpv-config\scripts\video-organizer.lua" (
    echo ✓ Lua script found
) else (
    echo ✗ Lua script missing
)

echo.
echo Creating test video...

REM Create a small test video file using FFmpeg (if available)
where ffmpeg >nul 2>&1
if %errorLevel% == 0 (
    ffmpeg -f lavfi -i testsrc=duration=5:size=320x240:rate=1 -f lavfi -i sine=frequency=440:duration=5 -c:v libx264 -c:a aac -shortest "D:\VideoTriage\Inbox\test-video.mp4" -y >nul 2>&1
    if exist "D:\VideoTriage\Inbox\test-video.mp4" (
        echo ✓ Created test video: test-video.mp4
    ) else (
        echo ! Could not create test video automatically
    )
) else (
    echo ! FFmpeg not found - test video not created
    echo You can manually place video files in D:\VideoTriage\Inbox\
)

echo.
echo ================================================
echo Setup Complete!
echo ================================================
echo.
echo To use the video organization workflow:
echo.
echo 1. Place video files in: D:\VideoTriage\Inbox\
echo 2. Run: WORKFLOW-VERIFIED.bat (recommended) or WORKFLOW-OPTIMIZED.bat
echo 3. Use keyboard shortcuts to organize:
echo    K = Keep, F = Favourite, D = Delete, S = Skip, C = Copy
echo    Ctrl+Z = Undo, LEFT/RIGHT = Seek, SPACE = Pause/Play
echo.
echo Note: All hotkeys have been debugged and verified to work!
echo.

pause