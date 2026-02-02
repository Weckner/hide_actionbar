--[[
    Hide Actionbar
    Toggle actionbar visibility with a keybind or slash command
]]

-- Bar definitions with frame names
-- MainActionBar (11.0+) / MainMenuBar (legacy) handled via fallback
local bars = {
    { id = "main",        frame = "MainActionBar",      fallback = "MainMenuBar", name = "Main" },
    { id = "bottomleft",  frame = "MultiBarBottomLeft", name = "Bar 1" },
    { id = "bottomright", frame = "MultiBarBottomRight", name = "Bar 2" },
    { id = "right",       frame = "MultiBarRight",      name = "Bar 3" },
    { id = "left",        frame = "MultiBarLeft",       name = "Bar 4" },
    { id = "bar5",        frame = "MultiBar5",          name = "Bar 5" },
    { id = "bar6",        frame = "MultiBar6",          name = "Bar 6" },
    { id = "bar7",        frame = "MultiBar7",          name = "Bar 7" },
    { id = "stance",      frame = "StanceBar",          name = "Stance Bar" },
    { id = "pet",         frame = "PetActionBar",       name = "Pet Bar" },
    { id = "micro",       frame = "MicroMenu",          name = "Micro Menu" },
    { id = "bags",        frame = "BagsBar",            name = "Bags Bar" },
}

-- Default settings
local defaults = {
    hiddenAlpha = 0,
    isHidden = false,
    enabledBars = {},
}

-- Build default enabledBars from bars table
for _, bar in ipairs(bars) do
    defaults.enabledBars[bar.id] = true
end

-- Get frame with fallback support for version differences
local function GetBarFrame(bar)
    local frame = _G[bar.frame]
    if not frame and bar.fallback then
        frame = _G[bar.fallback]
    end
    return frame
end

-- Initialize saved variables
local function InitDB()
    HideActionbarDB = HideActionbarDB or {}
    
    if HideActionbarDB.hiddenAlpha == nil then
        HideActionbarDB.hiddenAlpha = defaults.hiddenAlpha
    end
    if HideActionbarDB.isHidden == nil then
        HideActionbarDB.isHidden = defaults.isHidden
    end
    
    HideActionbarDB.enabledBars = HideActionbarDB.enabledBars or {}
    
    -- Ensure all bars have a setting (handles new bars added in updates)
    for _, bar in ipairs(bars) do
        if HideActionbarDB.enabledBars[bar.id] == nil then
            HideActionbarDB.enabledBars[bar.id] = defaults.enabledBars[bar.id]
        end
    end
end

-- Set alpha on enabled bars
local function SetBarsAlpha(alpha, debug)
    for _, bar in ipairs(bars) do
        if HideActionbarDB.enabledBars[bar.id] then
            local frame = GetBarFrame(bar)
            if frame then
                frame:SetAlpha(alpha)
                if debug then
                    local frameName = _G[bar.frame] and bar.frame or bar.fallback
                    print("  " .. frameName .. ": OK (alpha=" .. alpha .. ")")
                end
            elseif debug then
                local names = bar.fallback and (bar.frame .. "/" .. bar.fallback) or bar.frame
                print("  " .. names .. ": NOT FOUND")
            end
        end
    end
end

-- Toggle visibility (called by keybind)
function HideActionbar_Toggle()
    HideActionbarDB.isHidden = not HideActionbarDB.isHidden
    SetBarsAlpha(HideActionbarDB.isHidden and HideActionbarDB.hiddenAlpha or 1)
end

-- Print helper
local function Print(msg)
    print("|cFF00FF00Hide Actionbar:|r " .. msg)
end

-- Slash commands
SLASH_HIDEACTIONBAR1 = "/hideactionbar"
SLASH_HIDEACTIONBAR2 = "/hab"

SlashCmdList["HIDEACTIONBAR"] = function(msg)
    local cmd, arg = msg:match("^(%S+)%s*(.*)$")
    cmd = cmd and cmd:lower() or msg:lower()

    if cmd == "toggle" or cmd == "" then
        HideActionbar_Toggle()

    elseif cmd == "opacity" then
        local val = tonumber(arg)
        if val and val >= 0 and val <= 1 then
            HideActionbarDB.hiddenAlpha = val
            Print("Hidden opacity set to " .. val)
            if HideActionbarDB.isHidden then
                SetBarsAlpha(val)
            end
        else
            Print("Usage: /hab opacity <0-1>")
        end

    elseif cmd == "enable" then
        for _, bar in ipairs(bars) do
            if bar.id == arg:lower() then
                HideActionbarDB.enabledBars[bar.id] = true
                Print(bar.name .. " enabled")
                return
            end
        end
        Print("Unknown bar: " .. arg)

    elseif cmd == "disable" then
        for _, bar in ipairs(bars) do
            if bar.id == arg:lower() then
                HideActionbarDB.enabledBars[bar.id] = false
                local frame = GetBarFrame(bar)
                if frame then frame:SetAlpha(1) end
                Print(bar.name .. " disabled")
                return
            end
        end
        Print("Unknown bar: " .. arg)

    elseif cmd == "list" then
        Print("Bars (enabled = will be hidden):")
        for _, bar in ipairs(bars) do
            local status = HideActionbarDB.enabledBars[bar.id] and "|cFF00FF00ON|r" or "|cFFFF0000OFF|r"
            print("  " .. bar.id .. " - " .. bar.name .. " [" .. status .. "]")
        end

    elseif cmd == "debug" then
        Print("Checking frames:")
        SetBarsAlpha(HideActionbarDB.isHidden and HideActionbarDB.hiddenAlpha or 1, true)

    else
        Print("Commands:")
        print("  /hab toggle - Toggle visibility")
        print("  /hab opacity <0-1> - Set hidden opacity")
        print("  /hab list - Show all bars")
        print("  /hab enable <bar> - Enable bar for hiding")
        print("  /hab disable <bar> - Exclude bar from hiding")
        print("  /hab debug - Check frame status")
    end
end

-- Event handling
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    InitDB()
    if HideActionbarDB.isHidden then
        SetBarsAlpha(HideActionbarDB.hiddenAlpha)
    end
end)

-- Keybind localization
BINDING_HEADER_HIDE_ACTIONBAR = "Hide Actionbar"
BINDING_NAME_HIDE_ACTIONBAR_TOGGLE = "Toggle Visibility"
