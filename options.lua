local optionsPanel = CreateFrame("Frame", "DelvePlusTimerOptions", UIParent)
optionsPanel.name = "DelvePlus Timer"

-- Schriftgröße-Option
local fontSizeSlider = CreateFrame("Slider", "FontSizeSlider", optionsPanel, "OptionsSliderTemplate")
fontSizeSlider:SetPoint("TOPLEFT", 20, -40)
fontSizeSlider:SetMinMaxValues(10, 30)
fontSizeSlider:SetValue(DelvePlusTimerDB.fontSize)
fontSizeSlider:SetValueStep(1)
fontSizeSlider:SetScript("OnValueChanged", function(self, value)
    DelvePlusTimerDB.fontSize = value
    timerText:SetFont(DelvePlusTimerDB.font, value)
end)
fontSizeSlider.text = _G[fontSizeSlider:GetName().."Text"]
fontSizeSlider.text:SetText("Schriftgröße")
fontSizeSlider.low = _G[fontSizeSlider:GetName().."Low"]
fontSizeSlider.low:SetText("10")
fontSizeSlider.high = _G[fontSizeSlider:GetName().."High"]
fontSizeSlider.high:SetText("30")

-- Transparenz-Option
local transparencySlider = CreateFrame("Slider", "TransparencySlider", optionsPanel, "OptionsSliderTemplate")
transparencySlider:SetPoint("TOPLEFT", 20, -80)
transparencySlider:SetMinMaxValues(0, 1)
transparencySlider:SetValue(DelvePlusTimerDB.transparency)
transparencySlider:SetValueStep(0.1)
transparencySlider:SetScript("OnValueChanged", function(self, value)
    DelvePlusTimerDB.transparency = value
    timerFrame:SetBackdropColor(0, 0, 0, value)
end)
transparencySlider.text = _G[transparencySlider:GetName().."Text"]
transparencySlider.text:SetText("Transparenz")
transparencySlider.low = _G[transparencySlider:GetName().."Low"]
transparencySlider.low:SetText("0")
transparencySlider.high = _G[transparencySlider:GetName().."High"]
transparencySlider.high:SetText("1")

