local C_Engraving = {};

local Wrath_Runes = {};
function Wrath_Runes.ToggleEngravingFrame()
    if not C_Engraving.IsEngravingEnabled() then
        return;
    end

    if ( EngravingFrame and EngravingFrame:IsShown() ) then
        EngravingFrame:Hide();
        RuneFrameControlButton:SetChecked(false);
    else
        if ( not IsAddOnLoaded("Wrath_Runes") ) then
            LoadAddOn("Wrath_Runes");
        end

        EngravingFrame:Show();
        RuneFrameControlButton:SetChecked(true);
    end
end

function Wrath_Runes.RefreshRuneFrameControlButton()
    RuneFrameControlButton:SetChecked(EngravingFrame and EngravingFrame:IsShown());
end

function Wrath_Runes.GenerateRuneControlButton()
    local RuneFrameControlButton = CreateFrame("CheckButton", "RuneFrameControlButton", CharacterHandsSlot)
    RuneFrameControlButton:SetSize(32, 32)
    RuneFrameControlButton:SetPoint("BOTTOMRIGHT", CharacterHandsSlot, "TOPRIGHT", 0, 3)

    RuneFrameControlButton:SetNormalTexture("Interface\\Icons\\INV_Misc_Rune_06")
    RuneFrameControlButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    RuneFrameControlButton:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight", "ADD")

    RuneFrameControlButton:SetScript("OnLoad", RuneFrameControlButton_OnLoad)
    RuneFrameControlButton:SetScript("OnShow", RuneFrameControlButton_OnShow)
    RuneFrameControlButton:SetScript("OnClick", Wrath_Runes.ToggleEngravingFrame)

    PaperDollFrame:SetScript("OnHide", Wrath_Runes.ToggleEngravingFrame)
end
Wrath_Runes.GenerateRuneControlButton()

RuneFrameControlButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
    GameTooltip:SetText("Runes",1.0,1.0,1.0)
    GameTooltip:Show()
end)

RuneFrameControlButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)


CATEGORY_FILTERS = {};
RUNE_CATEGORIES = {
    [5] = "Chest",
    [6] = "Waist",
    [7] = "Legs",
    [10] = "Hands",
};
OWNED_CATEGORIES = {5, 6, 7, 10};
SEARCH_FILTER = nil;
ENGRAVING_ENABLED = true;
EXCLUSIVE_CATEGORY_FILTER = -1;
EQUIPPED_FILTER_ENABLED = false;
RUNE_INFORMATION = {};
EQUIPMENT_SLOT_ENGRAVINGS = {};
INVENTORY_ENGRAVINGS = {};
CATEGORY_ENGRAVINGS = {};
CURRENT_RUNE_CAST = {};

--[[ Not sure for this ]]--
CONTAINER_SLOT_ENGRAVINGS = {
    {true, true, true}, -- container 1 with all slots engravable
    {true, false, true}, -- container 2 with second slot not engravable
}

EQUIPMENT_ENGRAVABLE_SLOTS = {
    [5] = true,
    [6] = true,
    [7] = true,
    [10] = true,
}


