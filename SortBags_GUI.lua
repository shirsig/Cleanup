local _G, _M = getfenv(0), {}
setfenv(1, setmetatable(_M, {__index=_G}))

do
	local f = CreateFrame'Frame'
	f:SetScript('OnEvent', function() _M[event](this) end)
	f:RegisterEvent'ADDON_LOADED'
end

_G.SortBags_GUI = {
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

_G.SLASH_SORTBAGS1 = '/sortbags'
function _G.SlashCmdList.SORTBAGS(arg)
	buttonPlacer.key = 'BAGS'
	buttonPlacer:Show()
end

_G.SLASH_SORTBANKBAGS1 = '/sortbankbags'
function _G.SlashCmdList.SORTBANKBAGS(arg)
	buttonPlacer.key = 'BANK'
	buttonPlacer:Show()
end

function ADDON_LOADED()
	if arg1 ~= 'SortBags_GUI' then
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
	button:SetNormalTexture[[Interface\AddOns\SortBags_GUI\Bags]]
	button:GetNormalTexture():SetTexCoord(.12109375, .23046875, .7265625, .9296875)
	button:SetPushedTexture[[Interface\AddOns\SortBags_GUI\Bags]]
	button:GetPushedTexture():SetTexCoord(.00390625, .11328125, .7265625, .9296875)
	button:SetHighlightTexture[[Interface\Buttons\ButtonHilight-Square]]
	button:GetHighlightTexture():ClearAllPoints()
	button:GetHighlightTexture():SetPoint('CENTER', 0, 0)
	button:GetHighlightTexture():SetWidth(24)
	button:GetHighlightTexture():SetHeight(23)
	return button
end

function CreateButton(key)
	local settings = SortBags_GUI[key]
	local button = CleanupButton()
	_M[key].button = button
	button:SetScript('OnUpdate', function()
		if settings.parent and getglobal(settings.parent) then
			UpdateButton(key)
			this:SetScript('OnUpdate', nil)
		end
	end)
	button:SetScript('OnClick', function()
		PlaySoundFile[[Interface\AddOns\SortBags_GUI\UI_BagSorting_01.ogg]]
		_M[key].FUNCTION()
	end)
	button:SetScript('OnEnter', function()
		GameTooltip:SetOwner(this)
		GameTooltip:AddLine(_M[key].TOOLTIP)
		GameTooltip:Show()
	end)
	button:SetScript('OnLeave', function()
		GameTooltip:Hide()
	end)
end

function UpdateButton(key)
	local button, settings = _M[key].button, SortBags_GUI[key]
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
	targetMarker:SetTexture(1, 1, 0, .5)

	local buttonPreview = CleanupButton(frame)
	buttonPreview:EnableMouse(false)
	buttonPreview:SetAlpha(.5)

	local function target()
		local f = frames[frame.index]
		frame.target = f
		local scale, x, y = f:GetEffectiveScale(), GetCursorPosition()
		targetMarker:SetAllPoints(f)
		buttonPreview:SetScale(scale * this.scale)
		RaidWarningFrame:AddMessage(f:GetName())
	end

	frame:SetScript('OnShow', function()
		this.scale = 1
		this.index = 1
		CollectFrames()
		target()
	end)
	frame:SetScript('OnKeyDown', function() if arg1 == 'ESCAPE' then this:Hide() end end)
	frame:SetScript('OnMouseWheel', function()
		if IsControlKeyDown() then
			this.scale = max(0, this.scale + arg1 * .05)
			buttonPreview:SetScale(this.target:GetEffectiveScale() * this.scale)
		else
			this.index = this.index + arg1
			if this.index < 1 then
				this.index = getn(frames)
			elseif this.index > getn(frames) then
				this.index = 1
			end
			target()
		end
	end)
	frame:SetScript('OnMouseDown', function()
		this:Hide()
		local x, y = GetCursorPosition()
		local targetScale, targetX, targetY = this.target:GetEffectiveScale(), this.target:GetCenter()
		SortBags_GUI[this.key] = {parent=this.target:GetName(), position={(x/targetScale-targetX)/this.scale, (y/targetScale-targetY)/this.scale}, scale=this.scale}
		UpdateButton(this.key)
	end)
	frame:SetScript('OnUpdate', function()
		local scale, x, y = buttonPreview:GetEffectiveScale(), GetCursorPosition()
		buttonPreview:SetPoint('CENTER', UIParent, 'BOTTOMLEFT', x/scale, y/scale)
	end)
end