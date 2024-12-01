-- Hide XP Bar Addon Namespace
local HideXPBarAddon = {}

-- Variable to track XP bar visibility state
HideXPBarAddon.isHidden = true

-- Function to hide the XP bar
function HideXPBarAddon:HideXPBar()
    if _G["MainMenuExpBar"] then
        _G["MainMenuExpBar"]:Hide()
        self.isHidden = true
    end
end

-- Function to show the XP bar
function HideXPBarAddon:ShowXPBar()
    if _G["MainMenuExpBar"] then
        _G["MainMenuExpBar"]:Show()
        self.isHidden = false
    end
end

-- Function to toggle the XP bar visibility
function HideXPBarAddon:ToggleXPBar()
    if self.isHidden then
        self:ShowXPBar()
        print("|cFF0070DEXP Bar|r is now visible.")
    else
        self:HideXPBar()
        print("|cFF0070DEXP Bar|r is now hidden.")
    end
end

-- Event frame to handle initial hiding and updates
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("UPDATE_EXHAUSTION") -- Fired when XP or rested state updates
eventFrame:RegisterEvent("PLAYER_XP_UPDATE") -- Fired when gaining XP
eventFrame:RegisterEvent("UPDATE_FACTION") -- Fired when gaining reputation

eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "PLAYER_ENTERING_WORLD" or (event == "ADDON_LOADED" and arg1 == "HideXPBar") then
        HideXPBarAddon:HideXPBar()

        -- Display login message in chat
        if event == "PLAYER_ENTERING_WORLD" then
            print("|cFFFFFF00[|cFF0070DEHide XP Bar|r|cFFFFFF00]|r |cFFFFFFFFType /hidexpbar to toggle the Experience Bar.|r")
        end
    elseif event == "UPDATE_EXHAUSTION" or event == "PLAYER_XP_UPDATE" or event == "UPDATE_FACTION" then
        if HideXPBarAddon.isHidden then
            HideXPBarAddon:HideXPBar()
        end
    end
end)

-- Add slash command to toggle XP bar
SLASH_HIDEXPBAR1 = "/hidexpbar"
SlashCmdList["HIDEXPBAR"] = function(msg)
    HideXPBarAddon:ToggleXPBar()
end

-- Create a minimap button
local minimapButton = CreateFrame("Button", "HideXPBarMinimapButton", Minimap)
minimapButton:SetSize(32, 32) -- Button size
minimapButton:SetFrameStrata("MEDIUM")
minimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -2, -2) -- Anchor the button to the top-left corner of the minimap

-- Add the icon texture
local minimapButtonTexture = minimapButton:CreateTexture(nil, "ARTWORK")
local iconPath = "Interface\\AddOns\\HideXPBar\\icon.tga" -- Replace with your icon path
minimapButtonTexture:SetTexture(iconPath)
minimapButtonTexture:SetSize(20, 20) -- Icon size smaller than the button
minimapButtonTexture:SetPoint("CENTER", minimapButton, "CENTER", 0, 0) -- Center the icon

-- Add a border texture (no icon)
local minimapButtonBorder = minimapButton:CreateTexture(nil, "OVERLAY")
minimapButtonBorder:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
minimapButtonBorder:SetSize(54, 54) -- Adjust size of the border
minimapButtonBorder:SetPoint("CENTER", minimapButton, "CENTER", 10, -11.5) -- Center the border

-- Enable dragging of the button (restricted to the minimap circle)
minimapButton:SetMovable(true)
minimapButton:EnableMouse(true)
minimapButton:RegisterForDrag("LeftButton")

-- Restrict movement around the minimap
minimapButton:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

minimapButton:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()

    -- Get the position of the button relative to the minimap
    local mouseX, mouseY = GetCursorPosition()
    local uiScale = UIParent:GetEffectiveScale()
    local centerX, centerY = Minimap:GetCenter()
    local minimapX, minimapY = (mouseX / uiScale) - centerX, (mouseY / uiScale) - centerY
    local distance = math.sqrt(minimapX^2 + minimapY^2)

    -- Restrict the button to the edge of the minimap
    local radius = (Minimap:GetWidth() / 2) + 10 -- Adjust 10 to fine-tune position
    if distance > radius then
        minimapX = minimapX / distance * radius
        minimapY = minimapY / distance * radius
    end

    -- Position the button
    self:ClearAllPoints()
    self:SetPoint("CENTER", Minimap, "CENTER", minimapX, minimapY)
end)

-- Add a click handler to toggle XP bar
minimapButton:SetScript("OnClick", function(self, button)
    if button == "LeftButton" then
        HideXPBarAddon:ToggleXPBar()
    elseif button == "RightButton" then
        print("|cFFFFFF00[|cFF0070DEHide XP Bar|r|cFFFFFF00]|r |cFFFFFFFFRight-click toggled!|r")
    end
end)

-- Add a tooltip to the minimap button
minimapButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("Hide XP Bar Addon", 1, 1, 1)
    GameTooltip:AddLine("|cFFFFFF00Left Click:|r To toggle the |cFF0070DEXP Bar.|r", 0.8, 0.8, 0.8)
    GameTooltip:AddLine("|cFFFFFF00Right Click:|r For options (no options yet).", 0.8, 0.8, 0.8)
    GameTooltip:Show()
end)

minimapButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

