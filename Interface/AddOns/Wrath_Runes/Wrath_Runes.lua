local C_Engraving = {};

local Wrath_Runes = {};
-- This function toggles the visibility of the Engraving Frame in the application's UI.
function Wrath_Runes.ToggleEngravingFrame()
    if not C_Engraving.IsEngravingEnabled() then
        return;
    end

    if ( EngravingFrame and EngravingFrame:IsVisible() ) then
        EngravingFrame:Hide();
    else
        if ( not IsAddOnLoaded("Wrath_Runes") ) then
            LoadAddOn("Wrath_Runes");
        end

        EngravingFrame:Show();
    end
end

-- This function refreshes the Rune Frame Control Button on the application's UI.
function Wrath_Runes.RefreshRuneFrameControlButton()
    RuneFrameControlButton:SetChecked(EngravingFrame and EngravingFrame:IsVisible());
end

-- This function is triggered when Rune Frame Control Button is loaded on the application's UI.
-- If engraving is not enabled it hides Rune Frame Control Button
function Wrath_Runes.RuneFrameControlButton_OnLoad(self)
    if not C_Engraving.IsEngravingEnabled() then
        self:Hide();
    end
end

-- This function is triggered when Rune Frame Control Button is shown on the application's UI.
-- It refreshes the Rune Frame Control Button
function Wrath_Runes.RuneFrameControlButton_OnShow(self)
    Wrath_Runes.RefreshRuneFrameControlButton();
end

-- This function is triggered when Rune Frame Control Button is clicked.
-- It toggles the visibility of the Engraving Frame
function Wrath_Runes.RuneFrameControlButton_OnClick(self)
    Wrath_Runes.ToggleEngravingFrame();
end

-- This function generates the Rune Control Button on the application's UI.
function Wrath_Runes.GenerateRuneControlButton()
    local RuneFrameControlButton = CreateFrame("CheckButton", "RuneFrameControlButton", CharacterHandsSlot)
    RuneFrameControlButton:SetSize(32, 32)
    RuneFrameControlButton:SetPoint("BOTTOMRIGHT", CharacterHandsSlot, "TOPRIGHT", 0, 3)

    RuneFrameControlButton:SetNormalTexture("Interface\\Icons\\INV_Misc_Rune_06")
    RuneFrameControlButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    RuneFrameControlButton:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight", "ADD")

    RuneFrameControlButton:SetScript("OnLoad", Wrath_Runes.RuneFrameControlButton_OnLoad)
    RuneFrameControlButton:SetScript("OnShow", Wrath_Runes.RuneFrameControlButton_OnShow)
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
    5, 6, 7, 10
};
OWNED_CATEGORIES = {5, 6, 7, 10};
SEARCH_FILTER = nil;
ENGRAVING_ENABLED = true;
EXCLUSIVE_CATEGORY_FILTER = -1;
EQUIPPED_FILTER_ENABLED = false;
RUNE_INFORMATION = {};
EQUIPMENT_SLOT_ENGRAVINGS = {};
INVENTORY_ENGRAVINGS = {};
CATEGORY_ENGRAVINGS = {
    ["Legs"] = {
        {
            owned = true,
            iconTexture = "INTERFACE\\ICONS\\inv_misc_head_dragon_red",
            name = "Rune 1",
            skillLineAbilityID = 150,
        },
        {
            owned = true,
            iconTexture = "INTERFACE\\ICONS\\ability_parry",
            name = "Rune 2",
            skillLineAbilityID = 150,
        },
        {
            owned = true,
            iconTexture = "INTERFACE\\ICONS\\ability_warrior_innerrage",
            name = "Rune 3",
            skillLineAbilityID = 150,
        },
        {
            owned = true,
            iconTexture = "INTERFACE\\ICONS\\inv_sword_41",
            name = "Rune 4",
            skillLineAbilityID = 150,
        },
        {
            owned = true,
            iconTexture = "INTERFACE\\ICONS\\spell_nature_earthshock",
            name = "Rune 5",
            skillLineAbilityID = 150,
        },
        {
            owned = true,
            iconTexture = "INTERFACE\\ICONS\\ability_paladin_shieldofthetemplar",
            name = "Rune 6",
            skillLineAbilityID = 150,
        },
    },
    ["Chest"] = {
        {
            owned = true,
            iconTexture = "INTERFACE\\ICONS\\inv_misc_head_dragon_red",
            name = "Rune 1",
            skillLineAbilityID = 150,
        },
        {
            owned = true,
            iconTexture = "INTERFACE\\ICONS\\ability_parry",
            name = "Rune 2",
            skillLineAbilityID = 150,
        },
        {
            owned = true,
            iconTexture = "INTERFACE\\ICONS\\ability_warrior_innerrage",
            name = "Rune 3",
            skillLineAbilityID = 150,
        },
        {
            owned = true,
            iconTexture = "INTERFACE\\ICONS\\inv_sword_41",
            name = "Rune 4",
            skillLineAbilityID = 150,
        },
        {
            owned = true,
            iconTexture = "INTERFACE\\ICONS\\spell_nature_earthshock",
            name = "Rune 5",
            skillLineAbilityID = 150,
        },
        {
            owned = true,
            iconTexture = "INTERFACE\\ICONS\\ability_paladin_shieldofthetemplar",
            name = "Rune 6",
            skillLineAbilityID = 150,
        },
    }
};

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

