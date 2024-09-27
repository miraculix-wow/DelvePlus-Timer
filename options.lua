local AceGUI = LibStub("AceGUI-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

-- Lokalisierung
local L = {}
local locale = GetLocale()

if locale == "deDE" then
    L["Font"] = "Schriftart"
    L["FontSize"] = "Schriftgröße"
    L["Lock"] = "Timer sperren"
    L["Show"] = "Timer anzeigen"
    L["FontDesc"] = "Wähle die Schriftart für den Timer."
    L["FontSizeDesc"] = "Stelle die Schriftgröße für den Timer ein."
    L["LockDesc"] = "Sperrt den Timer an seiner Position."
    L["ShowDesc"] = "Zeigt oder versteckt den Timer."
else
    L["Font"] = "Font"
    L["FontSize"] = "Font Size"
    L["Lock"] = "Lock Timer"
    L["Show"] = "Show Timer"
    L["FontDesc"] = "Select the font for the timer."
    L["FontSizeDesc"] = "Set the font size for the timer."
    L["LockDesc"] = "Locks the timer at its position."
    L["ShowDesc"] = "Shows or hides the timer."
end

-- Standard Optionen
local options = {
    name = "DelvePlus Timer Einstellungen",
    handler = DelvePlusTimer,
    type = "group",
    args = {
        font = {
            type = "select",
            name = L["Font"],
            desc = L["FontDesc"],
            values = {
                ["Fonts\\FRIZQT__.TTF"] = "Friz Quadrata",
                ["Interface\\AddOns\\ElvUI\\Core\\media\\Fonts\\Expressway.ttf"] = "Expressway",
            },
            get = function(info) return DelvePlusTimer.db.profile.font end,
            set = function(info, value)
                DelvePlusTimer.db.profile.font = value
                DelvePlusTimer:UpdateTimerFont()  -- Schriftart und Schriftgröße aktualisieren
            end,
        },
        fontSize = {
            type = "range",
            name = L["FontSize"],
            desc = L["FontSizeDesc"],
            min = 10, max = 50, step = 1,
            get = function(info) return DelvePlusTimer.db.profile.fontSize end,
            set = function(info, value)
                DelvePlusTimer.db.profile.fontSize = value
                DelvePlusTimer:UpdateTimerFont()  -- Schriftgröße aktualisieren
            end,
        },
        lock = {
            type = "toggle",
            name = L["Lock"],
            desc = L["LockDesc"],
            get = function(info) return DelvePlusTimer.db.profile.locked end,
            set = function(info, value)
                if value then
                    DelvePlusTimer:LockTimerFrame()
                else
                    DelvePlusTimer:UnlockTimerFrame()
                end
            end,
        },
        show = {
            type = "toggle",
            name = L["Show"],
            desc = L["ShowDesc"],
            get = function(info) return DelvePlusTimer.db.profile.visible end,
            set = function(info, value)
                if value then
                    DelvePlusTimer:ShowTimerFrame()
                else
                    DelvePlusTimer:HideTimerFrame()
                end
            end,
        },
    },
}

-- Registriere das Optionsmenü bei AceConfig
AceConfig:RegisterOptionsTable("DelvePlusTimer", options)
AceConfigDialog:AddToBlizOptions("DelvePlusTimer", "DelvePlus Timer")

-- AceConfigDialog verwenden, um die Optionen zu öffnen
SLASH_DELVETIMER1 = "/delve"
SlashCmdList["DELVETIMER"] = function(msg)
    if msg == "config" then
        -- Öffnet das Optionsmenü mit AceConfigDialog
        AceConfigDialog:Open("DelvePlusTimer")
    elseif msg == "start" then
        DelvePlusTimer:StartTimer()  -- Timer starten
    elseif msg == "stop" then
        DelvePlusTimer:StopTimer()  -- Timer stoppen
    else
        print("Verwende /delve start, /delve stop, oder /delve config, um das Optionsfenster zu öffnen.")
    end
end
