-- Addon-Tabelle erstellen
local addonName, addonTable = ...
local frame = CreateFrame("Frame", "DelvePlusTimerFrame", UIParent, "BackdropTemplate")

-- Sprachvariablen
local L = {}
local locale = GetLocale()

-- Übersetzungen für Englisch
L["enUS"] = {
    title = "DelvePlus Timer",
    startMessage = "Timer will start after a 10-second countdown.",
    stopMessage = "Timer stopped!",
    showMessage = "DelvePlus Timer is now visible.",
    hideMessage = "DelvePlus Timer is now hidden.",
    slashHelp = "Use /delve start, /delve stop, /delve show, /delve hide, /delve lock or /delve unlock",
    lockMessage = "DelvePlus Timer is now locked in position.",
    unlockMessage = "DelvePlus Timer can now be moved.",
}

-- Übersetzungen für Deutsch
L["deDE"] = {
    title = "DelvePlus Timer",
    startMessage = "Der Timer wird nach einem 10-Sekunden-Countdown starten.",
    stopMessage = "Timer gestoppt!",
    showMessage = "DelvePlus Timer wird angezeigt.",
    hideMessage = "DelvePlus Timer ist versteckt.",
    slashHelp = "Verwende /delve start, /delve stop, /delve show, /delve hide, /delve lock oder /delve unlock",
    lockMessage = "DelvePlus Timer ist jetzt gesperrt.",
    unlockMessage = "DelvePlus Timer kann jetzt bewegt werden.",
}

-- Wähle die korrekte Sprachübersetzung
local function GetLocaleStrings()
    return L[locale] or L["enUS"]
end

local strings = GetLocaleStrings()

-- Standard Einstellungen
local defaults = {
    fontSize = 28,  -- Schriftgröße auf 28 gesetzt
    font = "Interface\\AddOns\\ElvUI\\Core\\media\\Fonts\\Expressway.ttf",  -- Korrigierter Pfad für Expressway-Schriftart
    transparency = 1,
    point = "CENTER",
    relativePoint = "CENTER",
    xOffset = 0,
    yOffset = 200,
    visible = true,  -- Timer standardmäßig sichtbar
    locked = false,  -- Timer standardmäßig entsperrt
}

-- Saved Variables initialisieren
DelvePlusTimerDB = DelvePlusTimerDB or defaults

-- Timer UI im ElvUI Stil
local timerFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
timerFrame:SetSize(300, 50)
timerFrame:SetMovable(true)
timerFrame:EnableMouse(true)

