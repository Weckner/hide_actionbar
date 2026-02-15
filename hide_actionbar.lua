--[[
    Hide Actionbar
    Toggle actionbar visibility with a keybind or slash command
]]

local addonName = ...

-- Bar definitions with frame names
-- MainActionBar (11.0+) / MainMenuBar (legacy) handled via fallback
local bars = {
    { id = "main",        frame = "MainActionBar",      fallback = "MainMenuBar", name = "Main Action Bar" },
    { id = "bottomleft",  frame = "MultiBarBottomLeft",  name = "Bar 1" },
    { id = "bottomright", frame = "MultiBarBottomRight", name = "Bar 2" },
    { id = "right",       frame = "MultiBarRight",       name = "Bar 3" },
    { id = "left",        frame = "MultiBarLeft",        name = "Bar 4" },
    { id = "bar5",        frame = "MultiBar5",           name = "Bar 5" },
    { id = "bar6",        frame = "MultiBar6",           name = "Bar 6" },
    { id = "bar7",        frame = "MultiBar7",           name = "Bar 7" },
    { id = "stance",      frame = "StanceBar",           name = "Stance Bar" },
    { id = "pet",         frame = "PetActionBar",        name = "Pet Bar" },
    { id = "micro",       frame = "MicroMenu",           name = "Micro Menu" },
    { id = "bags",        frame = "BagsBar",             name = "Bags Bar" },
}

-- Default settings
local defaults = {
    hiddenAlpha = 0,
    isHidden = false,
    enabledBars = {},
}

for _, bar in ipairs(bars) do
    defaults.enabledBars[bar.id] = true
end

-----------------------------------------------------------------------
-- Core functions
-----------------------------------------------------------------------

local function GetBarFrame(bar)
    local frame = _G[bar.frame]
    if not frame and bar.fallback then
        frame = _G[bar.fallback]
    end
    return frame
end

local function SetBarsAlpha(alpha)
    for _, bar in ipairs(bars) do
        if HideActionbarDB.enabledBars[bar.id] then
            local frame = GetBarFrame(bar)
            if frame then
                frame:SetAlpha(alpha)
            end
        end
    end
end

local function ApplyState()
    SetBarsAlpha(HideActionbarDB.isHidden and HideActionbarDB.hiddenAlpha or 1)
end

function HideActionbar_Toggle()
    HideActionbarDB.isHidden = not HideActionbarDB.isHidden
    ApplyState()
end

-----------------------------------------------------------------------
-- Saved variables
-----------------------------------------------------------------------

local function InitDB()
    HideActionbarDB = HideActionbarDB or {}

    if HideActionbarDB.hiddenAlpha == nil then
        HideActionbarDB.hiddenAlpha = defaults.hiddenAlpha
    end
    if HideActionbarDB.isHidden == nil then
        HideActionbarDB.isHidden = defaults.isHidden
    end

    HideActionbarDB.enabledBars = HideActionbarDB.enabledBars or {}

    for _, bar in ipairs(bars) do
        if HideActionbarDB.enabledBars[bar.id] == nil then
            HideActionbarDB.enabledBars[bar.id] = defaults.enabledBars[bar.id]
        end
    end
end

-----------------------------------------------------------------------
-- Settings panel (Options → Addons → Hide Actionbar)
-----------------------------------------------------------------------

local settingsCategory

local function InitializeSettings()
    local category, layout = Settings.RegisterVerticalLayoutCategory("Hide Actionbar")
    settingsCategory = category

    -- Opacity slider
    local opacitySetting = Settings.RegisterProxySetting(
        category,
        "HIDEACTIONBAR_OPACITY",
        Settings.VarType.Number,
        "Hidden Opacity",
        defaults.hiddenAlpha,
        function() return HideActionbarDB.hiddenAlpha end,
        function(value)
            HideActionbarDB.hiddenAlpha = value
            if HideActionbarDB.isHidden then
                ApplyState()
            end
        end
    )
    local sliderOptions = Settings.CreateSliderOptions(0, 1, 0.05)
    sliderOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value)
        return string.format("%.0f%%", value * 100)
    end)
    Settings.CreateSlider(category, opacitySetting, sliderOptions, "How transparent the bars become when hidden. 0% = fully invisible, 100% = fully visible.")

    -- Bar checkboxes
    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer("Bars to Hide"))

    for _, bar in ipairs(bars) do
        local barSetting = Settings.RegisterProxySetting(
            category,
            "HIDEACTIONBAR_BAR_" .. bar.id:upper(),
            Settings.VarType.Boolean,
            bar.name,
            defaults.enabledBars[bar.id],
            function() return HideActionbarDB.enabledBars[bar.id] end,
            function(value)
                HideActionbarDB.enabledBars[bar.id] = value
                if not value then
                    local frame = GetBarFrame(bar)
                    if frame then frame:SetAlpha(1) end
                elseif HideActionbarDB.isHidden then
                    local frame = GetBarFrame(bar)
                    if frame then frame:SetAlpha(HideActionbarDB.hiddenAlpha) end
                end
            end
        )
        Settings.CreateCheckbox(category, barSetting)
    end

    Settings.RegisterAddOnCategory(category)
end

-----------------------------------------------------------------------
-- Slash commands
-----------------------------------------------------------------------

SLASH_HIDEACTIONBAR1 = "/hideactionbar"
SLASH_HIDEACTIONBAR2 = "/hab"

SlashCmdList["HIDEACTIONBAR"] = function(msg)
    local cmd = msg:match("^(%S+)") or ""
    cmd = cmd:lower()

    if cmd == "toggle" or cmd == "" then
        HideActionbar_Toggle()
    elseif cmd == "options" or cmd == "config" or cmd == "settings" then
        ShowUIPanel(SettingsPanel)
        if settingsCategory then
            SettingsPanel:SelectCategory(settingsCategory)
        end
    else
        print("|cFF00FF00Hide Actionbar:|r Commands:")
        print("  /hab - Toggle visibility")
        print("  /hab options - Open settings")
    end
end

-----------------------------------------------------------------------
-- Event handling
-----------------------------------------------------------------------

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    InitDB()
    InitializeSettings()
    ApplyState()
end)

-- Keybind localization
BINDING_HEADER_HIDE_ACTIONBAR = "Hide Actionbar"
BINDING_NAME_HIDE_ACTIONBAR_TOGGLE = "Toggle Visibility"
