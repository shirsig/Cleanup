local _G, _M = getfenv(0), {}
setfenv(1, setmetatable(_M, {__index=_G}))

do
	local f = CreateFrame'Frame'
	f:SetScript('OnEvent', function() _M[event](this) end)
	f:RegisterEvent'ADDON_LOADED'
end

_G.Clean_Up_GUI_Settings = {
	reversed = false,
	bags = {},
	bank = {},
}

bags = {
	tooltip = 'Clean Up Bags',
}
bank = {
	tooltip = 'Clean Up Bank',
}

function ADDON_LOADED()
	if arg1 ~= 'Clean_Up_GUI' then
		return
	end

	SetupSlash()

	CreateButtonPlacer()
	CreateButton'bags'
	CreateButton'bank'
end

function Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage(LIGHTYELLOW_FONT_COLOR_CODE .. '[Clean Up] ' .. msg)
end

function SetupSlash()
  	_G.SLASH_CLEANUPBAGS1 = '/cleanupbags'
	function _G.SlashCmdList.CLEANUPBAGS(arg)
		buttonPlacer.key = 'bags'
		buttonPlacer:Show()
	end

	_G.SLASH_CLEANUPBANK1 = '/cleanupbank'
	function _G.SlashCmdList.CLEANUPBANK(arg)
		buttonPlacer.key = 'bank'
		buttonPlacer:Show()
	end

    _G.SLASH_CLEANUPREVERSE1 = '/cleanupreverse'
    function _G.SlashCmdList.CLEANUPREVERSE(arg)
        Clean_Up_GUI_Settings.reversed = not Clean_Up_GUI_Settings.reversed
        Print('Sort order: ' .. (Clean_Up_GUI_Settings.reversed and 'Reversed' or 'Standard'))
	end
end

function CleanUpButton(parent)
	local button = CreateFrame('Button', nil, parent)
	button:SetWidth(28)
	button:SetHeight(26)
	button:SetNormalTexture[[Interface\AddOns\Clean_Up_GUI\Bags]]
	button:GetNormalTexture():SetTexCoord(.12109375, .23046875, .7265625, .9296875)
	button:SetPushedTexture[[Interface\AddOns\Clean_Up_GUI\Bags]]
	button:GetPushedTexture():SetTexCoord(.00390625, .11328125, .7265625, .9296875)
	button:SetHighlightTexture[[Interface\Buttons\ButtonHilight-Square]]
	button:GetHighlightTexture():ClearAllPoints()
	button:GetHighlightTexture():SetPoint('CENTER', 0, 0)
	button:GetHighlightTexture():SetWidth(24)
	button:GetHighlightTexture():SetHeight(23)
	return button
end

function CreateButton(key)
	local settings = Clean_Up_GUI_Settings[key]
	local button = CleanUpButton()
	_M[key].button = button
	button:SetScript('OnUpdate', function()
		if settings.parent and getglobal(settings.parent) then
			UpdateButton(key)
			this:SetScript('OnUpdate', nil)
		end
	end)
	button:SetScript('OnClick', function()
		PlaySoundFile[[Interface\AddOns\Clean_Up_GUI\UI_BagSorting_01.ogg]]
		Clean_Up(key, Clean_Up_GUI_Settings.reversed)
	end)
	button:SetScript('OnEnter', function()
		GameTooltip:SetOwner(this)
		GameTooltip:AddLine(_M[key].tooltip)
		GameTooltip:Show()
	end)
	button:SetScript('OnLeave', function()
		GameTooltip:Hide()
	end)
end

function UpdateButton(key)
	local button, settings = _M[key].button, Clean_Up_GUI_Settings[key]
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

	local buttonPreview = CleanUpButton(frame)
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
		Clean_Up_GUI_Settings[this.key] = {parent=this.target:GetName(), position={(x/targetScale-targetX)/this.scale, (y/targetScale-targetY)/this.scale}, scale=this.scale}
		UpdateButton(this.key)
	end)
	frame:SetScript('OnUpdate', function()
		local scale, x, y = buttonPreview:GetEffectiveScale(), GetCursorPosition()
		buttonPreview:SetPoint('CENTER', UIParent, 'BOTTOMLEFT', x/scale, y/scale)
	end)
end