-- This function sets the filter for the search in Engraving Mode.
function C_Engraving.SetSearchFilter(filter)
    SEARCH_FILTER = filter
end

-- This function sets the filter for a specific category in the Engraving Mode.
function C_Engraving.SetCategoryFilter(category, state)
    CATEGORY_FILTERS[category] = state
end

-- This function checks if a specific category is selected in the Engraving Mode.
function C_Engraving.HasCategoryFilter(category)
    -- TODO: Remove this it's a tweaks
    if EXCLUSIVE_CATEGORY_FILTER == -1 then
        return true
    end

    return CATEGORY_FILTERS[category]
end

-- This function checks if a category is owned in the Engraving Mode.
function C_Engraving.isCategoryOwned(category)
    return GetInventoryItemLink("player", category) and true or false
end

-- This function gets the name of a specific category in Engraving Mode.
function C_Engraving.GetCategoryName(category)
    local switch = { [5] ="Chest", [6]= "Waist", [7] ="Legs", [10]= "Hands"}
    return switch[category]
end

-- This is function returns a list of Rune Categories.
-- Should Filter and ownedOnly can be used to filter down the list
function C_Engraving.GetRuneCategories(shouldFilter, ownedOnly)
    local filteredCategories = {}

    for _, category in pairs(RUNE_CATEGORIES) do
        local isCategoryIncluded = not EXCLUSIVE_CATEGORY_FILTER or EXCLUSIVE_CATEGORY_FILTER == -1 or EXCLUSIVE_CATEGORY_FILTER == category
        local addForFilter = not shouldFilter or C_Engraving.HasCategoryFilter(category)
        local addForOwnership = not ownedOnly or C_Engraving.isCategoryOwned(category)
        if isCategoryIncluded and addForFilter and addForOwnership then
            filteredCategories[category] = C_Engraving.GetCategoryName(category)
        end
    end

    return filteredCategories
end

-- This function adds a filter for a specified category.
function C_Engraving.AddCategoryFilter(category)
    CATEGORY_FILTERS[category] = true
end

-- This function adds an exclusive filter for a specified category.
function C_Engraving.AddExclusiveCategoryFilter(category)
    EXCLUSIVE_CATEGORY_FILTER = category
end

-- Method missing, does not actually implement anything.
function C_Engraving.CastRune(skillLineAbilityID)

end

-- This function clears all the category filters set in the Engraving mode.
function C_Engraving.ClearAllCategoryFilters()
    for category in pairs(CATEGORY_FILTERS) do
        C_Engraving.ClearCategoryFilter(category)
    end
end

-- This function clears the filter for a specific category in the Engraving mode.
function C_Engraving.ClearCategoryFilter(category)
    CATEGORY_FILTERS[category] = nil
end

-- This function removes the exclusive category filter set in the Engraving mode.
function C_Engraving.ClearExclusiveCategoryFilter()
    EXCLUSIVE_CATEGORY_FILTER = -1
end

-- This function enables or disables the equipped filter in the Engraving mode.
function C_Engraving.EnableEquippedFilter(enabled)
    EQUIPPED_FILTER_ENABLED = enabled
end

-- Method missing, does not actually implement anything.
function C_Engraving.GetCurrentRuneCast()
    -- idk for the moment
end

-- Method missing, does not actually implement anything.
function C_Engraving.GetEngravingModeEnabled()
    -- idk for the moment
end

-- This function returns the exclusive category filter set in the Engraving mode.
function C_Engraving.GetExclusiveCategoryFilter()
    return EXCLUSIVE_CATEGORY_FILTER
end

-- This function returns the number of known Runes for a specific equipment slot.
function C_Engraving.GetNumRunesKnown(equipmentSlot)
    if equipmentSlot == nil or RUNE_INFORMATION[equipmentSlot] == nil then
        return 0, 0
    end
    return RUNE_INFORMATION[equipmentSlot].known, RUNE_INFORMATION[equipmentSlot].max
end

