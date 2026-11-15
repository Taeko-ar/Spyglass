local addonName, ns = ...
local L = ns.L

local DEFAULT_URL = "https://www.wowhead.com/forever/"
local DEFAULTS = { enabled = true, dbUrl = "" }
local UNIT_MENUS = { "MENU_UNIT_TARGET", "MENU_UNIT_FOCUS" }
local LINK_TYPES = { item = "item", quest = "quest", spell = "spell", enchant = "spell" }
local NPC_GUID_TYPES = { Creature = true, Vehicle = true }

local BACKDROP = {
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
}

local ui = {}
local lastMenuTime

local function Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff96Spyglass:|r " .. message)
end

local function Readable(value)
    if issecretvalue and issecretvalue(value) then return nil end
    return value
end

local function BaseUrl()
    return SpyglassDB.dbUrl ~= "" and SpyglassDB.dbUrl or DEFAULT_URL
end

local function NormalizeUrl(url)
    url = strtrim(url)
    if url ~= "" and not url:match("/$") then
        url = url .. "/"
    end
    return url
end

local function BuildUrl(entry)
    if entry.id then
        return BaseUrl() .. entry.type .. "=" .. entry.id
    end
    return BaseUrl() .. "search?q=" .. (entry.name:gsub(" ", "+"))
end

local function BuildTitle(entry)
    local title = L[entry.type:upper()] .. ": " .. entry.name
    if entry.id then
        title = title .. " (ID: " .. entry.id .. ")"
    end
    return title
end

local function ParseHyperlink(hyperlink)
    local linkType, id = hyperlink:match("|H(%a+):(%d+)")
    local lookupType = LINK_TYPES[linkType]
    if not lookupType then return nil end
    return { type = lookupType, id = tonumber(id), name = hyperlink:match("%[(.-)%]") or linkType }
end

local function ParseNpcId(guid)
    local guidType, _, _, _, _, id = strsplit("-", guid or "")
    return NPC_GUID_TYPES[guidType] and tonumber(id) or nil
end

local function EntryFromUnit(unit)
    if not UnitExists(unit) or UnitIsPlayer(unit) then return nil end
    local name = Readable(UnitName(unit))
    if not name then return nil end
    return { type = "npc", id = ParseNpcId(Readable(UnitGUID(unit))), name = name }
end

local function CreatePanel(name, width, height)
    local panel = CreateFrame("Frame", name, UIParent, "BackdropTemplate")
    panel:SetSize(width, height)
    panel:SetPoint("CENTER")
    panel:SetFrameStrata("DIALOG")
    panel:SetBackdrop(BACKDROP)
    panel:SetBackdropColor(0.06, 0.07, 0.09, 0.95)
    panel:SetBackdropBorderColor(0, 0.7, 1, 0.8)
    panel:SetClampedToScreen(true)
    panel:EnableMouse(true)
    panel:SetMovable(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
    panel:Hide()
    tinsert(UISpecialFrames, name)
    return panel
end

local function CreateText(parent, template)
    return parent:CreateFontString(nil, "ARTWORK", template)
end

local function CreateButton(parent, label, width, onClick)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width, 26)
    button:SetText(label)
    button:SetScript("OnClick", onClick)
    return button
end

local function CreateCloseButton(parent)
    local button = CreateFrame("Button", nil, parent, "UIPanelCloseButton")
    button:SetPoint("TOPRIGHT", -5, -5)
    return button
end

local function CreateInput(parent, onEnter)
    local input = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    input:SetSize(340, 32)
    input:SetAutoFocus(false)
    input:SetMaxLetters(255)
    input:SetScript("OnEnterPressed", onEnter)
    input:SetScript("OnEscapePressed", function() parent:Hide() end)
    return input
end

local function CreateLinkPanel()
    local panel = CreatePanel("SpyglassLinkFrame", 400, 110)
    panel.title = CreateText(panel, "GameFontNormal")
    panel.title:SetPoint("TOP", 0, -15)
    panel.input = CreateInput(panel, function() panel:Hide() end)
    panel.input:SetPoint("TOP", 0, -40)
    CreateButton(panel, L.CLOSE, 110, function() panel:Hide() end):SetPoint("BOTTOM", 0, 12)
    CreateCloseButton(panel)
    return panel
end

local function SaveUrl()
    local url = NormalizeUrl(ui.setup.input:GetText())
    if url == "" then
        Print(L.URL_BLANK)
    end
    SpyglassDB.dbUrl = url
    Print(L.URL_SAVED .. url)
    ui.setup:Hide()
end

local function CreateSuggestion(panel)
    local button = CreateFrame("Button", nil, panel)
    button:SetSize(340, 20)
    local text = CreateText(button, "GameFontNormalSmall")
    text:SetAllPoints()
    text:SetJustifyH("LEFT")
    local function Paint(color)
        text:SetText(L.SETUP_SUGGEST:format(color .. DEFAULT_URL .. "|r"))
    end
    button:SetScript("OnClick", function()
        panel.input:SetText(DEFAULT_URL)
        panel.input:SetFocus()
    end)
    button:SetScript("OnEnter", function() Paint("|cffffdd00") end)
    button:SetScript("OnLeave", function() Paint("|cff00ffff") end)
    Paint("|cff00ffff")
    return button
