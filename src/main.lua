-- Author: AntCant
-- Date: 06-11-2025
-- Version: 1.0.0.0
-- main.lua

---Main handler table for YieldTracker mod.
---Controls mod initialization, update cycle, and cleanup.
MainHandler = {
    dir = g_currentModDirectory,  -- Directory where the mod is located
    enabled = true                -- Whether the mod is active
}

-- Load core mod logic and GUI scripts
source(MainHandler.dir .. "scripts/yieldTracker.lua")
source(MainHandler.dir .. "scripts/gui/yieldTrackerGUI.lua")

---Called once when the map is loaded.
---Disables the mod in multiplayer mode; otherwise, initializes tracking systems.
function MainHandler:loadMap(name)
    if g_currentMission and g_currentMission.missionDynamicInfo and g_currentMission.missionDynamicInfo.isMultiplayer then
        print("[YieldTracker] Multiplayer detected. Disabling mod.")
        self.enabled = false
        g_currentMission:showBlinkingWarning("YieldTracker disabled in multiplayer mode.", 5000)
        return
    end

    YieldTracker:setup()       -- Initialize yield tracking logic
    YieldTrackerGUI:setup()    -- Initialize the GUI components
end

---Called when the map is being deleted/unloaded.
---Clears tracked data so nothing carries over into another savegame.
function MainHandler:deleteMap()
    YieldTracker:shutdown()
end

-- Register MainHandler to receive game loop events (loadMap, update, etc.)
addModEventListener(MainHandler)