local addon, ns = ...
local O3 = O3

ns.RepairPanel = O3.UI.Panel:extend({
	height = 30,
	buttons = {},
	createButton = function (self, template)
		local button = O3.UI.IconButton:instance(template)
		if self.lastButton then
			button:point('RIGHT', self.lastButton.frame, 'LEFT', -1, 0)
		else
			button:point('RIGHT', self.frame, 'RIGHT', -2, 0)
		end
		if (id ~= currentFilter) then
			button.icon:SetDesaturated(true)
		end
		self.lastButton = button
	end,
	createRegions = function (self)
		self:createButton({
			parentFrame = self.frame,
			offset = {nil, nil, 2, nil},
			width = self.height-4,
			height = self.height-4,
			icon = "Interface\\Icons\\Trade_blacksmithing",
			onEnter = function (self, control)
				GameTooltip:SetOwner(control, "ANCHOR_RIGHT")
				local repairAllCost, canRepair = GetRepairAllCost()
				if ( canRepair and (repairAllCost > 0) ) then
					GameTooltip:SetText(REPAIR_ALL_ITEMS)
					SetTooltipMoney(GameTooltip, repairAllCost)
				end
				GameTooltip:Show()
			end,
			onLeave = function (self, control) 
				GameTooltip:Hide()
				ResetCursor()
			end,
			onClick = function (button)
				RepairAllItems()
				PlaySound("ITEM_REPAIR")
				
			end,
		})

		self:createButton({
			parentFrame = self.frame,
			offset = {nil, nil, 2, nil},
			width = self.height-4,
			height = self.height-4,
			icon = "Interface\\Icons\\Trade_blacksmithing",
			postInit = function (self)
				self.icon:SetVertexColor(1,1,0)
			end,
			onEnter = function (self, control)
				GameTooltip:SetOwner(control, "ANCHOR_RIGHT")
				local repairAllCost, canRepair = GetRepairAllCost()
				if ( canRepair and (repairAllCost > 0) ) then
					GameTooltip:SetText(REPAIR_ALL_ITEMS)
					SetTooltipMoney(GameTooltip, repairAllCost)
					local amount = GetGuildBankWithdrawMoney()
					local guildBankMoney = GetGuildBankMoney()
					if ( amount == -1 ) then
						amount = guildBankMoney
					else
						amount = min(amount, guildBankMoney)
					end
					GameTooltip:AddLine(GUILDBANK_REPAIR, nil, nil, nil, 1)
					SetTooltipMoney(GameTooltip, amount, "GUILD_REPAIR")
					GameTooltip:Show()
				end
			end,
			onLeave = function (self, control) 
				GameTooltip:Hide()
				ResetCursor()
			end,
			onClick = function (button)
				if(CanGuildBankRepair()) then
					RepairAllItems(true)
					PlaySound("ITEM_REPAIR")
				end
			end,
		})

		self:createButton({
			parentFrame = self.frame,
			offset = {nil, nil, 2, nil},
			width = self.height-4,
			height = self.height-4,
			icon = "Interface\\Icons\\Inv_hammer_20",
			onClick = function (button)
				if ( InRepairMode() ) then
					HideRepairCursor()
				else
					ShowRepairCursor()
				end
			end,
		})				
	end,

})