-- ElvUI-Textur und Rahmen verwenden
timerFrame:SetBackdrop({
    bgFile = "Interface\\AddOns\\ElvUI\\media\\textures\\normTex",  -- ElvUI-Textur
    edgeFile = "Interface\\AddOns\\ElvUI\\media\\textures\\glowTex", -- ElvUI-Glow Textur für den Rahmen
    edgeSize = 6,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
timerFrame:SetBackdropColor(0, 0, 0, DelvePlusTimerDB.transparency)  -- Transparenz steuern
timerFrame:SetBackdropBorderColor(0, 0, 0, 0.8) -- Dunkler Rahmen im ElvUI-Stil

-- Funktion zum Setzen der Schriftart mit Fallback auf Friz Quadrata
local function SetFontWithFallback(fontString, fontPath, fontSize)
    local success = fontString:SetFont(fontPath, fontSize, "OUTLINE")
    
    -- Prüfe, ob die Schriftart erfolgreich gesetzt wurde
    if not success then
        -- Fallback auf Friz Quadrata, falls Expressway nicht verfügbar ist
        fontString:SetFont("Fonts\\FRIZQT__.TTF", fontSize, "OUTLINE")
        print("Expressway-Schriftart nicht verfügbar. Fallback auf Friz Quadrata.")
    end
end

-- Blauer Text "DelvePlus Timer"
local titleText = timerFrame:CreateFontString(nil, "OVERLAY")
titleText:SetPoint("LEFT", timerFrame, "LEFT", 10, 0)  -- Positionierung links im Frame
SetFontWithFallback(titleText, "Interface\\AddOns\\ElvUI\\Core\\media\\Fonts\\Expressway.ttf", 28)  -- Versuche, Expressway zu verwenden
titleText:SetTextColor(0, 0.5, 1)  -- Blauer Text
titleText:SetText(strings.title .. ": ")

-- Timer Text
local timerText = timerFrame:CreateFontString(nil, "OVERLAY")
timerText:SetPoint("LEFT", titleText, "RIGHT", 10, 0)  -- Timer rechts vom Titel-Text positionieren
SetFontWithFallback(timerText, "Interface\\AddOns\\ElvUI\\Core\\media\\Fonts\\Expressway.ttf", 28)  -- Versuche, Expressway zu verwenden
timerText:SetTextColor(1, 1, 1)  -- Weißer Text für den Timer
timerText:SetText("00:00:00")


-- Timer Logik
local running = false
local startTime = 0

local function UpdateTimer(self, elapsed)
    if running then
        local time = GetTime() - startTime
        timerText:SetText(date("!%X", time))  -- Nur der Timer wird aktualisiert
    end
end

timerFrame:SetScript("OnUpdate", UpdateTimer)

-- Funktion zum Verstecken oder Anzeigen des Timer-Frames
local function ShowTimerFrame()
    timerFrame:Show()
    DelvePlusTimerDB.visible = true
    print(strings.showMessage)
end

local function HideTimerFrame()
    timerFrame:Hide()
    DelvePlusTimerDB.visible = false
    print(strings.hideMessage)
end

-- Funktion, um den Timerframe zu sperren oder zu entsperren
local function LockTimerFrame()
    timerFrame:SetMovable(false)
    timerFrame:EnableMouse(false)
    DelvePlusTimerDB.locked = true
    print(strings.lockMessage)
end

local function UnlockTimerFrame()
    timerFrame:SetMovable(true)
    timerFrame:EnableMouse(true)
    timerFrame:RegisterForDrag("LeftButton")
    timerFrame:SetScript("OnDragStart", timerFrame.StartMoving)
    timerFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relativePoint, xOffset, yOffset = self:GetPoint()
        DelvePlusTimerDB.point = point
        DelvePlusTimerDB.relativePoint = relativePoint
        DelvePlusTimerDB.xOffset = xOffset
        DelvePlusTimerDB.yOffset = yOffset
    end)
    DelvePlusTimerDB.locked = false
    print(strings.unlockMessage)
end

-- Event, um sicherzustellen, dass die Position korrekt geladen wird
local function OnAddonLoaded(self, event, addon)
    if addon == addonName then
        -- Setze die gespeicherte Position des Frames
        timerFrame:ClearAllPoints()
        timerFrame:SetPoint(DelvePlusTimerDB.point, UIParent, DelvePlusTimerDB.relativePoint, DelvePlusTimerDB.xOffset, DelvePlusTimerDB.yOffset)
        
        -- Zeige oder verstecke das Frame basierend auf gespeicherten Einstellungen
        if DelvePlusTimerDB.visible then
            ShowTimerFrame()
        else
            HideTimerFrame()
        end

        -- Sperre oder entsperre das Frame basierend auf gespeicherten Einstellungen
        if DelvePlusTimerDB.locked then
            LockTimerFrame()
        else
            UnlockTimerFrame()
        end
    end
end

-- Event-Handler registrieren
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", OnAddonLoaded)

-- Timer-Start mit Bildschirmanzeige-Countdown-Logik
local function StartTimerWithScreenCountdown()
    local countdownTime = 10  -- Setze den Countdown auf 10 Sekunden
    print(strings.startMessage)

-- Erstelle ein FontString-Overlay für den Countdown
local countdownText = UIParent:CreateFontString(nil, "OVERLAY")

-- Verwende die SetFontWithFallback-Funktion, um die Schriftart zu setzen
SetFontWithFallback(countdownText, "Interface\\AddOns\\ElvUI\\Core\\media\\Fonts\\Expressway.ttf", 60)

countdownText:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
countdownText:SetTextColor(1, 1, 1)  -- Weißer Text für den Countdown
countdownText:SetText(tostring(countdownTime))

    -- Funktion zum Herunterzählen und Aktualisieren der Anzeige
    local function CountdownStep()
        if countdownTime > 0 then
            -- Aktualisiere die Countdown-Anzeige
            countdownText:SetText(tostring(countdownTime))
            countdownTime = countdownTime - 1

            -- Wiederhole die Funktion nach einer Sekunde
            C_Timer.After(1, CountdownStep)
        else
            -- Zeige "Go!" in Grün an und starte den Timer
            countdownText:SetText("Go!")
            countdownText:SetTextColor(0, 1, 0)  -- Setze den Text auf Grün für "Go!"
            C_Timer.After(1, function() countdownText:Hide() end)  -- Verberge den Countdown nach 1 Sekunde
            running = true
            startTime = GetTime()
        end
    end

    -- Starte den Countdown
    CountdownStep()
end

-- Befehle für Starten, Stoppen, Anzeigen, Verstecken, Sperren und Entsperren des Timers
SLASH_DELVETIMER1 = "/delve"
SlashCmdList["DELVETIMER"] = function(msg)
    if msg == "start" then
        StartTimerWithScreenCountdown()  -- Countdown und Timer starten
    elseif msg == "stop" then
        running = false
        print(strings.stopMessage)
    elseif msg == "show" then
        ShowTimerFrame()
    elseif msg == "hide" then
        HideTimerFrame()
    elseif msg == "lock" then
        LockTimerFrame()
    elseif msg == "unlock" then
        UnlockTimerFrame()
    else
        print(strings.slashHelp)
    end
end
