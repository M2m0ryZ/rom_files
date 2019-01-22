AuctionSignUpData = class("AuctionSignUpData")

function AuctionSignUpData:ctor(data)
	self:SetData(data)
end

function AuctionSignUpData:SetData(data)
	if data then
		self.itemid = data.itemid
		self.price = data.price
		self.state = AuctionSignUpState.SignUp
		self.needEnchant = data.auction	-- 0:???????????????1:?????????2:????????????
	end
end

function AuctionSignUpData:SetCloseState()
	if self.state ~= AuctionSignUpState.Signed then
		self.state = AuctionSignUpState.Close
	end
end

function AuctionSignUpData:SetState(state)
	self.state = state
end

function AuctionSignUpData:GetItemData()
	if self.itemData == nil then
		self.itemData = ItemData.new("Auction", self.itemid)
	end

	return self.itemData
end

function AuctionSignUpData:CanSignUp()
	return BagProxy.Instance:GetItemNumByStaticID(self.itemid) > 0
end

--????????????????????????????????????
function AuctionSignUpData:IsNeedEnchant()
	return self.needEnchant == 2
end