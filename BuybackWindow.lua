local addon, ns = ...
local O3 = O3
local UI = O3.UI

ns.BuybackWindow = UI.ItemListWindow:extend({
	settings = {
		itemHeight = 26,
		itemsBottomGap = 0,
		itemsTopGap = 0,
		footerHeight = 22,
	},
	itemCount = 10,
	width = 250,
	name = 'BuyBack',
	title = 'O3 Buyback',
	offset = {100, nil, 100, nil},
	managed = true,
	getNumItems = function (self)
		self.numItems = GetNumBuybackItems()
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
							offset = {2, 60, 2, nil},
							height = 12,
							justifyV = 'TOP',
							justifyH = 'LEFT',
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
						panel.buyBackButton = O3.UI.Button:instance({
							parentFrame = panel.frame,
							color = {0.1, 0.8, 0.1},
							offset = {nil, 1, 1, 1},
							width = 60,
							text = 'Buyback',
							onClick = function (button)
								BuybackItem(item.id)
							end,
						})
					end,
				})
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
					GameTooltip:SetBuybackItem(item.id)
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

		local name, texture, price, quantity, numAvailable, isUsable = GetBuybackItemInfo(id)
		item.id = id
		-- local maxStack = GetMerchantItemMaxStack(id)
		item.button:setTexture(texture)
		item.name:SetText(name)
		item.itemName = name
		if quantity > 1 then
			item.countText:SetText(quantity)
		else
			item.countText:SetText(nil)
		end

		local itemLink = GetBuybackItemLink(id)

		if itemLink then
			local itemName, _, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice =  GetItemInfo(itemLink)
			local r, g, b, hex = GetItemQualityColor(itemRarity or 0)
			item.r = r
			item.g = g
			item.b = b
			item.bg:SetTexture(r,g,b, 0.4)
			item.bg:SetVertexColor(r,g,b, 0.4)
		end
	end,
	onShow = function (self)
		self.handler:registerEvent('MERCHANT_UPDATE', self)
	end,
	onHide = function (self)
		self.handler:unregisterEvent('MERCHANT_UPDATE', self)
	end,
	MERCHANT_UPDATE = function (self)
		self:reset()
	end,	
	onHide = function (self)
	end,
})