-- This function returns the Rune for a specific equipment slot.
function C_Engraving.GetRuneForEquipmentSlot(equipmentSlot)
    return EQUIPMENT_SLOT_ENGRAVINGS[equipmentSlot];
end

-- This function returns the Rune for a specific inventory slot.
function C_Engraving.GetRuneForInventorySlot(containerIndex, slotIndex)
    if INVENTORY_ENGRAVINGS[containerIndex] and INVENTORY_ENGRAVINGS[containerIndex][slotIndex] then
        return INVENTORY_ENGRAVINGS[containerIndex][slotIndex]
    else
        return nil
    end
end

-- This function returns all the Runes for a specific category.
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

-- This function checks if a specific equipment slot can be engraved.
function C_Engraving.IsEquipmentSlotEngravable(equipmentSlot)
    return EQUIPMENT_ENGRAVABLE_SLOTS[equipmentSlot] or false;
end

-- This function checks if equipped filter is enabled in the Engraving mode.
function C_Engraving.IsEquippedFilterEnabled()
    return EQUIPMENT_FILTER_ENABLED;
end

-- This function checks if a specific inventory slot can be engraved.
function C_Engraving.IsInventorySlotEngravable(containerIndex, slotIndex)
    return CONTAINER_SLOT_ENGRAVINGS[containerIndex] and CONTAINER_SLOT_ENGRAVINGS[containerIndex][slotIndex] or false
end

-- This function checks if a specific inventory slot can be engraved by the current Rune cast.
function C_Engraving.IsInventorySlotEngravableByCurrentRuneCast(containerIndex, slotIndex)
    return containerIndex == CURRENT_RUNE_CAST.containerIndex and slotIndex == CURRENT_RUNE_CAST.slotIndex
end

-- This function checks if a specific Rune spell is known.
function C_Engraving.IsKnownRuneSpell(spellID)
    return IsSpellKnown(spellID)
end

-- Method missing, does not actually implement anything.
function C_Engraving.IsRuneEquipped(skillLineAbilityID)
    -- idk for the moment
end

-- Method missing, does not actually implement anything.
function C_Engraving.RefreshRunesList()
    -- idk for the moment
end

-- Method missing, does not actually implement anything.
function C_Engraving.SetEngravingModeEnabled(enabled)
    -- idk for the moment
end

-- Method missing, does not actually implement anything.
function  C_Engraving.EngravingModeChanged(enabled)
    -- idk for the moment
end

-- Method missing, does not actually implement anything.
function  C_Engraving.EngravingTargetingModeChanged(enabled)
    -- idk for the moment
end

-- Method missing, does not actually implement anything.
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

-- This function executes when the Engraving Frame is loaded. It creates Buttons for the Hybrid Scroll Frame
function EngravingFrame_OnLoad (self)
    self.scrollFrame.update = function() EngravingFrame_UpdateRuneList(self) end;
    self.scrollFrame.scrollBar.doNotHide = true;
--[[
    self.scrollFrame.dynamic = EngravingFrame_CalculateScroll;
]]

    HybridScrollFrame_CreateButtons(self.scrollFrame, "RuneSpellButtonTemplate", 0, -1, "TOPLEFT", "TOPLEFT", 0, -1, "TOP", "BOTTOM");
end

-- This function executes when the Engraving Frame gets visible. It registers specific events and enables the Engraving Mode
function EngravingFrame_OnShow (self)
    C_Engraving.RefreshRunesList();

    C_Engraving.SetSearchFilter("");

    EngravingFrame_UpdateRuneList(self);

    C_Engraving.SetEngravingModeEnabled(true);

    self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
    self:RegisterEvent("NEW_RECIPE_LEARNED");
end

-- This function executes when the Engraving Frame gets hidden. It unregisters specific events and disables the Engraving Mode
function EngravingFrame_OnHide (self)
    self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED");
    self:UnregisterEvent("NEW_RECIPE_LEARNED");

    SetUIPanelAttribute(CharacterFrame, "width", 353);
    UpdateUIPanelPositions(CharacterFrame);

    C_Engraving.SetEngravingModeEnabled(false);
end

-- This function executes when specific events are dispatched to the Engraving Frame. Currently it handles PLAYER_EQUIPMENT_CHANGED and NEW_RECIPE_LEARNED
function EngravingFrame_OnEvent(self, event, ...)
    if ( event == "PLAYER_EQUIPMENT_CHANGED" ) then
        EngravingFrame_UpdateRuneList(self);
    elseif ( event == "NEW_RECIPE_LEARNED") then
        EngravingFrame_UpdateRuneList(self);
    end
end

