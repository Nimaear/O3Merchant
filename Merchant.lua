local addon, ns = ...
local O3 = O3

O3:module({
	name = 'Merchant',
	readable = 'Merchant',
    weight = 97,
	config = {
		enabled = true,
        font = O3.Media:font('Normal'),
        fontSize = 12,
        fontStyle = 'THINOUTLINE',
        autoLoot = false,
		xOffset = 0,
		yOffset = 100,
		anchor = 'CENTER',
		anchorTo = 'CENTER',
        repair = true,
        guildBankRepair = true,
        sellGrays = true,
	},        
	events = {
		MERCHANT_SHOW = true,
		MERCHANT_CLOSED = true,
	},
	settings = {
	},
	addOptions = function (self)
        self:addOption('_0', {
            type = 'Title',
            label = 'Options',
        })
        self:addOption('autoLoot', {
            type = 'Toggle',
            label = 'Auto loot',
        })
        self:addOption('_1', {
            type = 'Title',
            label = 'Font',
        })
        self:addOption('font', {
            type = 'FontDropDown',
            label = 'Font',
        })
        self:addOption('fontSize', {
            type = 'Range',
            min = 6,
            max = 20,
            step = 1,
            label = 'Font size',
        })

        self:addOption('fontStyle', {
            type = 'DropDown',
            label = 'Outline',
            _values = O3.Media.fontStyles,
        })
        self:addOption('_2', {
        	type = 'Title',
        	label = 'Loot Roll'
        })
        self:addOption('anchor', {
            type = 'DropDown',
            label = 'Point',
            setter = 'anchorSet',
            _values = O3.UI.anchorPoints
        })
        self:addOption('anchorTo', {
            type = 'DropDown',
            label = 'To Point',
            setter = 'anchorSet',
            _values = O3.UI.anchorPoints
        })        
		self:addOption('xOffset', {
			type = 'Range',
			label = 'Horizontal',
			setter = 'anchorSet',
			bag = self,
			min = -500,
			max = 500,
			step = 5,
		})
		self:addOption('yOffset', {
			type = 'Range',
			label = 'Vertical',
			setter = 'anchorSet',
			min = -500,
			max = 500,
			step = 5,
		})		
        self:addOption('_3', {
        	type = 'Title',
        	label = 'Pleasure'
        })
        self:addOption('sellGrays', {
            type = 'Toggle',
            label = 'Sell grays to the vendor',
        })
        self:addOption('repair', {
            type = 'Toggle',
            label = 'Repair when you visit a vendor',
        })
        self:addOption('guildBankRepair', {
            type = 'Toggle',
            label = 'Use guildbank to pay for repairs when possible',
        })

	end,
	anchorSet = function (self)
		self.merchantWindow:SetPoint(self.settings.anchor, UIParent, self.settings.anchorTo, self.settings.xOffset, self.settings.yOffset)
	end,
	MERCHANT_CLOSED = function (self)
		self.merchantWindow:hide()
        self.open = false
	end,
    postInit = function (self)
        O3:destroy(MerchantFrame)
    end,
	MERCHANT_SHOW = function (self)
        self.open = true
        if (not self.merchantWindow) then
            self.merchantWindow = ns.MerchantWindow:instance({
                handler = self,
            })
        end
		self.merchantWindow:show()
		self.merchantWindow:setTitle('Merchant', UnitName("target"))
		self.merchantWindow:reset()
        if (self.settings.repair) then
            self:repair()
        end
        if (self.settings.sellGrays) then
            self:sellGrays()
        end		
	end,
    repair = function (self)
        if CanMerchantRepair() then
            local cost = GetRepairAllCost()
            local amount = GetGuildBankWithdrawMoney()
            local guildBankMoney = GetGuildBankMoney()
            if ( amount == -1 ) then
                amount = guildBankMoney
            else
                amount = min(amount, guildBankMoney)
            end
            if (self.settings.guildBankRepair and CanGuildBankRepair() and cost > 0 and amount >= cost) then
                RepairAllItems(true)
                -- O3.Notification:info("Auto-repaired equipment for "..O3:formatMoney(cost).." using guild money.")
            elseif cost > 0 then
                if GetMoney() > cost and cost > 0 then                   
                    local g, s, c = math.floor(cost/10000) or 0, math.floor((cost%10000)/100) or 0, cost%100
                    -- O3.Notification:info("Auto-repaired equipment for "..O3:formatMoney(cost)..".")
                else
                    -- O3.Notification:info("Can not afford repair bill of "..O3:formatMoney(cost)..".")
                end               
            end
        end

    end,
    sellGrays = function (self)
        local c = 0
        for b=0,4 do
            for s=1,GetContainerNumSlots(b) do
                local l = GetContainerItemLink(b, s)
                if l then
                    local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(l)
                    local texture, count, locked, quality, readable, lootable, link, isFiltered  = GetContainerItemInfo(b, s)
                    if quality == 0 and vendorPrice then
                        local p = vendorPrice * count
                        UseContainerItem(b, s)
                        PickupMerchantItem()
                        c = c+p
                    end
                end
            end
        end
        if c>0 then
            -- O3.Notification:info("Your vendor trash has been sold and you earned "..O3:formatMoney(c)..".")
        end 
    end,	
})