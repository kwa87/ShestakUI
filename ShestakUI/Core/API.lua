﻿local T, C, L = unpack(select(2, ...))

local noop = T.dummy
local floor = math.floor
local class = T.class
local texture = C.media.blank
local backdropr, backdropg, backdropb, backdropa, borderr, borderg, borderb = 0, 0, 0, 1, 0, 0, 0

----------------------------------------------------------------------------------------
--	Pixel perfect script of custom ui Scale
----------------------------------------------------------------------------------------
T.UIScale = function()
	if T.getscreenwidth <= 1440 then
		T.low_resolution = true
	else
		T.low_resolution = false
	end

	if C.general.auto_scale == true then
		C.general.uiscale = min(2, max(0.64, 768/string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)")))
	end
end
T.UIScale()

local mult = 768/string.match(GetCVar("gxResolution"), "%d+x(%d+)")/C.general.uiscale
local Scale = function(x)
    return mult*math.floor(x/mult+0.5)
end

T.Scale = function(x) return Scale(x) end
T.mult = mult

local function Size(frame, width, height)
	frame:SetSize(Scale(width), Scale(height or width))
end

local function Width(frame, width)
	frame:SetWidth(Scale(width))
end

local function Height(frame, height)
	frame:SetHeight(Scale(height))
end

local function Point(obj, arg1, arg2, arg3, arg4, arg5)
	if type(arg1)=="number" then arg1 = Scale(arg1) end
	if type(arg2)=="number" then arg2 = Scale(arg2) end
	if type(arg3)=="number" then arg3 = Scale(arg3) end
	if type(arg4)=="number" then arg4 = Scale(arg4) end
	if type(arg5)=="number" then arg5 = Scale(arg5) end

	obj:SetPoint(arg1, arg2, arg3, arg4, arg5)
end

----------------------------------------------------------------------------------------
--	Template functions
----------------------------------------------------------------------------------------
local function CreateShadow(f, t)
	if f.shadow then return end
	
	borderr, borderg, borderb = 0, 0, 0
	backdropr, backdropg, backdropb = 0, 0, 0
	
	if t == "ClassColor" then
		local c = T.oUF_colors.class[class]
		borderr, borderg, borderb = c[1], c[2], c[3]
		backdropr, backdropg, backdropb = unpack(C.media.backdrop_color)
	end
	
	local shadow = CreateFrame("Frame",  f:GetName() and f:GetName().."Shadow" or nil, f)
	shadow:SetFrameLevel(1)
	shadow:SetFrameStrata(f:GetFrameStrata())
	shadow:Point("TOPLEFT", -3, 3)
	shadow:Point("BOTTOMLEFT", -3, -3)
	shadow:Point("TOPRIGHT", 3, 3)
	shadow:Point("BOTTOMRIGHT", 3, -3)
	shadow:SetBackdrop({ 
		edgeFile = C.media.glow, edgeSize = T.Scale(3),
		insets = {left = T.Scale(5), right = T.Scale(5), top = T.Scale(5), bottom = T.Scale(5)},
	})
	shadow:SetBackdropColor(backdropr, backdropg, backdropb, 0)
	shadow:SetBackdropBorderColor(borderr, borderg, borderb, 0.8)
	f.shadow = shadow
end

local function CreateOverlay(f)
	if f.overlay then return end
	
	local overlay = f:CreateTexture(f:GetName() and f:GetName().."Overlay" or nil, "BORDER", f)
	overlay:ClearAllPoints()
	overlay:Point("TOPLEFT", 2, -2)
	overlay:Point("BOTTOMRIGHT", -2, 2)
	overlay:SetTexture(C.media.blank)
	overlay:SetVertexColor(0.1, 0.1, 0.1, 1)
	f.overlay = overlay
end

local function CreateBorder(f, i, o)
	if i then
		if f.iborder then return end
		local border = CreateFrame("Frame", f:GetName() and f:GetName().."InnerBorder" or nil, f)
		border:Point("TOPLEFT", mult, -mult)
		border:Point("BOTTOMRIGHT", -mult, mult)
		border:SetBackdrop({
			edgeFile = C.media.blank, edgeSize = mult, 
			insets = {left = mult, right = mult, top = mult, bottom = mult}
		})
		border:SetBackdropBorderColor(unpack(C.media.backdrop_color))
		f.iborder = border
	end
	
	if o then
		if f.oborder then return end
		local border = CreateFrame("Frame", f:GetName() and f:GetName().."OuterBorder" or nil, f)
		border:Point("TOPLEFT", -mult, mult)
		border:Point("BOTTOMRIGHT", mult, -mult)
		border:SetFrameLevel(f:GetFrameLevel() + 1)
		border:SetBackdrop({
			edgeFile = C.media.blank, edgeSize = mult, 
			insets = {left = mult, right = mult, top = mult, bottom = mult}
		})
		border:SetBackdropBorderColor(unpack(C.media.backdrop_color))
		f.oborder = border
	end
end

local function GetTemplate(t)
	if t == "ClassColor" then
		local c = T.oUF_colors.class[class]
		borderr, borderg, borderb = c[1], c[2], c[3]
		backdropr, backdropg, backdropb = unpack(C.media.backdrop_color)
	else
		borderr, borderg, borderb = unpack(C.media.border_color)
		backdropr, backdropg, backdropb = unpack(C.media.backdrop_color)
	end
end

local function SetTemplate(f, t, tex)
	if tex then texture = C.media.texture else texture = C.media.blank end
	
	GetTemplate(t)
	
	f:SetBackdrop({
		bgFile = C.media.blank, 
		edgeFile = C.media.blank, 
		tile = false, tileSize = 0, edgeSize = mult, 
		insets = {left = -mult, right = -mult, top = -mult, bottom = -mult}
	})
	
	if t == "Transparent" then
		backdropa = 0.7
		f:CreateBorder(true, true)
	elseif t == "Overlay" then
		backdropa = 1
		f:CreateOverlay()
	else
		backdropa = 1
	end
	
	f:SetBackdropColor(backdropr, backdropg, backdropb, backdropa)
	f:SetBackdropBorderColor(borderr, borderg, borderb)
end

local function CreatePanel(f, t, w, h, a1, p, a2, x, y)
	GetTemplate(t)

	f:Width(w)
	f:Height(h)
	f:SetFrameLevel(1)
	f:SetFrameStrata("BACKGROUND")
	f:Point(a1, p, a2, x, y)
	f:SetBackdrop({
		bgFile = C.media.blank, 
		edgeFile = C.media.blank, 
		tile = false, tileSize = 0, edgeSize = mult, 
		insets = {left = -mult, right = -mult, top = -mult, bottom = -mult}
	})
	
	if t == "Transparent" then
		backdropa = 0.7
		f:CreateBorder(true, true)
	elseif t == "Overlay" then
		backdropa = 1
		f:CreateOverlay()
	else
		backdropa = 1
	end
	
	f:SetBackdropColor(backdropr, backdropg, backdropb, backdropa)
	f:SetBackdropBorderColor(borderr, borderg, borderb)
end

----------------------------------------------------------------------------------------
--	Kill object function
----------------------------------------------------------------------------------------
local function Kill(object)
	if object.UnregisterAllEvents then
		object:UnregisterAllEvents()
	end
	object.Show = noop
	object:Hide()
end

----------------------------------------------------------------------------------------
--	Style ActionBars/Bags buttons function(by Chiril & Karudon)
----------------------------------------------------------------------------------------
local function StyleButton(b, c) 
    local name = b:GetName()
    local button = _G[name]
    local icon = _G[name.."Icon"]
    local count = _G[name.."Count"]
    local border = _G[name.."Border"]
    local hotkey = _G[name.."HotKey"]
    local cooldown = _G[name.."Cooldown"]
    local nametext = _G[name.."Name"]
    local flash = _G[name.."Flash"]
    local normaltexture = _G[name.."NormalTexture"]
	local icontexture = _G[name.."IconTexture"]
	
	local hover = b:CreateTexture("Frame", nil, self)
	hover:SetTexture(1, 1, 1, 0.3)
	hover:Size(button:GetWidth(), button:GetHeight())
	hover:Point("TOPLEFT", button, 2, -2)
	hover:Point("BOTTOMRIGHT", button, -2, 2)
	button:SetHighlightTexture(hover)

	local pushed = b:CreateTexture("Frame", nil, self)
	pushed:SetTexture(0.9, 0.8, 0.1, 0.3)
	pushed:Size(button:GetWidth(), button:GetHeight())
	pushed:Point("TOPLEFT", button, 2, -2)
	pushed:Point("BOTTOMRIGHT", button, -2, 2)
	button:SetPushedTexture(pushed)
 
	if c then
		local checked = b:CreateTexture("Frame", nil, self)
		checked:SetTexture(0, 1, 0, 0.3)
		checked:Size(button:GetWidth(), button:GetHeight())
		checked:Point("TOPLEFT", button, 2, -2)
		checked:Point("BOTTOMRIGHT", button, -2, 2)
		button:SetCheckedTexture(checked)
	end
	
	if cooldown then
		cooldown:ClearAllPoints()
		cooldown:Point("TOPLEFT", button, 2, -2)
		cooldown:Point("BOTTOMRIGHT", button, -2, 2)
	end
end

----------------------------------------------------------------------------------------
--	Style buttons function
----------------------------------------------------------------------------------------
T.SetModifiedBackdrop = function(self)
	self:SetBackdropBorderColor(T.color.r, T.color.g, T.color.b)
	if self.overlay then
		self.overlay:SetVertexColor(T.color.r, T.color.g, T.color.b, 0.3)
	end
end

T.SetOriginalBackdrop = function(self)
	self:SetBackdropBorderColor(unpack(C.media.border_color))
	if self.overlay then
		self.overlay:SetVertexColor(0.1, 0.1, 0.1, 1)
	end
end

local function SkinButton(f)
	if f.SetNormalTexture then f:SetNormalTexture("") end
	if f.SetHighlightTexture then f:SetHighlightTexture("") end
	if f.SetPushedTexture then f:SetPushedTexture("") end
	if f.SetDisabledTexture then f:SetDisabledTexture("") end

	if f:GetName() then
		if _G[f:GetName().."Left"] then _G[f:GetName().."Left"]:SetAlpha(0) end
		if _G[f:GetName().."Middle"] then _G[f:GetName().."Middle"]:SetAlpha(0) end
		if _G[f:GetName().."Right"] then _G[f:GetName().."Right"]:SetAlpha(0) end
		if _G[f:GetName().."LeftDisabled"] then _G[f:GetName().."LeftDisabled"]:SetAlpha(0) end
		if _G[f:GetName().."MiddleDisabled"] then _G[f:GetName().."MiddleDisabled"]:SetAlpha(0) end
		if _G[f:GetName().."RightDisabled"] then _G[f:GetName().."RightDisabled"]:SetAlpha(0) end
		if _G[f:GetName().."HighlightTexture"] then _G[f:GetName().."HighlightTexture"]:SetAlpha(0) end
	end
	
	f:SetTemplate("Overlay")
	f:HookScript("OnEnter", T.SetModifiedBackdrop)
	f:HookScript("OnLeave", T.SetOriginalBackdrop)
end

----------------------------------------------------------------------------------------
--	Font function
----------------------------------------------------------------------------------------
local function FontString(parent, name, fontName, fontHeight, fontStyle)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(fontName, fontHeight, fontStyle)
	fs:SetJustifyH("LEFT")
	
	if not name then
		parent.text = fs
	else
		parent[name] = fs
	end
	
	return fs
end

----------------------------------------------------------------------------------------
--	Fade in/out functions
----------------------------------------------------------------------------------------
local function FadeIn(f)
	UIFrameFadeIn(f, 0.4, f:GetAlpha(), 1)
end
	
local function FadeOut(f)
	UIFrameFadeOut(f, 0.8, f:GetAlpha(), 0)
end

local function addapi(object)
	local mt = getmetatable(object).__index
	mt.Size = Size
	mt.Width = Width
	mt.Height = Height
	mt.Point = Point
	mt.CreateOverlay = CreateOverlay
	mt.CreateBorder = CreateBorder
	mt.SetTemplate = SetTemplate
	mt.CreatePanel = CreatePanel
	mt.Kill = Kill
	mt.StyleButton = StyleButton
	mt.SkinButton = SkinButton
	mt.FontString = FontString
	mt.FadeIn = FadeIn
	mt.FadeOut = FadeOut
end

local handled = {["Frame"] = true}
local object = CreateFrame("Frame")
addapi(object)
addapi(object:CreateTexture())
addapi(object:CreateFontString())

object = EnumerateFrames()
while object do
	if not handled[object:GetObjectType()] then
		addapi(object)
		handled[object:GetObjectType()] = true
	end

	object = EnumerateFrames(object)
end