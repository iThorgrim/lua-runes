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
RUNE_CATEGORIES = {1, 2, 3, 4, 5};
OWNED_CATEGORIES = {1, 3};
SEARCH_FILTER = nil;
ENGRAVING_ENABLED = true;
EXCLUSIVE_CATEGORY_FILTER = nil;
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
    [1] = true,
    [2] = false,
    -- ...
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
    return CATEGORY_FILTERS[category] or false
end

function C_Engraving.isCategoryOwned(category)
    for _, ownedCategory in ipairs(OWNED_CATEGORIES) do
        if ownedCategory == category then
            return true
        end
    end
    return false
end

function C_Engraving.GetRuneCategories(shouldFilter, ownedOnly)
    local categories = {}

    for _, category in ipairs(RUNE_CATEGORIES) do
        if not shouldFilter or C_Engraving.HasCategoryFilter(category) then
            if not ownedOnly or C_Engraving.isCategoryOwned(category) then
                table.insert(categories, category)
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
    -- idk for the moment
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

function EngravingFrame_OnLoad (self)
    self.scrollFrame.update = function() EngravingFrame_UpdateRuneList(self) end;
    self.scrollFrame.scrollBar.doNotHide = true;
    self.scrollFrame.dynamic = EngravingFrame_CalculateScroll;

    HybridScrollFrame_CreateButtons(self.scrollFrame, "RuneSpellButtonTemplate", 0, -1, "TOPLEFT", "TOPLEFT", 0, -1, "TOP", "BOTTOM");
end

function EngravingFrame_OnShow (self)
    SetUIPanelAttribute(CharacterFrame, "width", 560);
    UpdateUIPanelPositions(CharacterFrame);

--[[    C_Engraving.RefreshRunesList(); ]]
    C_Engraving.SetSearchFilter("");

    EngravingFrame_UpdateRuneList(self);

--[[    C_Engraving.SetEngravingModeEnabled(true);]]

    self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
    self:RegisterEvent("NEW_RECIPE_LEARNED");
end

function EngravingFrame_CalculateScroll(offset)
    local heightLeft = offset;

    local i = 1;
    -- TODO: Add categories
    local categories = { };
    for _, category in ipairs(categories) do

        if ( heightLeft - RUNE_HEADER_BUTTON_HEIGHT <= 0 ) then
            return i - 1, heightLeft;
        else
            heightLeft = heightLeft - RUNE_HEADER_BUTTON_HEIGHT;
        end
        i = i + 1;

        -- TODO: Add runes
        local runes = {  };
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

function EngravingFrameSearchBox_OnShow(self)
    self:SetText("Search");
    self:SetFontObject("GameFontDisable");
    self.searchIcon:SetVertexColor(0.6, 0.6, 0.6);
    self:SetTextInsets(16, 0, 0, 0);
end

function EngravingFrameSearchBox_OnEditFocusLost(self)
    self:HighlightText(0, 0);
    if ( self:GetText() == "" ) then
        self:SetText("Search");
        self:SetFontObject("GameFontDisable");
        self.searchIcon:SetVertexColor(0.6, 0.6, 0.6);
    end
end

function EngravingFrameSearchBox_OnEditFocusGained(self)
    self:HighlightText();
    if ( self:GetText() == "Search" ) then
        self:SetFontObject("ChatFontSmall");
        self.searchIcon:SetVertexColor(1.0, 1.0, 1.0);
    end
end

function EngravingFrameSearchBox_OnTextChanged(self)
    local text = self:GetText();

    if ( text == "Search" ) then
        -- C_Engraving.SetSearchFilter("");
        return;
    end

    EngravingFrame_UpdateRuneList(_G["EngravingFrame"]);
end