end

local function CreateSetupPanel()
    local panel = CreatePanel("SpyglassSetupFrame", 400, 180)
    local title = CreateText(panel, "GameFontNormal")
    title:SetPoint("TOP", 0, -15)
    title:SetText(L.SETUP_TITLE)
    local subtitle = CreateText(panel, "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", 30, -45)
    subtitle:SetText(L.SETUP_SUBTITLE)
    panel.input = CreateInput(panel, SaveUrl)
    panel.input:SetPoint("TOPLEFT", 30, -70)
    CreateSuggestion(panel):SetPoint("TOPLEFT", panel.input, "BOTTOMLEFT", 0, -5)
    CreateButton(panel, L.CLOSE, 110, function() panel:Hide() end):SetPoint("BOTTOMLEFT", 30, 20)
    CreateButton(panel, L.SETUP_SAVE, 110, SaveUrl):SetPoint("BOTTOMRIGHT", -30, 20)
    CreateCloseButton(panel)
    return panel
end

local function ShowLink(entry)
    ui.link.title:SetText(BuildTitle(entry))
    ui.link.input:SetText(BuildUrl(entry))
    ui.link:Show()
    ui.link.input:SetFocus()
    ui.link.input:HighlightText()
    Print(L.OPENED_LINK .. entry.name)
end

local function ShowSetup()
    ui.setup.input:SetText(BaseUrl())
    ui.setup:Show()
end

local function ShowMenu(entry)
    if lastMenuTime == GetTime() then return end
    lastMenuTime = GetTime()
    MenuUtil.CreateContextMenu(UIParent, function(_, root)
        root:CreateTitle(entry.name)
        root:CreateButton(L.DB_LOOKUP, function() ShowLink(entry) end)
    end)
end

local function IsLookupClick(button)
    return SpyglassDB.enabled and button == "RightButton" and IsControlKeyDown()
end

local function OnHyperlinkClick(hyperlink, button)
    if not hyperlink or not IsLookupClick(button) then return end
    local entry = ParseHyperlink(hyperlink)
    if entry then
        ShowMenu(entry)
    end
end

local function AddUnitMenuButton(_, root, context)
    local entry = SpyglassDB.enabled and EntryFromUnit(context.unit)
    if not entry then return end
    root:CreateDivider()
    root:CreateButton(L.DB_LOOKUP, function() ShowLink(entry) end)
end

local function LookupTarget()
    local entry = EntryFromUnit("target")
    if entry then
        ShowLink(entry)
    else
        Print(L.NO_TARGET)
    end
end

local function ToggleEnabled()
    SpyglassDB.enabled = not SpyglassDB.enabled
    Print(SpyglassDB.enabled and L.ENABLED or L.DISABLED)
end

local function PrintHelp()
    Print(L.HELP_BASE)
    Print(L.HELP_TOGGLE)
    Print(L.HELP_SETUP)
end

local COMMANDS = {
    toggle = ToggleEnabled,
    setup = ShowSetup,
    help = PrintHelp,
}

local function OnSlashCommand(message)
    local command = COMMANDS[strtrim(message):lower()] or LookupTarget
    command()
end

local function RegisterSlashCommands()
    SLASH_SPYGLASS1 = "/spyglass"
    SLASH_SPYGLASS2 = "/qdb"
    SlashCmdList.SPYGLASS = OnSlashCommand
end

local function RegisterHooks()
    hooksecurefunc("SetItemRef", function(_, text, button) OnHyperlinkClick(text, button) end)
    hooksecurefunc("HandleModifiedItemClick", function(link) OnHyperlinkClick(link, GetMouseButtonClicked()) end)
    for _, tag in ipairs(UNIT_MENUS) do
        Menu.ModifyMenu(tag, AddUnitMenuButton)
    end
end

local function LoadSavedVariables()
    SpyglassDB = SpyglassDB or {}
    for key, value in pairs(DEFAULTS) do
        if SpyglassDB[key] == nil then
            SpyglassDB[key] = value
        end
    end
end

local function OnAddonLoaded(self, _, name)
    if name ~= addonName then return end
    self:UnregisterEvent("ADDON_LOADED")
    LoadSavedVariables()
    Print(L.LOADED:format(C_AddOns.GetAddOnMetadata(addonName, "Version")))
    if SpyglassDB.dbUrl == "" then
        ShowSetup()
    end
end

local function Init()
    ui.link = CreateLinkPanel()
    ui.setup = CreateSetupPanel()
    RegisterSlashCommands()
    RegisterHooks()
    local loader = CreateFrame("Frame")
    loader:RegisterEvent("ADDON_LOADED")
    loader:SetScript("OnEvent", OnAddonLoaded)
end

Init()
