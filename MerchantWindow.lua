local addon, ns = ...
local O3 = O3
local UI = O3.UI

ns.MerchantWindow = UI.ItemListWindow:extend({
	_weight = 99,
	settings = {
		itemHeight = 26,
		itemsBottomGap = 0,
		footerHeight = 32,
	},
	name = 'Trainer',
	title = 'O3 Trainer',	
	offset = {100, nil, 100, nil},
	managed = true,
	filterText = '',
	getNumItems = function (self)
		self.numItems = GetMerchantNumItems()
	end,
	createItem = function (self)
		local itemHeight = self.settings.itemHeight
		local item = self.content:createPanel({
			type = 'Button',
			offset = {2, 2, nil, nil},
			height = itemHeight,
			createRegions = function (item)
				item.button = O3.UI.IconButton:instance({
					parent = item,
					icon = nil,
					parentFrame = item.frame,
					height = itemHeight,
					width = itemHeight,
					onClick = function (item)
						if (item.parent.onIconClick) then
							item.parent:onIconClick()
						end
					end,
					createRegions = function (item)
						item.count = item:createFontString({
							offset = {2, nil, 2, nil},
							fontFlags = 'OUTLINE',
							text = nil,
							-- shadowOffset = {1, -1},
							fontSize = 12,
						})
					end,					
				})
				item.button:point('TOPLEFT')
				item.panel = item:createPanel({
					offset = {itemHeight+2, 0, 0, 0},
					style = function (panel)
						panel.name = panel:createFontString({
							offset = {2, 85, 2, nil},
							height = 12,
							justifyV = 'TOP',
							justifyH = 'LEFT',
						})
						panel.cost = panel:createFontString({
							offset = {2, 85, nil, 2},
							height = 10,
							justifyV = 'middle',
							justifyH = 'RIGHT',
						})

						panel:createOutline({
							layer = 'BORDER',
							gradient = 'VERTICAL',
							color = {1, 1, 1, 0.03 },
							colorEnd = {1, 1, 1, 0.05 },
							offset = {0, 0, 0, 0},
							-- width = 2,
							-- height = 2,
						})	
						panel.highlight = panel:createTexture({
							layer = 'ARTWORK',
							gradient = 'VERTICAL',
							color = {0,1,1,0.10},
							colorEnd = {0,0.5,0.5,0.20},
							offset = {1,1,1,1},
						})
						panel.highlight:Hide()						
						panel.buyButton = O3.UI.Button:instance({
							parentFrame = panel.frame,
							color = {0.1, 0.8, 0.1},
							offset = {nil, 1, 1, 1},
							width = 40,
							text = 'Buy',
							onClick = function (button)
								local buyCount = item.buyCount
								local index = item.id
								local maxStack = GetMerchantItemMaxStack(index)
								if (buyCount > maxStack) then
									while buyCount > 0 do
										BuyMerchantItem(index, maxStack)
										buyCount = buyCount - maxStack
									end
								else
									BuyMerchantItem(index, buyCount)
								end
							end,
						})
						panel.buyCountControl = O3.UI.EditBox:instance({
							parentFrame = panel.frame,
							offset = {nil, nil, 1, 1},
							width = 40,
							hook = function (buyCountControl)
								buyCountControl._parent.hook(buyCountControl)
								buyCountControl.frame:SetScript('OnChar', function (control)
									item.buyCount = control:GetNumber() or 1
									print(item.buyCount)
								end)
							end,
						})
						panel.buyCountControl:point('RIGHT', panel.buyButton.frame, 'LEFT', -1, 0)
					end,
				})
				item.buyCountControl = item.panel.buyCountControl
				item.cost = item.panel.cost
				item.name = item.panel.name
				item.countText = item.button.count
			end,
			style = function (self)
				self.bg = self:createTexture({
					layer = 'BACKGROUND',
					subLayer = -7,
					color = {0, 0, 0, 0.95},
					-- offset = {0, 0, 0, nil},
					-- height = 1,
				})
			end,
			hook = function (item)
				item.frame:SetScript('OnEnter', function (frame)
					item.panel.highlight:Show()
					GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
					GameTooltip:SetMerchantItem(item.id)
					CursorUpdate(frame)
					GameTooltip:Show()


					
					if (item.onEnter) then
						item:onEnter()
					end
				end)
				item.frame:SetScript('OnLeave', function (frame)
					GameTooltip:Hide()
					ResetCursor()

					item.panel.highlight:Hide()
					if (item.onLeave) then
						item:onLeave()
					end
				end)
				item.frame:SetScript('OnClick', function (frame)
					BuyTrainerService(item.id)
					if (item.onClick) then
						item:onClick()
					end
				end)
			end,
		})
		return item
	end,	
	updateItem = function (self, item, id)
		local name, texture, price, quantity, numAvailable, isUsable, extendedCost = GetMerchantItemInfo(id)
		local maxStack = GetMerchantItemMaxStack(id)
		item.button:setTexture(texture)
		item.name:SetText(name)
		item.id = id
		item.itemName = name
		if quantity > 1 then
			item.countText:SetText(quantity)
		else
			item.countText:SetText(nil)
		end
		item.buyCount = maxStack
		item.buyCountControl.frame:SetText(maxStack)
		local itemLink = GetMerchantItemLink(id)
		if extendedCost then
			local currencyCount = GetMerchantItemCostInfo(id)
			local currencyString = ''
			for currencyIndex = 1, currencyCount do
				
				local texture, value, link, name = GetMerchantItemCostItem(id, currencyIndex)
				if texture then
					currencyString = currencyString .. value .. ' |T'..texture..':0|t'
				end
			end
			item.cost:SetText(currencyString)

		else
			item.cost:SetText(GetCoinTextureString(price))
		end
		if itemLink then
			local itemName, _, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice =  GetItemInfo(itemLink)
			local r, g, b, hex = GetItemQualityColor(itemRarity or 0)
			item.r = r
			item.g = g
			item.b = b
			item.bg:SetTexture(r,g,b, 0.4)
			item.bg:SetVertexColor(r,g,b, 0.4)
		end
		self:checkItemForFilter(item)
	end,
	filter = function (self, filterText)
		self.filterText = filterText
		for i = 1, self.itemCount do
			local item = self.items[i]
			if item.frame:IsVisible() then
				self:checkItemForFilter(item)
			end
		end
	end,
	checkItemForFilter = function (self, item)
		if  self.filterText == "" or string.find(item.itemName:lower(), self.filterText:lower()) then
			item.frame:SetAlpha(1)
		else
			item.frame:SetAlpha(0.3)
		end
	end,		
	postCreate = function (self)
		self.bar = UI.ScrollBar:instance({
			width = 11,
			parentFrame = self.content.frame,
			offset = {nil, -11, 0, 0},
		})
		self.filterPanel = ns.FilterPanel:instance({
			height = self.settings.itemsTopGap,
			parentFrame = self.frame,
			offset = {0, 0, self.settings.headerHeight-1, nil},
			callback = function ()
				self:reset()
			end,
			filter = function (filterPanel, text)
				self:filter(text)
			end,
		})
		self.repairPanel = ns.RepairPanel:instance({
			frame = self.footer.frame,
			height = self.settings.footerHeight,
			callback = function ()
				self:reset()
			end,
		})
		self._offset = 0
		self:createItems()
		self:createHeaderButtons()
		self:reset()
	end,
	createHeaderButtons = function (self)
		self.header:addButton(O3.UI.GlyphButton:instance({
			parentFrame = self.header.frame,
			width = 20,
			height = 20,
			text = '',
			onClick = function ()
				if not self.buybackWindow then
					self.buybackWindow = ns.BuybackWindow:instance({
						handler = self.handler,
						
					})
				end
				self.buybackWindow:show()
				self.buybackWindow:reset()
			end,
		}))	
	end,
	onShow = function (self)
		self.handler:registerEvent('MERCHANT_UPDATE', self)
		self.filterText = ''
		self.filterPanel:setFilterText('')
		if CanMerchantRepair() then
			self.repairPanel:show()
		else
			self.repairPanel:hide()
		end
		self:MERCHANT_UPDATE()
	end,
	MERCHANT_UPDATE = function (self)
		-- if GetNumBuybackItems() > 0 then
		-- 	self.buybackControl:Show()
		-- else
		-- 	self.buybackControl:Hide()
		-- end
		self:scrollTo(self._offset)
	end,
	onHide = function (self)
		self.handler:unregisterEvent('MERCHANT_UPDATE', self)
		CloseMerchant()
		if (self.buybackWindow) then
			self.buybackWindow:hide()
		end
	end,
})
