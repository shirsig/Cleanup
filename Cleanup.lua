local _G, _M = getfenv(0), {}
setfenv(1, setmetatable(_M, {__index=_G}))

do
	local f = CreateFrame'Frame'
	f:SetScript('OnEvent', function(self, event, ...) _M[event](self, ...) end)
	f:RegisterEvent'ADDON_LOADED'
end

_G.Cleanup = {
	BAGS = {},
	BANK = {},
}

BAGS = {
	FUNCTION = SortBags,
	TOOLTIP = 'Clean Up Bags',
}

BANK = {
	FUNCTION = SortBankBags,
	TOOLTIP = 'Clean Up Bank',
}

_G.SLASH_CLEANUPBAGS1 = '/cleanupbags'
function _G.SlashCmdList.CLEANUPBAGS(arg)
	buttonPlacer.key = 'BAGS'
	buttonPlacer:Show()
end

_G.SLASH_CLEANUPBANK1 = '/cleanupbank'
function _G.SlashCmdList.CLEANUPBANK(arg)
	buttonPlacer.key = 'BANK'
	buttonPlacer:Show()
end

function ADDON_LOADED(_, arg1)
	if arg1 ~= 'Cleanup' then
		return
	end

	CreateButtonPlacer()
	CreateButton'BAGS'
	CreateButton'BANK'
end

function CleanupButton(parent)
	local button = CreateFrame('Button', nil, parent)
	button:SetWidth(28)
	button:SetHeight(26)
	button:SetNormalTexture[[Interface\AddOns\Cleanup\Bags]]
	button:GetNormalTexture():SetTexCoord(.12109375, .23046875, .7265625, .9296875)
	button:SetPushedTexture[[Interface\AddOns\Cleanup\Bags]]
	button:GetPushedTexture():SetTexCoord(.00390625, .11328125, .7265625, .9296875)
	button:SetHighlightTexture[[Interface\Buttons\ButtonHilight-Square]]
	button:GetHighlightTexture():ClearAllPoints()
	button:GetHighlightTexture():SetPoint('CENTER', 0, 0)
	button:GetHighlightTexture():SetWidth(24)
	button:GetHighlightTexture():SetHeight(23)
	return button
end

function CreateButton(key)
	local settings = Cleanup[key]
	local button = CleanupButton()
	_M[key].button = button
	button:SetScript('OnUpdate', function(self)
		if settings.parent and getglobal(settings.parent) then
			UpdateButton(key)
			self:SetScript('OnUpdate', nil)
		end
	end)
	button:SetScript('OnClick', function()
		PlaySoundFile[[Interface\AddOns\Cleanup\UI_BagSorting_01.ogg]]
		_M[key].FUNCTION()
	end)
	button:SetScript('OnEnter', function(self)
		GameTooltip:SetOwner(self)
		GameTooltip:AddLine(_M[key].TOOLTIP)
		GameTooltip:Show()
	end)
	button:SetScript('OnLeave', function()
		GameTooltip:Hide()
	end)
end

function UpdateButton(key)
	local button, settings = _M[key].button, Cleanup[key]
	button:SetParent(settings.parent)
	button:SetPoint('CENTER', unpack(settings.position))
	button:SetScale(settings.scale)
	button:Show()
end

function CollectFrames()
	frames = {}
	local f
	while true do
		f = EnumerateFrames(f)
		if not f then break end
		if f.GetName and f:GetName() and f.IsVisible and f:IsVisible() and f.GetCenter and f:GetCenter() then
			tinsert(frames, f)
		end
	end	
end

function CreateButtonPlacer()
	local frame = CreateFrame('Frame', nil, UIParent)
	buttonPlacer = frame
	frame:EnableMouse(true)
	frame:EnableMouseWheel(true)
	frame:EnableKeyboard(true)
	frame:SetFrameStrata'FULLSCREEN_DIALOG'
	frame:SetAllPoints()
	frame:Hide()
	local targetMarker = frame:CreateTexture()
	targetMarker:SetColorTexture(1, 1, 0, .5)

	local buttonPreview = CleanupButton(frame)
	buttonPreview:EnableMouse(false)
	buttonPreview:SetAlpha(.5)

	local function target(self)
		local f = frames[frame.index]
		frame.target = f
		local scale, x, y = f:GetEffectiveScale(), GetCursorPosition()
		targetMarker:SetAllPoints(f)
		buttonPreview:SetScale(scale * self.scale)
		RaidNotice_Clear(RaidWarningFrame)
		RaidNotice_AddMessage(RaidWarningFrame, f:GetName(), ChatTypeInfo["SAY"])
	end

	frame:SetScript('OnShow', function(self)
		self.scale = 1
		self.index = 1
		CollectFrames()
		target(self)
	end)
	frame:SetScript('OnKeyDown', function(self, arg1) if arg1 == 'ESCAPE' then self:Hide() end end)
	frame:SetScript('OnMouseWheel', function(self, arg1)
		if IsControlKeyDown() then
			self.scale = max(0, self.scale + arg1 * .05)
			buttonPreview:SetScale(self.target:GetEffectiveScale() * self.scale)
		else
			self.index = self.index + arg1
			if self.index < 1 then
				self.index = #frames
			elseif self.index > #frames then
				self.index = 1
			end
			target(self)
		end
	end)
	frame:SetScript('OnMouseDown', function(self)
		self:Hide()
		local x, y = GetCursorPosition()
		local targetScale, targetX, targetY = self.target:GetEffectiveScale(), self.target:GetCenter()
		Cleanup[self.key] = {parent=self.target:GetName(), position={(x/targetScale-targetX)/self.scale, (y/targetScale-targetY)/self.scale}, scale=self.scale}
		UpdateButton(self.key)
	end)
	frame:SetScript('OnUpdate', function()
		local scale, x, y = buttonPreview:GetEffectiveScale(), GetCursorPosition()
		buttonPreview:SetPoint('CENTER', UIParent, 'BOTTOMLEFT', x/scale, y/scale)
	end)
end