--[[ Retro-ingenering of this : https://github.com/Gethe/wow-ui-source/blob/classic_era/Interface/AddOns/Blizzard_APIDocumentationGenerated/EngravingInfoDocumentation.lua ]]--

function C_Engraving.IsEngravingEnabled()
    return ENGRAVING_ENABLED
end

function C_Engraving.SetSearchFilter(filter)
    SEARCH_FILTER = filter
end

function C_Engraving.SetCategoryFilter(category, state)
    CATEGORY_FILTERS[category] = state
end

function C_Engraving.HasCategoryFilter(category)
    return --[[CATEGORY_FILTERS[category] or false]] true
end

function C_Engraving.isCategoryOwned(category)
    return GetInventoryItemLink("player", category) and true or false
end

function C_Engraving.GetRuneCategories(shouldFilter, ownedOnly)
    local categories = {}

    for category_id, category_name in pairs(RUNE_CATEGORIES) do
        if not shouldFilter or C_Engraving.HasCategoryFilter(category_id) then
            if not ownedOnly or C_Engraving.isCategoryOwned(category_id) then
                categories[category_id] = category_name;
            end
        end
    end
    return categories
end

--[[ Method missing ]]--
function C_Engraving.AddCategoryFilter(category)
    CATEGORY_FILTERS[category] = true
end

function C_Engraving.AddExclusiveCategoryFilter(category)
    EXCLUSIVE_CATEGORY_FILTER = category
end

function C_Engraving.CastRune(skillLineAbilityID)

end

function C_Engraving.ClearAllCategoryFilters()
    for category in pairs(CATEGORY_FILTERS) do
        C_Engraving.ClearCategoryFilter(category)
    end
end

function C_Engraving.ClearCategoryFilter(category)
    CATEGORY_FILTERS[category] = nil
end

function C_Engraving.ClearExclusiveCategoryFilter()
    EXCLUSIVE_CATEGORY_FILTER = nil
end

function C_Engraving.EnableEquippedFilter(enabled)
    EQUIPPED_FILTER_ENABLED = enabled
end

function C_Engraving.GetCurrentRuneCast()
    -- idk for the moment
end

function C_Engraving.GetEngravingModeEnabled()
    -- idk for the moment
end

function C_Engraving.GetExclusiveCategoryFilter()
    return EXCLUSIVE_CATEGORY_FILTER
end

function C_Engraving.GetNumRunesKnown(equipmentSlot)
    if equipmentSlot == nil or RUNE_INFORMATION[equipmentSlot] == nil then
        return 0, 0
    end
    return RUNE_INFORMATION[equipmentSlot].known, RUNE_INFORMATION[equipmentSlot].max
end

function C_Engraving.GetRuneForEquipmentSlot(equipmentSlot)
    return EQUIPMENT_SLOT_ENGRAVINGS[equipmentSlot];
end

function C_Engraving.GetRuneForInventorySlot(containerIndex, slotIndex)
    if INVENTORY_ENGRAVINGS[containerIndex] and INVENTORY_ENGRAVINGS[containerIndex][slotIndex] then
        return INVENTORY_ENGRAVINGS[containerIndex][slotIndex]
    else
        return nil
    end
end

function C_Engraving.GetRunesForCategory(category, ownedOnly)
    local engravingInfoForCategory = CATEGORY_ENGRAVINGS[category];

    if not engravingInfoForCategory then
        return {};
    end

    if ownedOnly then
        local ownedEngravingInfo = {};
        for i, engravingData in ipairs(engravingInfoForCategory) do
            if engravingData.owned then
                table.insert(ownedEngravingInfo, engravingData);
            end
        end
        return ownedEngravingInfo;
    end

    return engravingInfoForCategory;
end

function C_Engraving.IsEquipmentSlotEngravable(equipmentSlot)
    return EQUIPMENT_ENGRAVABLE_SLOTS[equipmentSlot] or false;
end

function C_Engraving.IsEquippedFilterEnabled()
    return EQUIPMENT_FILTER_ENABLED;
end

function C_Engraving.IsInventorySlotEngravable(containerIndex, slotIndex)
    return CONTAINER_SLOT_ENGRAVINGS[containerIndex] and CONTAINER_SLOT_ENGRAVINGS[containerIndex][slotIndex] or false
end

function C_Engraving.IsInventorySlotEngravableByCurrentRuneCast(containerIndex, slotIndex)
    return containerIndex == CURRENT_RUNE_CAST.containerIndex and slotIndex == CURRENT_RUNE_CAST.slotIndex
end

function C_Engraving.IsKnownRuneSpell(spellID)
    return IsSpellKnown(spellID)
end

function C_Engraving.IsRuneEquipped(skillLineAbilityID)
    -- idk for the moment
end

function C_Engraving.RefreshRunesList()
    -- idk for the moment
end

function C_Engraving.SetEngravingModeEnabled(enabled)
    -- idk for the moment
end

function  C_Engraving.EngravingModeChanged(enabled)
    -- idk for the moment
end

function  C_Engraving.EngravingTargetingModeChanged(enabled)
    -- idk for the moment
end

function  C_Engraving.RuneUpdated(rune)
    -- idk for the moment
end

--[[ Not sure for this ]]--
local EngravingData = {
    skillLineAbilityID = 0,
    itemEnchantmentID = 0,
    name = "",
    iconTexture = 0,
    equipmentSlot = 0,
    level = 0,
    learnedAbilitySpellIDs = {}
}

RUNE_BUTTON_HEIGHT = 40;
RUNE_HEADER_BUTTON_HEIGHT = 23;

ALL_RUNES_CATEGORY = -1;
EQUIPPED_RUNES_CATEGORY = -2;

ALL_RUNES = "ALL_RUNES";
EQUIPPED_RUNES = "EQUIPPED_RUNES";
SEARCH = "SEARCH";
RUNES_COLLECTED = 0;
RUNES_COLLECTED_SLOT = 0;

function EngravingFrame_OnLoad (self)
    self.scrollFrame.update = function() EngravingFrame_UpdateRuneList(self) end;
    self.scrollFrame.scrollBar.doNotHide = true;
    self.scrollFrame.dynamic = EngravingFrame_CalculateScroll;

    HybridScrollFrame_CreateButtons(self.scrollFrame, "RuneSpellButtonTemplate", 0, -1, "TOPLEFT", "TOPLEFT", 0, -1, "TOP", "BOTTOM");
end

function EngravingFrame_OnShow (self)
    C_Engraving.RefreshRunesList();

    C_Engraving.SetSearchFilter("");

    EngravingFrame_UpdateRuneList(self);

    C_Engraving.SetEngravingModeEnabled(true);

    self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
    self:RegisterEvent("NEW_RECIPE_LEARNED");
end

function EngravingFrame_OnHide (self)
    self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED");
    self:UnregisterEvent("NEW_RECIPE_LEARNED");

    SetUIPanelAttribute(CharacterFrame, "width", 353);
    UpdateUIPanelPositions(CharacterFrame);

    C_Engraving.SetEngravingModeEnabled(false);
end

function EngravingFrame_OnEvent(self, event, ...)
    if ( event == "PLAYER_EQUIPMENT_CHANGED" ) then
        EngravingFrame_UpdateRuneList(self);
    elseif ( event == "NEW_RECIPE_LEARNED") then
        EngravingFrame_UpdateRuneList(self);
    end
end

function EngravingFrame_HideAllHeaders()
    local currentHeader = 1;
    local header = _G["EngravingFrameHeader"..currentHeader];
    while header do
        header:Hide();
        currentHeader = currentHeader + 1;
        header = _G["EngravingFrameHeader"..currentHeader];
    end
end

-- Todo: It's logic filter
function EngravingFrame_UpdateRuneList (self)
    local numHeaders = 0;
    local numRunes = 0;
    local scrollFrame = EngravingFrame.scrollFrame;
    local buttons = scrollFrame.buttons;
    local offset = HybridScrollFrame_GetOffset(scrollFrame);
    local currOffset = 0;

    local currentHeader = 1;
    EngravingFrame_HideAllHeaders();

    local currButton = 1;
    local categories = C_Engraving.GetRuneCategories(true, true);
    numHeaders = #categories;
    for _, category in ipairs(categories) do
        if currOffset < offset then
            currOffset = currOffset + 1;
        else
            local button = buttons[currButton];
            if button then
                button:Hide();
                header = _G["EngravingFrameHeader"..currentHeader];
                if header then
                    header:SetPoint("BOTTOM", button, 0 , 0);
                    header:Show();
                    header:SetParent(button:GetParent());
                    currentHeader = currentHeader + 1;

                    header.filter = category;
                    header.name:SetText(GetItemInventorySlotInfo(category));

                    if C_Engraving.HasCategoryFilter(category) then
                        header.expandedIcon:Hide();
                        header.collapsedIcon:Show();
                    else
                        header.expandedIcon:Show();
                        header.collapsedIcon:Hide();
                    end
                    button:SetHeight(RUNE_HEADER_BUTTON_HEIGHT);
                    currButton = currButton + 1;
                end
            end
        end

        local runes = C_Engraving.GetRunesForCategory(category, true);
        numRunes = numRunes + #runes;
        for _, rune in ipairs(runes) do
            if currOffset < offset then
                currOffset = currOffset + 1;
            else
                local button = buttons[currButton];

                if button then
                    button:SetHeight(RUNE_BUTTON_HEIGHT);
                    button.icon:SetTexture(rune.iconTexture);
                    button.tooltipName = rune.name;
                    button.name:SetText(rune.name);
                    button.skillLineAbilityID = rune.skillLineAbilityID;
                    button.disabledBG:Hide();
                    button.selectedTex:Hide();
                    button:Show();
                    currButton = currButton + 1;
                end
            end
        end
    end

    while currButton < #buttons do
        buttons[currButton]:Hide();

        currButton = currButton + 1;
    end

    local totalHeight = numRunes * RUNE_BUTTON_HEIGHT;
    totalHeight = totalHeight + (numHeaders * RUNE_HEADER_BUTTON_HEIGHT);
    HybridScrollFrame_Update(scrollFrame, totalHeight+10, 348);

    if numHeaders == 0 and numRunes == 0 then
        scrollFrame.emptyText:Show();
    else
        scrollFrame.emptyText:Hide();
    end

    local exclusiveFilter = C_Engraving.GetExclusiveCategoryFilter();
    if exclusiveFilter then
        UIDropDownMenu_SetText(EngravingFrameFilterDropDown, ALL_RUNES);
    else
        if C_Engraving.IsEquippedFilterEnabled() then
            UIDropDownMenu_SetText(EngravingFrameFilterDropDown, EQUIPPED_RUNES);
        else
            UIDropDownMenu_SetText(EngravingFrameFilterDropDown, ALL_RUNES);
        end
    end

    EngravingFrame_UpdateCollectedLabel(self);
end

-- Todo: idk
function EngravingFrame_UpdateCollectedLabel(self)
    local label = self.collected.collectedText;
    if label then
        local exclusiveFilter = C_Engraving.GetExclusiveCategoryFilter();
        local known, max = C_Engraving.GetNumRunesKnown(exclusiveFilter);

        if exclusiveFilter then
            label:SetFormattedText(RUNES_COLLECTED_SLOT, known, max --[[GetItemInventorySlotInfo(exclusiveFilter)]]);
        else
            label:SetFormattedText(RUNES_COLLECTED, known, max);
        end
    end
end

-- Todo: Set scroll logic
function EngravingFrame_CalculateScroll(offset)
    local heightLeft = offset;

    local i = 1;
    local categories = C_Engraving.GetRuneCategories(true, true);
    for _, category in pairs(categories) do

        if ( heightLeft - RUNE_HEADER_BUTTON_HEIGHT <= 0 ) then
            return i - 1, heightLeft;
        else
            heightLeft = heightLeft - RUNE_HEADER_BUTTON_HEIGHT;
        end
        i = i + 1;

        local runes = C_Engraving.GetRunesForCategory(category, true);
        for _, rune in ipairs(runes) do
            if ( heightLeft - RUNE_BUTTON_HEIGHT <= 0 ) then
                return i - 1, heightLeft;
            else
                heightLeft = heightLeft - RUNE_BUTTON_HEIGHT;
            end
            i = i + 1;
        end
    end
end

--
function EngravingFrameSearchBox_OnShow(self)
    self:SetText(SEARCH);
    self:SetFontObject("GameFontDisable");
    self.searchIcon:SetVertexColor(0.6, 0.6, 0.6);
    self:SetTextInsets(16, 0, 0, 0);
end

function EngravingFrameSearchBox_OnEditFocusLost(self)
    self:HighlightText(0, 0);
    if ( self:GetText() == "" ) then
        self:SetText(SEARCH);
        self:SetFontObject("GameFontDisable");
        self.searchIcon:SetVertexColor(0.6, 0.6, 0.6);
    end
end

function EngravingFrameSearchBox_OnEditFocusGained(self)
    self:HighlightText();
    if ( self:GetText() == SEARCH ) then
        self:SetFontObject("ChatFontSmall");
        self.searchIcon:SetVertexColor(1.0, 1.0, 1.0);
    end
end

function EngravingFrameSearchBox_OnTextChanged(self)
    local text = self:GetText();

    if ( text == SEARCH ) then
        C_Engraving.SetSearchFilter("");
        return;
    end

    C_Engraving.SetSearchFilter(text);
    EngravingFrame_UpdateRuneList(_G["EngravingFrame"]);
end

-- Todo: Set filter logic
function RuneFrameFilter_Modify(self, arg1)
    if(arg1 == ALL_RUNES_CATEGORY) then
        C_Engraving.ClearExclusiveCategoryFilter();
        C_Engraving.EnableEquippedFilter(false);
    elseif(arg1 == EQUIPPED_RUNES_CATEGORY) then
        C_Engraving.ClearExclusiveCategoryFilter();
        C_Engraving.EnableEquippedFilter(true);
    else
        C_Engraving.AddExclusiveCategoryFilter(arg1);
        C_Engraving.EnableEquippedFilter(false);
    end

    EngravingFrame_UpdateRuneList(_G["EngravingFrame"]);
end

function RuneFrameFilter_Initialize()
    local info = UIDropDownMenu_CreateInfo();
    info.func = RuneFrameFilter_Modify;

    info.text = ALL_RUNES;
    info.checked = C_Engraving.GetExclusiveCategoryFilter() == nil and not C_Engraving.IsEquippedFilterEnabled();
    info.arg1 = ALL_RUNES_CATEGORY;
    UIDropDownMenu_AddButton(info);

    info.text = EQUIPPED_RUNES;
    info.checked = C_Engraving.IsEquippedFilterEnabled();
    info.arg1 = EQUIPPED_RUNES_CATEGORY;
    UIDropDownMenu_AddButton(info);

    local categories = C_Engraving.GetRuneCategories(false, true);
    for _, category in pairs(categories) do
        info.text = category;

        local exclusiveFilter = C_Engraving.GetExclusiveCategoryFilter();
        local checked = false;
        if(exclusiveFilter and exclusiveFilter == category) then
            checked = true;
        end
        info.checked = checked;
        info.arg1 = category;
        UIDropDownMenu_AddButton(info);
    end
end

-- Todo: Set filter logic
function RuneHeader_OnClick (self, button)
    -- PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
    if C_Engraving.HasCategoryFilter(self.filter) then
        C_Engraving.ClearCategoryFilter(self.filter);
    else
        C_Engraving.AddCategoryFilter(self.filter);
    end

    EngravingFrame_UpdateRuneList(_G["EngravingFrame"]);
end

-- Todo: Apply Rune to item
function EngravingFrameSpell_OnClick (self, button)
    C_Engraving.CastRune(self.skillLineAbilityID);
end

function RuneSpellButton_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    -- Todo: Add GameToolTip
    GameTooltip:SetHyperlink("spell:2457")
    self.showingTooltip = true;
    GameTooltip:Show();
end
