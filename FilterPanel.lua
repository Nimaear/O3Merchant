local addon, ns = ...
local O3 = O3

ns.FilterPanel = O3.UI.Panel:extend({
	height = 30,
	buttons = {},
	merchantWindow = nil,
	style = function (self)
		self:createTexture({
			layer = 'BACKGROUND',
			file = O3.Media:texture('Background'),
			tile = true,
			color = {147/255, 153/255, 159/255, 0.95},
			offset = {1,1,1,1},
		})
		self:createOutline({
			layer = 'BORDER',
			gradient = 'VERTICAL',
			color = {1, 1, 1, 0.03 },
			colorEnd = {1, 1, 1, 0.05 },
			offset = {1, 1, 1, 1},
			-- width = 2,
			-- height = 2,
		})
		self:createOutline({
			layer = 'BORDER',
			gradient = 'VERTICAL',
			color = {0, 0, 0, 1 },
			colorEnd = {0, 0, 0, 1 },
			offset = {0, 0, 0, 0 },
		})
	end,
	createButton = function (self, id, currentFilter, description, icon)
		local button = O3.UI.IconButton:instance({
			id = id,
			parentFrame = self.frame,
			offset = {nil, nil, 2, nil},
			width = self.height-4,
			height = self.height-4,
			icon = icon,
			onEnter = function (self, control)
				GameTooltip:SetOwner(control, "ANCHOR_RIGHT")
				GameTooltip:AddLine(description, 1, 1, 1)
				CursorUpdate(control)
				GameTooltip:Show()
			end,
			onLeave = function (self, control) 
				GameTooltip:Hide()
				ResetCursor()
			end,
			onClick = function (button)
				self:choose(button.id)
			end,
		})
		if self.lastButton then
			button:point('RIGHT', self.lastButton.frame, 'LEFT', -1, 0)
		else
			button:point('RIGHT', self.frame, 'RIGHT', -2, 0)
		end
		if (id ~= currentFilter) then
			button.icon:SetDesaturated(true)
		end
		self.buttons[id] =  button
		self.lastButton = button
	end,
	choose = function (self, id)
		local currFilter = GetMerchantFilter()
		self.buttons[currFilter].icon:SetDesaturated(true)

		SetMerchantFilter(id)
		self.buttons[id].icon:SetDesaturated(false)
		self:callback(id)
	end,
	callback = function (self)
	end,
	createRegions = function (self)
		local currentFilter = GetMerchantFilter()

		local className, classToken = UnitClass("player")
		-- specs
		-- LE_LOOT_FILTER_SPEC1
		-- 
		local numSpecs = GetNumSpecializations()
		for i = 1, numSpecs do
			local _, name, _, icon = GetSpecializationInfo(i)
			self:createButton(LE_LOOT_FILTER_SPEC1+i-1, currentFilter, name, icon)
		end

		local texture = self.frame:CreateTexture()
		texture:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
		texture:SetTexCoord(CLASS_ICON_TCOORDS[classToken][1]+0.03, CLASS_ICON_TCOORDS[classToken][2]-0.03, CLASS_ICON_TCOORDS[classToken][3]+0.03, CLASS_ICON_TCOORDS[classToken][4]-0.03)

		-- Class
		-- LE_LOOT_FILTER_CLASS
		self:createButton(LE_LOOT_FILTER_CLASS, currentFilter, className, texture)


		-- Boe
		-- LE_LOOT_FILTER_BOE 
		self:createButton(LE_LOOT_FILTER_BOE, currentFilter, 'BoE', "Interface\\Icons\\inv_misc_gift_01")

		-- All
		-- LE_LOOT_FILTER_ALL
		self:createButton(LE_LOOT_FILTER_ALL, currentFilter, 'All', "Interface\\Icons\\Trade_engineering")	

		self.filterText = O3.UI.EditBox:instance({
			parentFrame = self.frame,
			offset = {2, nil, 2, 2},
			width = 150,
			onEnterPressed = function (editBox)
				self:filter(editBox.frame:GetText())
			end,
		})
	end,
	setFilterText = function (self, text)
		self.filterText.frame:SetText(text)
	end,
	filter = function (self)
	end,
})