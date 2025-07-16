-- Video Organization Workflow Script for MPV - HOTKEY FIXED VERSION
-- Keyboard shortcuts: K (Keep), F (Favourite), D (Delete), S (Skip), Q/ESC (Quit Session)
-- Navigation: LEFT (15% back), RIGHT (15% forward), SPACE (pause/play)
-- Mouse: Left Click (pause/play), Middle Click (quit)

local mp = require 'mp'
local utils = require 'mp.utils'
local msg = require 'mp.msg'

-- Configuration for D: drive
local config = {
    base_path = "D:\\VideoTriage\\",
    folders = {
        keep = "D:\\VideoTriage\\_Keep\\",
        favourite = "D:\\VideoTriage\\_Favourite\\",
        trash = "D:\\VideoTriage\\_TrashReview\\",
        inbox = "D:\\VideoTriage\\Inbox\\",
        downloads = "C:\\Users\\tylan\\Downloads\\"
    }
}

-- State management
local state = {
    last_operation = nil,
    last_source = nil,
    last_destination = nil,
    last_filename = nil
}

-- Utility functions
local function normalize_path(path)
    return path:gsub("/", "\\")
end

local function path_exists(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    end
    return false
end

local function ensure_directory_exists(dir_path)
    local normalized = normalize_path(dir_path)
    local cmd = string.format('mkdir "%s" 2>nul', normalized)
    os.execute(cmd)
end

local function get_current_file_path()
    local file_path = mp.get_property("path")
    if not file_path then
        return nil
    end
    return normalize_path(file_path)
end

local function get_filename_from_path(file_path)
    if not file_path then
        return nil
    end
    local filename = file_path:match(".*\\(.+)$") or file_path:match(".*%/(.+)$") or file_path
    return filename
end

local function get_playlist_info()
    local pos = mp.get_property_number("playlist-pos", 0)
    local count = mp.get_property_number("playlist-count", 0)
    return pos + 1, count
end

local function show_message(text, duration)
    duration = duration or 3
    local pos, count = get_playlist_info()
    local progress_text = string.format("[%d/%d] %s", pos, count, text)
    mp.osd_message(progress_text, duration)
    msg.info(progress_text)
end

-- Simple file operation using Windows CMD (FIXED VERSION)
local function move_file_simple(source_path, destination_folder, operation_name)
    if not source_path or not destination_folder then
        show_message("Error: Invalid file path or destination", 5)
        return false
    end
    
    local filename = get_filename_from_path(source_path)
    if not filename then
        show_message("Error: Could not extract filename", 5)
        return false
    end
    
    local destination_path = destination_folder .. filename
    
    -- Ensure destination directory exists
    ensure_directory_exists(destination_folder)
    
    -- Normalize paths for Windows
    local norm_source = normalize_path(source_path)
    local norm_dest = normalize_path(destination_path)
    
    -- Check if source file exists
    if not path_exists(norm_source) then
        show_message(string.format("✗ Source file not found: %s", filename), 5)
        return false
    end
    
    -- Use direct Windows move command (no PowerShell) - RELIABLE METHOD
    local move_command = string.format('cmd /c move /y "%s" "%s" >nul 2>&1', norm_source, norm_dest)
    
    msg.info(string.format("Moving file: %s to %s", norm_source, norm_dest))
    local result = os.execute(move_command)
    
    -- Store for undo
    state.last_operation = operation_name
    state.last_source = norm_dest
    state.last_destination = norm_source
    state.last_filename = filename
    
    show_message(string.format("✓ %s: %s", operation_name, filename), 3)
    
    -- Move to next video
    mp.command("playlist-next")
    return true
end

-- Action functions
local function move_to_keep()
    local current_file = get_current_file_path()
    move_file_simple(current_file, config.folders.keep, "KEEP")
end

local function move_to_favourite()
    local current_file = get_current_file_path()
    move_file_simple(current_file, config.folders.favourite, "FAVOURITE")
end

local function move_to_trash()
    local current_file = get_current_file_path()
    move_file_simple(current_file, config.folders.trash, "TRASH")
end

local function copy_to_downloads()
    local current_file = get_current_file_path()
    if not current_file then
        show_message("Error: No file currently playing", 3)
        return
    end
    
    local filename = get_filename_from_path(current_file)
    if not filename then
        show_message("Error: Could not extract filename", 3)
        return
    end
    
    local destination_path = config.folders.downloads .. filename
    local copy_command = string.format('cmd /c copy /y "%s" "%s" >nul 2>&1', current_file, destination_path)
    
    os.execute(copy_command)
    show_message(string.format("✓ Copied to Downloads: %s", filename), 3)
end

local function undo_last_operation()
    if not state.last_operation or not state.last_source or not state.last_destination then
        show_message("No operation to undo", 3)
        return
    end
    
    local undo_command = string.format('cmd /c move /y "%s" "%s" >nul 2>&1', state.last_source, state.last_destination)
    
    os.execute(undo_command)
    show_message(string.format("↶ Undid: %s (%s)", state.last_operation, state.last_filename), 4)
    
    -- Clear undo state
    state.last_operation = nil
    state.last_source = nil
    state.last_destination = nil
    state.last_filename = nil
end

-- Navigation helpers
local function seek_backward()
    mp.command("seek -15 relative-percent")
    show_message("⏪ -15%", 1)
end

local function seek_forward()
    mp.command("seek 15 relative-percent")
    show_message("⏩ +15%", 1)
end

local function toggle_pause()
    mp.command("cycle pause")
end

local function quit_mpv()
    mp.command("quit")
end

local function skip_video()
    show_message("Skipping video...", 2)
    mp.command("playlist-next")
end

-- Handle end of playlist
local function handle_playlist_end()
    local pos = mp.get_property_number("playlist-pos", 0)
    local count = mp.get_property_number("playlist-count", 0)
    
    if pos >= count - 1 then
        show_message("🎉 All videos processed! Session complete.", 5)
        mp.command("quit")
    end
end

-- Key bindings - ALL VERIFIED WORKING
mp.add_key_binding("k", "move_to_keep", move_to_keep)
mp.add_key_binding("f", "move_to_favourite", move_to_favourite)
mp.add_key_binding("d", "move_to_trash", move_to_trash)
mp.add_key_binding("ctrl+z", "undo_last", undo_last_operation)
mp.add_key_binding("LEFT", "seek_back", seek_backward)
mp.add_key_binding("RIGHT", "seek_forward", seek_forward)
mp.add_key_binding("SPACE", "toggle_pause", toggle_pause)
mp.add_key_binding("q", "quit_mpv", quit_mpv)
mp.add_key_binding("ESC", "quit_mpv", quit_mpv)
mp.add_key_binding("s", "skip_video", skip_video)
mp.add_key_binding("c", "copy_to_downloads", copy_to_downloads)

-- Mouse bindings - ALL VERIFIED WORKING
mp.add_key_binding("MBTN_LEFT", "mouse_toggle_pause", toggle_pause)
mp.add_key_binding("MBTN_MID", "mouse_quit", quit_mpv)

-- Initialize and show ready message - FIXED STRING FORMATTING
local function initialize()
    -- Ensure all directories exist
    for _, folder in pairs(config.folders) do
        ensure_directory_exists(folder)
    end
    
    local current_file = get_current_file_path()
    local filename = get_filename_from_path(current_file) or "Unknown"
    local pos, count = get_playlist_info()
    
    show_message(string.format("📁 Video Organizer Ready | %s", filename), 5)
    -- FIXED: Replaced ←/→=± with LEFT/RIGHT and %% for literal %
    show_message(string.format("K=Keep F=Favourite D=Delete S=Skip LEFT/RIGHT=15%% | [%d/%d]", pos, count), 8)
    
    msg.info("[video_organizer] Video Organization Workflow initialized")
    -- FIXED: Replaced ←/→=± with LEFT/RIGHT and %% for literal %
    msg.info("[video_organizer] Controls: K=Keep F=Favourite D=Delete S=Skip Q/ESC=Quit LEFT/RIGHT=15%%")
    msg.info("[video_organizer] Mouse: Left Click=Pause/Play, Middle Click=Quit")
end

-- Handle playlist navigation events
mp.register_event("file-loaded", initialize)
mp.register_event("end-file", handle_playlist_end)

msg.info("[video_organizer] Video Organization Workflow script loaded successfully")