-- This function hides all headers in Engraving Frame
function EngravingFrame_HideAllHeaders()
    local currentHeader = 1;
    local header = _G["EngravingFrameHeader"..currentHeader];
    while header do
        header:Hide();
        currentHeader = currentHeader + 1;
        header = _G["EngravingFrameHeader"..currentHeader];
    end
end

function TableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

-- Todo: It's logic filter
-- This function updates the Rune List displayed in the Engraving Frame
function EngravingFrame_UpdateRuneList (self)
    local numHeaders = 0;
    local numRunes = 0;
    local scrollFrame = EngravingFrame.scrollFrame;
    local buttons = scrollFrame.buttons;
    local offset = HybridScrollFrame_GetOffset(scrollFrame);
    --[[EngravingFrame_CalculateScroll(offset)]]
    local currOffset = 0;

    local currentHeader = 1;
    EngravingFrame_HideAllHeaders();

    local currButton = 1;
    local categories = C_Engraving.GetRuneCategories(true, true);
    numHeaders = TableLength(categories);

    for _, category in pairs(categories) do
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
                    header.name:SetText(category);

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
        for _, rune in pairs(runes) do
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
-- This function updates the collected label displayed in the Engraving Frame
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
-- Rework EngravingFrame_CalculateScroll for making scroll complete
--[[function EngravingFrame_CalculateScroll(offset)
    local heightLeft = offset;
    print('ok')
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
        for _, rune in pairs(runes) do
            if ( heightLeft - RUNE_BUTTON_HEIGHT <= 0 ) then
                return i - 1, heightLeft;
            else
                heightLeft = heightLeft - RUNE_BUTTON_HEIGHT;
            end
            i = i + 1;
        end
    end
end]]

-- This function executes when search box is shown. It sets specific properties for the search box.
function EngravingFrameSearchBox_OnShow(self)
    self:SetText(SEARCH);
    self:SetFontObject("GameFontDisable");
    self.searchIcon:SetVertexColor(0.6, 0.6, 0.6);
    self:SetTextInsets(16, 0, 0, 0);
end

-- This function executes when search box loses focus. It sets specific properties for the search box.
function EngravingFrameSearchBox_OnEditFocusLost(self)
    self:HighlightText(0, 0);
    if ( self:GetText() == "" ) then
        self:SetText(SEARCH);
        self:SetFontObject("GameFontDisable");
        self.searchIcon:SetVertexColor(0.6, 0.6, 0.6);
    end
end

-- This function executes when search box gains focus. It sets specific properties for the search box.
function EngravingFrameSearchBox_OnEditFocusGained(self)
    self:HighlightText();
    if ( self:GetText() == SEARCH ) then
        self:SetFontObject("ChatFontSmall");
        self.searchIcon:SetVertexColor(1.0, 1.0, 1.0);
    end
end

-- This function executes when text is changed in the search box. It sets the search filter in Engraving Mode.
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
-- This function modifies the filter for Rune Frame
function RuneFrameFilter_Modify(self, arg1)
    if(arg1 == ALL_RUNES_CATEGORY) then
        C_Engraving.ClearExclusiveCategoryFilter();
        C_Engraving.EnableEquippedFilter(false);
    elseif(arg1 == EQUIPPED_RUNES_CATEGORY) then
        C_Engraving.ClearExclusiveCategoryFilter();
        C_Engraving.EnableEquippedFilter(true);
    else
        C_Engraving.EnableEquippedFilter(false);
        C_Engraving.AddExclusiveCategoryFilter(arg1);
    end

    EngravingFrame_UpdateRuneList(_G["EngravingFrame"]);
end

-- This function initializes the filter for Rune Frame
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
    for _, category in ipairs(categories) do
        info.text = GetItemInventorySlotInfo(category);

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
-- This function executes when a header is clicked. It toggles the visibility of specific headers.
function RuneHeader_OnClick (self, button)
    -- PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
    if C_Engraving.HasCategoryFilter(self.filter) then
        print(self.filter)
        C_Engraving.ClearCategoryFilter(self.filter);
    else
        print("Add", self.filter)
        C_Engraving.AddCategoryFilter(self.filter);
    end

    EngravingFrame_UpdateRuneList(_G["EngravingFrame"]);
end

-- Todo: Apply Rune to item
-- This function executes when an Engraving Frame Spell is clicked. It initiates the process to cast a specific Rune.
function EngravingFrameSpell_OnClick (self, button)
    C_Engraving.CastRune(self.skillLineAbilityID);
end

-- This function executes when Rune Spell Button is hovered. It displays a specific tooltip.
function RuneSpellButton_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    -- Todo: Add GameToolTip
    GameTooltip:SetHyperlink("spell:2457")
    self.showingTooltip = true;
    GameTooltip:Show();
end
