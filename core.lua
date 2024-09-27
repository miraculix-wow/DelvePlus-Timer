local L = {}
local locale = GetLocale()

-- Lokalisierung für Deutsch und Englisch
if locale == "deDE" then
    L["TimerStarted"] = "Der Timer startet nach einem 10-Sekunden-Countdown."
    L["TimerStopped"] = "Timer gestoppt!"
    L["CountdownMessage"] = "Der 10-Sekunden-Countdown beginnt!"
    L["Go"] = "Los!"
else
    L["TimerStarted"] = "Timer will start after a 10-second countdown."
    L["TimerStopped"] = "Timer stopped!"
    L["CountdownMessage"] = "The 10-second countdown begins!"
    L["Go"] = "Go!"
end

DelvePlusTimer = LibStub("AceAddon-3.0"):NewAddon("DelvePlusTimer", "AceConsole-3.0", "AceEvent-3.0")

-- Timer und gespeicherte Einstellungen
local defaults = {
    profile = {
        fontSize = 28,
        font = "Fonts\\FRIZQT__.TTF",
        transparency = 1,
        point = "CENTER",
        relativePoint = "CENTER",
        xOffset = 0,
        yOffset = 200,
        visible = true,
        locked = false,
    }
}

function DelvePlusTimer:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("DelvePlusTimerDB", defaults, true)
    
    -- Setze den Timer verschiebbar, wenn nicht gesperrt
    if self.db.profile.locked then
        self:LockTimerFrame()
    else
        self:UnlockTimerFrame()
    end

    -- Timer initial anzeigen oder verstecken
    if self.db.profile.visible then
        self:ShowTimerFrame()
    else
        self:HideTimerFrame()
    end
end

function DelvePlusTimer:OnEnable()
    -- Stelle sicher, dass der Timer beim Aktivieren geladen wird
    self:UpdateTimerPosition()
end

-- Timer Frame als globale Variable erstellen
timerFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
timerFrame:SetSize(300, 50)
timerFrame:SetMovable(true)
timerFrame:EnableMouse(true)
timerFrame:RegisterForDrag("LeftButton")

-- Timer UI erstellen
local titleText = timerFrame:CreateFontString(nil, "OVERLAY")
local timerText = timerFrame:CreateFontString(nil, "OVERLAY")

-- Schriftart und Farben für den Titel und Timer einstellen
function DelvePlusTimer:UpdateTimerFont()
    local font = self.db.profile.font or "Fonts\\FRIZQT__.TTF"
    local fontSize = self.db.profile.fontSize or 28

    -- Blauer Titeltext
    titleText:SetFont(font, fontSize, "OUTLINE")
    titleText:SetTextColor(0, 0.5, 1)  -- Blau für den Titel
    titleText:SetText("DelvePlus Timer")

    -- Weißer Timertext
    timerText:SetFont(font, fontSize, "OUTLINE")
    timerText:SetTextColor(1, 1, 1)  -- Weiß für den Timer
    timerText:SetText("00:00:00")

    titleText:SetPoint("LEFT", timerFrame, "LEFT", 10, 0)  -- Titel-Text Position
    timerText:SetPoint("LEFT", titleText, "RIGHT", 10, 0)  -- Timer rechts vom Titel-Text
end

-- Position aktualisieren
function DelvePlusTimer:UpdateTimerPosition()
    local db = self.db.profile
    timerFrame:ClearAllPoints()
    timerFrame:SetPoint(db.point, UIParent, db.relativePoint, db.xOffset, db.yOffset)
    self:UpdateTimerFont()
end

-- Timer anzeigen
function DelvePlusTimer:ShowTimerFrame()
    timerFrame:Show()
    titleText:Show()
    timerText:Show()
    self:UpdateTimerFont()  -- Schriftart und Position aktualisieren
    self.db.profile.visible = true
end

-- Timer verstecken
function DelvePlusTimer:HideTimerFrame()
    timerFrame:Hide()
    self.db.profile.visible = false
end

-- Timer sperren
function DelvePlusTimer:LockTimerFrame()
    timerFrame:SetMovable(false)
    timerFrame:EnableMouse(false)
    self.db.profile.locked = true
end

-- Timer entsperren
function DelvePlusTimer:UnlockTimerFrame()
    timerFrame:SetMovable(true)
    timerFrame:EnableMouse(true)
    timerFrame:RegisterForDrag("LeftButton")
    timerFrame:SetScript("OnDragStart", timerFrame.StartMoving)
    timerFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relativePoint, xOffset, yOffset = self:GetPoint()
        DelvePlusTimer.db.profile.point = point
        DelvePlusTimer.db.profile.relativePoint = relativePoint
        DelvePlusTimer.db.profile.xOffset = xOffset
        DelvePlusTimer.db.profile.yOffset = yOffset
    end)
    self.db.profile.locked = false
end

-- Timer Logik
local running = false
local startTime = 0

local function UpdateTimer(self, elapsed)
    if running then
        local time = GetTime() - startTime
        timerText:SetText(date("!%X", time))  -- Aktualisiere den Timertext
    end
end
timerFrame:SetScript("OnUpdate", UpdateTimer)

-- Countdown Funktion
function DelvePlusTimer:StartTimerWithCountdown()
    local countdownTime = 10
    local countdownText = UIParent:CreateFontString(nil, "OVERLAY")
    countdownText:SetFont("Fonts\\FRIZQT__.TTF", 40, "OUTLINE")
    countdownText:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    
    local function CountdownStep()
        if countdownTime > 0 then
            countdownText:SetText(tostring(countdownTime))
            countdownTime = countdownTime - 1
            C_Timer.After(1, CountdownStep)
        else
            countdownText:SetText(L["Go"])
            countdownText:SetTextColor(0, 1, 0) -- Setze den "Go!" Text auf grün
            C_Timer.After(1, function() countdownText:Hide() end)
            running = true
            startTime = GetTime()
        end
    end
    CountdownStep()
end

-- **Neue Funktionen zum Starten und Stoppen des Timers**

function DelvePlusTimer:StartTimer()
    self:StartTimerWithCountdown()
    print(L["CountdownMessage"])
end

function DelvePlusTimer:StopTimer()
    running = false
    print(L["TimerStopped"])
end

-- Slash-Befehle
SLASH_DELVETIMER1 = "/delve"
SlashCmdList["DELVETIMER"] = function(msg)
    if msg == "start" then
        DelvePlusTimer:StartTimer()
    elseif msg == "stop" then
        DelvePlusTimer:StopTimer()
    elseif msg == "config" then
        AceConfigDialog:Open("DelvePlusTimer")
    else
        print("Verwende /delve start, stop, show, hide, lock oder unlock.")
    end
end
