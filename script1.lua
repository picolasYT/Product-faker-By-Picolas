-- ============================================================
--  PRODUCT FAKER V2 : By Picolas
--  Full: search · batch · loop · fake-detected · anti-afk · hop
-- ============================================================

local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local TextService       = game:GetService("TextService")
local HttpService       = game:GetService("HttpService")
local MarketplaceService= game:GetService("MarketplaceService")
local TeleportService   = game:GetService("TeleportService")
local VirtualUser       = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

local toggleKey    = Enum.KeyCode.RightShift
local supportedUrl = "https://loadstring.net/raw/TCiFuJc4kK"
local title        = "PRODUCT FAKER V2 : By Picolas"

local asciiCfg = {
	enabled = true, textSize = 13, padding = 80, fps = 30,
	ramp = " .,:;-=+*x#%@", color = Color3.fromRGB(255,255,255), mouse = true,
}

local env = typeof(getgenv) == "function" and getgenv() or _G
local previous = env.__ProductFaker or env.__ProductFakerUI
if previous then pcall(previous.Destroy, true) end

local col = {
	bg=Color3.fromRGB(13,13,13), panel=Color3.fromRGB(30,30,30),
	panelHi=Color3.fromRGB(38,38,38), button=Color3.fromRGB(56,56,56),
	buttonHi=Color3.fromRGB(72,72,72), active=Color3.fromRGB(84,84,84),
	icon=Color3.fromRGB(193,193,193), dim=Color3.fromRGB(120,120,120),
	white=Color3.fromRGB(255,255,255), red=Color3.fromRGB(255,57,57),
	blue=Color3.fromRGB(94,115,255), yellow=Color3.fromRGB(238,255,131),
	green=Color3.fromRGB(110,255,150),
}

local roboto      = "rbxasset://fonts/families/RobotoCondensed.json"
local fontBold    = Font.new(roboto, Enum.FontWeight.Bold, Enum.FontStyle.Normal)
local fontReg     = Font.new(roboto, Enum.FontWeight.Regular, Enum.FontStyle.Normal)
local fontItalic  = Font.new(roboto, Enum.FontWeight.Regular, Enum.FontStyle.Italic)
local fontInput   = Font.new("rbxassetid://16658246179", Enum.FontWeight.Regular, Enum.FontStyle.Normal)

local img = {
	close="rbxassetid://89309313651390", home="rbxassetid://70573525526341",
	faker="rbxassetid://117975333704340", logger="rbxassetid://109982256018444",
	supported="rbxassetid://133954136637154", passes="rbxassetid://84787327728949",
	join="rbxassetid://88984171145049", copy="rbxassetid://101160281432561",
}

local function getEnum(e,i) local ok,v=pcall(function() return Enum[e][i] end) return ok and v or nil end
local strokeInner = getEnum("BorderStrokePosition","Inner")

local function create(class, props, children)
	local ok, inst = pcall(Instance.new, class)
	if not ok then return nil end
	local parent
	for k, v in pairs(props or {}) do
		if k == "Parent" then parent = v else pcall(function() inst[k] = v end) end
	end
	for _, child in pairs(children or {}) do child.Parent = inst end
	if parent then inst.Parent = parent end
	return inst
end

local function corner(r) return create("UICorner",{CornerRadius=UDim.new(0, r or 8)}) end
local function stroke(t) return create("UIStroke",{Color=col.white,Transparency=t or 0.86,BorderStrokePosition=strokeInner}) end
local function tween(o, t, p, s, d)
	local tw = TweenService:Create(o, TweenInfo.new(t, s or Enum.EasingStyle.Quint, d or Enum.EasingDirection.Out), p)
	tw:Play(); return tw
end
local function label(props)
	props.BackgroundTransparency = 1; props.BorderSizePixel = 0
	props.TextScaled = props.TextScaled ~= false; props.TextWrapped = true
	props.AnchorPoint = props.AnchorPoint or Vector2.new(0.5,0.5)
	props.FontFace = props.FontFace or fontReg
	props.TextColor3 = props.TextColor3 or col.white
	return create("TextLabel", props)
end
local function isClick(i)
	local t = i.UserInputType
	return t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch
end
local function commas(n)
	local s = tostring(math.floor(tonumber(n) or 0))
	return (s:reverse():gsub("(%d%d%d)","%1,"):reverse():gsub("^,",""))
end
local function copy(text)
	local fn = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set)
	return fn ~= nil and (pcall(fn, tostring(text)))
end

local connections = {}
local function bind(sig, fn) local c = sig:Connect(fn) table.insert(connections, c) return c end
local function mount(gui)
	local parents = {}
	if typeof(gethui) == "function" then table.insert(parents, gethui) end
	table.insert(parents, function() return game:GetService("CoreGui") end)
	table.insert(parents, function() return LocalPlayer:WaitForChild("PlayerGui") end)
	for _, get in ipairs(parents) do
		if pcall(function() gui.Parent = get() end) and gui.Parent then return end
	end
end

local fadeProps = {
	{"GuiObject","BackgroundTransparency"},{"TextLabel","TextTransparency"},
	{"TextButton","TextTransparency"},{"TextBox","TextTransparency"},
	{"ImageLabel","ImageTransparency"},{"ImageButton","ImageTransparency"},
	{"ScrollingFrame","ScrollBarImageTransparency"},{"UIStroke","Transparency"},
	{"UIShadow","Transparency"},
}
local originals, fadeExclude = {}, {}
local function getOriginal(inst)
	local o = originals[inst]; if o then return o end
	o = {}
	for _, p in ipairs(fadeProps) do
		local ok, is = pcall(inst.IsA, inst, p[1])
		if ok and is then
			local ok2, v = pcall(function() return inst[p[2]] end)
			if ok2 and type(v) == "number" then o[p[2]] = v end
		end
	end
	originals[inst] = o
	inst.Destroying:Connect(function() originals[inst] = nil end)
	return o
end
local function isExcluded(inst)
	for _, r in ipairs(fadeExclude) do if inst == r or inst:IsDescendantOf(r) then return true end end
	return false
end
local function fade(root, alpha, t)
	local list = root:GetDescendants(); table.insert(list, root)
	for _, inst in ipairs(list) do
		if not isExcluded(inst) then
			local goal
			for prop, v in pairs(getOriginal(inst)) do
				goal = goal or {}; goal[prop] = v + (1-v)*(1-alpha)
			end
			if goal then
				if t and t > 0 then tween(inst, t, goal, Enum.EasingStyle.Quad)
				else for p, v in pairs(goal) do pcall(function() inst[p] = v end) end end
			end
		end
	end
end

local glyphs = "!<>-_\\/[]{}=+*^?#@$%&"
local scrambleIds = {}
local function scramble(lbl, text, duration)
	local id = (scrambleIds[lbl] or 0) + 1; scrambleIds[lbl] = id
	task.spawn(function()
		local start, len = os.clock(), #text
		while lbl.Parent and scrambleIds[lbl] == id do
			local p = (os.clock()-start)/duration
			if p >= 1 then break end
			local revealed = math.floor(p*len)
			local out = table.create(len)
			for i = 1, len do
				local ch = text:sub(i,i)
				if i <= revealed or ch == " " then out[i] = ch
				else local r = math.random(1,#glyphs); out[i] = glyphs:sub(r,r) end
			end
			lbl.Text = table.concat(out); task.wait(0.03)
		end
		if scrambleIds[lbl] == id then lbl.Text = text end
	end)
end

-- ==================== GUI BASE ====================
local ScreenGui = create("ScreenGui",{
	Name="ProductFakerV2", ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
	ResetOnSpawn=false, IgnoreGuiInset=true, DisplayOrder=999,
})
mount(ScreenGui)

local AsciiHolder = create("Frame",{
	Name="AsciiBackdrop", AnchorPoint=Vector2.new(0.5,0.5),
	Position=UDim2.fromScale(0.5,0.5), BackgroundTransparency=1,
	ClipsDescendants=true, Visible=false, ZIndex=1, Parent=ScreenGui,
})

local MainScale = create("UIScale",{Scale=1})
local Main = create("Frame",{
	Name="Main", AnchorPoint=Vector2.new(0.5,0.5),
	Position=UDim2.fromScale(0.5,0.5), Size=UDim2.fromScale(0.285,0.439),
	BackgroundColor3=col.bg, BorderSizePixel=0, Visible=false, ZIndex=2, Parent=ScreenGui,
},{
	corner(),
	create("UIShadow",{Transparency=0.5, BlurRadius=UDim.new(0,20)}),
	create("UIStroke",{Color=col.white, Transparency=0.74}),
	create("UIAspectRatioConstraint",{AspectRatio=1.2415}),
	create("UISizeConstraint",{MinSize=Vector2.new(380,306)}),
	MainScale,
})

local idle  = {BackgroundColor3=col.button, ImageColor3=col.icon}
local hover = {BackgroundColor3=col.buttonHi, ImageColor3=col.white}
local function buttonFx(btn, normal, hovered, isActive)
	normal = normal or idle; hovered = hovered or hover
	local scale = btn:FindFirstChildOfClass("UIScale") or create("UIScale",{Parent=btn})
	local function active() return isActive and isActive() end
	btn.MouseEnter:Connect(function() if not active() then tween(btn,0.15,hovered) end end)
	btn.MouseLeave:Connect(function()
		tween(scale,0.2,{Scale=1})
		if not active() then tween(btn,0.2,normal) end
	end)
	btn.MouseButton1Down:Connect(function() tween(scale,0.08,{Scale=0.9}) end)
	btn.MouseButton1Up:Connect(function() tween(scale,0.35,{Scale=1},Enum.EasingStyle.Back) end)
end

-- TopBar
local TopBar = create("Frame",{
	Name="TopBar", Size=UDim2.fromScale(1,0.125),
	BackgroundColor3=col.panel, BorderSizePixel=0, Parent=Main,
},{create("UICorner",{BottomLeftRadius=UDim.new(0,0),BottomRightRadius=UDim.new(0,0)})})

local Title = label({
	Name="Title", AnchorPoint=Vector2.new(0,0.5), Position=UDim2.fromScale(0.034,0.5),
	Size=UDim2.fromScale(0.8,0.386), Text=title, FontFace=fontBold,
	TextXAlignment=Enum.TextXAlignment.Left, Parent=TopBar,
})

local CloseButton = create("ImageButton",{
	Name="CloseButton", AnchorPoint=Vector2.new(0.5,0.5),
	Position=UDim2.fromScale(0.948,0.5), Size=UDim2.fromScale(0.069,0.693),
	BackgroundColor3=col.button, BorderSizePixel=0, Image=img.close,
	ImageColor3=col.icon, AutoButtonColor=false, Parent=TopBar,
},{corner(), stroke(), create("UIScale")})
buttonFx(CloseButton, idle, {BackgroundColor3=Color3.fromRGB(150,40,40), ImageColor3=col.white})

-- BottomBar
local BottomBar = create("Frame",{
	Name="BottomBar", AnchorPoint=Vector2.new(0,1), Position=UDim2.fromScale(0,1),
	Size=UDim2.fromScale(1,0.125), BackgroundColor3=col.panel, BorderSizePixel=0, Parent=Main,
},{create("UICorner",{TopLeftRadius=UDim.new(0,0),TopRightRadius=UDim.new(0,0)})})

local ButtonContainer = create("Frame",{
	Name="ButtonContainer", AnchorPoint=Vector2.new(0.5,0.5),
	Position=UDim2.fromScale(0.5,0.5), Size=UDim2.fromScale(0.9588,0.636),
	BackgroundTransparency=1, Parent=BottomBar,
},{create("UIListLayout",{
	FillDirection=Enum.FillDirection.Horizontal,
	HorizontalAlignment=Enum.HorizontalAlignment.Center,
	VerticalAlignment=Enum.VerticalAlignment.Center,
	Padding=UDim.new(0,4), SortOrder=Enum.SortOrder.LayoutOrder,
})})

local Indicator = create("Frame",{
	Name="TabIndicator", AnchorPoint=Vector2.new(0.5,1),
	Position=UDim2.new(0,0,1,-2), Size=UDim2.fromOffset(14,2),
	BackgroundColor3=col.white, BorderSizePixel=0, ZIndex=3, Parent=BottomBar,
},{corner(1)})

local function navButton(name, image, order)
	return create("ImageButton",{
		Name=name, LayoutOrder=order, Size=UDim2.fromScale(0.0668,1),
		BackgroundColor3=col.button, BorderSizePixel=0, Image=image,
		ImageColor3=col.icon, AutoButtonColor=false, Parent=ButtonContainer,
	},{corner(), stroke(), create("UIScale")})
end
local HomeButton      = navButton("HomeButton",      img.home,      1)
local FakerButton     = navButton("FakerButton",     img.faker,     2)
local LoggerButton    = navButton("LoggerButton",    img.logger,    3)
local SupportedButton = navButton("SupportedButton", img.supported, 4)
local PassListButton  = navButton("PassListButton",  img.passes,    5)

local SectionsContainer = create("Frame",{
	Name="SectionsContainer", AnchorPoint=Vector2.new(0.5,0.5),
	Position=UDim2.fromScale(0.5,0.5), Size=UDim2.fromScale(0.938,0.665),
	BackgroundTransparency=1, ClipsDescendants=true, Parent=Main,
})

local emptyLabels = {}
local function makeScreen(name, scrolling)
	if not scrolling then
		return create("Frame",{
			Name=name, Size=UDim2.fromScale(1,1),
			BackgroundTransparency=1, Visible=false, Parent=SectionsContainer,
		})
	end
	local sf = create("ScrollingFrame",{
		Name=name, Size=UDim2.fromScale(1,1), BackgroundTransparency=1,
		BorderSizePixel=0, Visible=false, ScrollBarThickness=3,
		ScrollBarImageColor3=col.button, CanvasSize=UDim2.new(),
		AutomaticCanvasSize=Enum.AutomaticSize.Y,
		ScrollingDirection=Enum.ScrollingDirection.Y, Parent=SectionsContainer,
	},{
		create("UIListLayout",{Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.LayoutOrder}),
		create("UIPadding",{PaddingTop=UDim.new(0,1),PaddingBottom=UDim.new(0,1),PaddingLeft=UDim.new(0,1)}),
	})
	local empty = label({
		Name="Empty", AnchorPoint=Vector2.new(0,0), Size=UDim2.new(1,-8,0,40),
		Text="Nothing here yet.", TextScaled=false, TextSize=14,
		TextColor3=col.dim, LayoutOrder=-1e9, Parent=sf,
	})
	emptyLabels[sf] = empty
	local rows = 0
	local function refresh() empty.Visible = rows == 0 end
	sf.ChildAdded:Connect(function(c) if c:GetAttribute("IsRow") then rows += 1; refresh() end end)
	sf.ChildRemoved:Connect(function(c) if c:GetAttribute("IsRow") then rows = math.max(0, rows-1); refresh() end end)
	return sf
end
local HomeScreen        = makeScreen("HomeScreen", false)
local FakerScreen       = makeScreen("FakerScreen", false)
local ProductLogger     = makeScreen("ProductLogger", true)
local SupportedContainer= makeScreen("SupportedContainer", true)
local GamepassList      = makeScreen("GamepassList", true)

-- Toast
local ToastStroke = create("UIStroke",{Color=col.white,Transparency=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border})
local Toast = create("TextLabel",{
	Name="Toast", AnchorPoint=Vector2.new(0.5,1), Position=UDim2.new(0.5,0,0.875,-6),
	Size=UDim2.fromOffset(0,26), AutomaticSize=Enum.AutomaticSize.X,
	BackgroundColor3=col.panel, BackgroundTransparency=1, BorderSizePixel=0,
	FontFace=fontReg, TextSize=14, TextColor3=col.white, TextTransparency=1,
	Text="", ZIndex=20, Parent=Main,
},{
	corner(13), create("UIPadding",{PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12)}), ToastStroke,
})
table.insert(fadeExclude, Toast)

local toastQueue, toastBusy, toastId = {}, false, 0
local function runToast(text, color)
	toastId += 1; local id = toastId
	Toast.TextColor3 = color or col.white
	Toast.Position = UDim2.new(0.5,0,0.875,4)
	tween(Toast,0.3,{BackgroundTransparency=0, TextTransparency=0, Position=UDim2.new(0.5,0,0.875,-6)})
	tween(ToastStroke,0.3,{Transparency=0.8})
	scramble(Toast, text, 0.25)
	task.delay(1.8,function()
		if id ~= toastId then return end
		tween(Toast,0.3,{BackgroundTransparency=1, TextTransparency=1})
		tween(ToastStroke,0.3,{Transparency=1})
	end)
end
local function toast(text, color)
	table.insert(toastQueue, {text=text, color=color})
	if toastBusy then return end
	toastBusy = true
	task.spawn(function()
		while #toastQueue > 0 do
			local item = table.remove(toastQueue, 1)
			runToast(item.text, item.color)
			task.wait(1.9)
		end
		toastBusy = false
	end)
end

local destroyed = false
local Stats = {start=os.clock(), fakes=0, copies=0}

-- ==================== HOME SCREEN ====================
label({Name="Subhead", Text="By Picolas — Fakes gamepass/product purchases.",
	FontFace=fontItalic, Size=UDim2.fromScale(0.824,0.107),
	Position=UDim2.fromScale(0.5,0.088), Parent=HomeScreen})

local function linkLabel(text, color, y, link)
	local lbl = label({Name="Link", Text=text, TextColor3=color,
		Size=UDim2.fromScale(0.824,0.107), Position=UDim2.fromScale(0.5,y),
		Active=true, Parent=HomeScreen})
	lbl.MouseEnter:Connect(function() tween(lbl,0.15,{TextColor3=color:Lerp(col.white,0.45)}) end)
	lbl.MouseLeave:Connect(function() tween(lbl,0.2,{TextColor3=color}) end)
	lbl.InputBegan:Connect(function(input)
		if not isClick(input) then return end
		if copy(link) then Stats.copies += 1; toast("Copied "..link)
		else toast("Clipboard unavailable", col.red) end
	end)
end
linkLabel("YouTube: @vaehz", col.red, 0.297, "https://youtube.com/@vaehz")
linkLabel("Discord: discord.gg/vaehz", col.blue, 0.404, "https://discord.gg/vaehz")
linkLabel("Website: RobloxExploit.org", col.yellow, 0.511, "https://robloxexploit.org")

local StatsPanel = create("Frame",{
	Name="StatsPanel", AnchorPoint=Vector2.new(0.5,0.5),
	Position=UDim2.fromScale(0.5,0.635), Size=UDim2.fromScale(0.824,0.15),
	BackgroundColor3=col.panel, BorderSizePixel=0, Parent=HomeScreen,
},{corner(10), stroke()})

local statDefs = {
	{key="fakes",  label="Fakes",   color=col.green},
	{key="copies", label="Copies",  color=col.blue},
	{key="time",   label="Session", color=col.yellow},
}
local statValues = {}
for i, d in ipairs(statDefs) do
	local x = (i-0.5)/#statDefs
	label({Name=d.key.."L", Text=d.label, AnchorPoint=Vector2.new(0.5,0),
		Position=UDim2.new(x,0,0,4), Size=UDim2.new(1/#statDefs,0,0,12),
		TextScaled=false, TextSize=10, TextColor3=col.dim, Parent=StatsPanel})
	statValues[d.key] = label({Name=d.key.."V", Text="0", AnchorPoint=Vector2.new(0.5,0),
		Position=UDim2.new(x,0,0,18), Size=UDim2.new(1/#statDefs,0,0,16),
		TextScaled=false, TextSize=14, FontFace=fontBold, TextColor3=d.color, Parent=StatsPanel})
end

task.spawn(function()
	while not destroyed do
		statValues.fakes.Text  = tostring(Stats.fakes)
		statValues.copies.Text = tostring(Stats.copies)
		local e = math.floor(os.clock() - Stats.start)
		statValues.time.Text = ("%d:%02d"):format(math.floor(e/60), e%60)
		task.wait(1)
	end
end)

local QuickActions = create("Frame",{
	Name="QuickActions", AnchorPoint=Vector2.new(0.5,1),
	Position=UDim2.new(0.5,0,0.93,0), Size=UDim2.new(0.824,0,0,0),
	AutomaticSize=Enum.AutomaticSize.Y, BackgroundTransparency=1,
	Parent=HomeScreen,
},{create("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,
	HorizontalAlignment=Enum.HorizontalAlignment.Center, Padding=UDim.new(0,6)})})

local function miniAction(text, color, onClick)
	local b = create("TextButton",{
		Size=UDim2.fromOffset(100,28), BackgroundColor3=col.panel,
		BorderSizePixel=0, Text=text, FontFace=fontBold, TextSize=12,
		TextColor3=color or col.white, AutoButtonColor=false, Parent=QuickActions,
	},{corner(7), stroke(), create("UIScale")})
	local sc = b:FindFirstChildOfClass("UIScale")
	b.MouseEnter:Connect(function() tween(b,0.15,{BackgroundColor3=col.buttonHi}) end)
	b.MouseLeave:Connect(function() tween(b,0.2,{BackgroundColor3=col.panel}) end)
	b.MouseButton1Down:Connect(function() tween(sc,0.08,{Scale=0.9}) end)
	b.MouseButton1Up:Connect(function() tween(sc,0.35,{Scale=1},Enum.EasingStyle.Back) end)
	b.MouseButton1Click:Connect(onClick)
	return b
end

miniAction("Server Hop", col.blue, function()
	toast("Buscando servidor...")
	task.spawn(function()
		local url = ("https://games.roblox.com/v1/games/%d/servers/Public?limit=100&excludeFullGames=true"):format(game.PlaceId)
		local ok, res = pcall(function() return game:HttpGet(url) end)
		if not ok or type(res) ~= "string" then toast("Error al obtener servidores", col.red); return end
		local ok2, data = pcall(HttpService.JSONDecode, HttpService, res)
		if not ok2 or type(data) ~= "table" or type(data.data) ~= "table" then toast("Respuesta inválida", col.red); return end
		local c = {}
		for _, s in ipairs(data.data) do
			if s.id and s.id ~= game.JobId and (s.playing or 0) < (s.maxPlayers or 0) then table.insert(c, s.id) end
		end
		if #c == 0 then toast("No hay otros servidores", col.yellow); return end
		toast("Teleportando a nuevo servidor...")
		pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, c[math.random(1,#c)], LocalPlayer) end)
	end)
end)

local antiAfkEnabled, antiAfkConn = false, nil
local antiAfkBtn = miniAction("Anti-AFK: OFF", col.red, function() end)
antiAfkBtn.MouseButton1Click:Connect(function()
	antiAfkEnabled = not antiAfkEnabled
	if antiAfkEnabled then
		antiAfkBtn.Text = "Anti-AFK: ON"; antiAfkBtn.TextColor3 = col.green
		antiAfkConn = LocalPlayer.Idled:Connect(function()
			VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new())
		end)
		toast("Anti-AFK activado", col.green)
	else
		antiAfkBtn.Text = "Anti-AFK: OFF"; antiAfkBtn.TextColor3 = col.red
		if antiAfkConn then antiAfkConn:Disconnect(); antiAfkConn = nil end
		toast("Anti-AFK desactivado", col.yellow)
	end
end)

label({Name="Notice",
	Text="THIS WONT WORK ON MAJORITY OF GAMES. SUPPORTED GAMES LIST CAN BE FOUND AT THE BOTTOM OF THIS UI.",
	Size=UDim2.fromScale(0.824,0.13), Position=UDim2.fromScale(0.5,0.80), Parent=HomeScreen})

-- ==================== FAKER SCREEN ====================
local idInputPos = UDim2.fromScale(0.0122, 0)
local IdStroke = stroke()
local IdInput = create("Frame",{
	Name="IdInput", Position=idInputPos, Size=UDim2.fromScale(0.5805,0.1838),
	BackgroundColor3=col.panel, BorderSizePixel=0, Parent=FakerScreen,
},{corner(), IdStroke})

local InpBox = create("TextBox",{
	Name="InpBox", AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5),
	Size=UDim2.fromScale(0.9076,0.4651), BackgroundTransparency=1, BorderSizePixel=0,
	FontFace=fontInput, PlaceholderText="Paste ID(s) — one per line",
	PlaceholderColor3=col.dim, Text="", TextColor3=col.white, TextScaled=true,
	TextWrapped=true, TextXAlignment=Enum.TextXAlignment.Left,
	ClearTextOnFocus=false, Parent=IdInput,
})
InpBox.Focused:Connect(function()
	tween(IdStroke,0.2,{Transparency=0.55}); tween(IdInput,0.2,{BackgroundColor3=col.panelHi})
end)

local FakeAllBtn = create("ImageButton",{
	Name="FakeAllBtn", Position=UDim2.fromScale(0.5976,0),
	Size=UDim2.fromScale(0.3878,0.1838), BackgroundColor3=col.panel,
	BorderSizePixel=0, AutoButtonColor=false, ImageTransparency=1, Parent=FakerScreen,
},{corner(), stroke(), create("UIScale")})
local FakeAllLbl = label({Name="Label", Text="Fake ALL", FontFace=fontBold,
	Size=UDim2.fromScale(0.9,0.4651), Position=UDim2.fromScale(0.5,0.5), Parent=FakeAllBtn})
buttonFx(FakeAllBtn, {BackgroundColor3=col.panel}, {BackgroundColor3=col.buttonHi})

local FakeButton = create("ImageButton",{
	Name="FakePurchaseBtn", Position=UDim2.fromScale(0.5976,0.22),
	Size=UDim2.fromScale(0.3878,0.13), BackgroundColor3=col.panel,
	BorderSizePixel=0, AutoButtonColor=false, ImageTransparency=1, Parent=FakerScreen,
},{corner(), stroke(), create("UIScale")})
local FakeOneLbl = label({Name="Label", Text="Fake One", FontFace=fontReg,
	Size=UDim2.fromScale(0.9,0.4651), Position=UDim2.fromScale(0.5,0.5), Parent=FakeButton})
buttonFx(FakeButton, {BackgroundColor3=col.panel}, {BackgroundColor3=col.buttonHi})

local LoopToggle = create("TextButton",{
	Name="LoopToggle", Position=UDim2.fromScale(0.0122,0.22),
	Size=UDim2.fromScale(0.28,0.13), BackgroundColor3=col.panel,
	BorderSizePixel=0, Text="Loop: OFF", FontFace=fontBold, TextSize=12,
	TextColor3=col.red, AutoButtonColor=false, Parent=FakerScreen,
},{corner(), stroke(), create("UIScale")})
buttonFx(LoopToggle, {BackgroundColor3=col.panel}, {BackgroundColor3=col.buttonHi})

local IntervalFrame = create("Frame",{
	Name="IntervalFrame", Position=UDim2.fromScale(0.30,0.22),
	Size=UDim2.fromScale(0.28,0.13), BackgroundColor3=col.panel,
	BorderSizePixel=0, Parent=FakerScreen,
},{corner(), stroke()})
local IntervalBox = create("TextBox",{
	Name="Val", AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5),
	Size=UDim2.fromScale(0.9,0.7), BackgroundTransparency=1, FontFace=fontReg,
	Text="0.5", TextColor3=col.white, TextSize=12,
	TextXAlignment=Enum.TextXAlignment.Center,
	PlaceholderText="0.5s", PlaceholderColor3=col.dim,
	ClearTextOnFocus=false, Parent=IntervalFrame,
})

-- 🆕 PROGRESS BAR
local ProgressBar = create("Frame",{
	Name="ProgressBar", Position=UDim2.fromScale(0.0122,0.375),
	Size=UDim2.fromScale(0.976,0.016), BackgroundColor3=col.panel,
	BorderSizePixel=0, Visible=false, Parent=FakerScreen,
},{corner(4)})
local ProgressFill = create("Frame",{
	Name="Fill", Size=UDim2.fromScale(0,1), BackgroundColor3=col.green,
	BorderSizePixel=0, Parent=ProgressBar,
},{corner(4)})
local ProgressLabel = create("TextLabel",{
	Name="ProgressLabel", AnchorPoint=Vector2.new(1,1),
	Position=UDim2.new(1,0,0,-2), Size=UDim2.fromOffset(120,12),
	BackgroundTransparency=1, FontFace=fontReg, TextSize=10,
	TextColor3=col.dim, Text="", TextXAlignment=Enum.TextXAlignment.Right,
	TextScaled=false, Parent=ProgressBar,
})

local function setProgress(pct, visible, info)
	ProgressBar.Visible = visible or (pct and pct > 0)
	if pct then tween(ProgressFill, 0.15, {Size=UDim2.fromScale(math.clamp(pct,0,1), 1)}) end
	if info then ProgressLabel.Text = info end
end

label({Name="Notice",
	Text="Batch: IDs por línea. Loop: repite hasta STOP. Fake All (Passes): dispara todos los detectados.",
	Size=UDim2.fromScale(0.8244,0.12), Position=UDim2.fromScale(0.4841,0.86),
	Parent=FakerScreen})

local function shake(obj, base)
	task.spawn(function()
		for _, o in ipairs({7,-6,4,-3,2,0}) do
			tween(obj,0.04,{Position=base+UDim2.fromOffset(o,0)},Enum.EasingStyle.Sine)
			task.wait(0.04)
		end
		obj.Position = base
	end)
end

-- ==================== ROW / LIST ====================
local function makeRow(list, data, actionImage, onAction, bulk)
	local row = create("Frame",{
		Name="Row", Size=UDim2.new(1,-8,0,66), BackgroundColor3=col.panel,
		BorderSizePixel=0, LayoutOrder=data.order or 0,
	},{corner(), stroke()})
	row:SetAttribute("IsRow", true)
	if data.id then row:SetAttribute("ProductId", tostring(data.id)) end
	if data.kind then row:SetAttribute("ProductKind", tostring(data.kind)) end

	create("ImageLabel",{
		Name="Icon", AnchorPoint=Vector2.new(0.5,0.5),
		Position=UDim2.new(0,35,0.5,0), Size=UDim2.fromOffset(49,49),
		BackgroundColor3=col.button, BorderSizePixel=0, Image=data.icon or "",
		ScaleType=Enum.ScaleType.Crop, Parent=row,
	},{corner(), stroke()})

	label({Name="Title", AnchorPoint=Vector2.new(0,0.5), Position=UDim2.new(0,71,0,24),
		Size=UDim2.new(1,-120,0,17), Text=data.title or "", FontFace=fontBold,
		TextXAlignment=Enum.TextXAlignment.Left, Parent=row})
	label({Name="Sub", AnchorPoint=Vector2.new(0,0.5), Position=UDim2.new(0,71,0,41),
		Size=UDim2.new(1,-120,0,17), Text=data.sub or "", TextColor3=col.icon,
		TextXAlignment=Enum.TextXAlignment.Left, Parent=row})

	local action = create("ImageButton",{
		Name="Action", AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(1,-30,0.5,0),
		Size=UDim2.fromOffset(32,32), BackgroundColor3=col.button,
		BorderSizePixel=0, Image=actionImage, ImageColor3=col.icon,
		AutoButtonColor=false, Parent=row,
	},{corner(), stroke(), create("UIScale")})
	buttonFx(action)
	action.MouseButton1Click:Connect(onAction)

	if data.onClick then
		row.InputBegan:Connect(function(input) if isClick(input) then data.onClick() end end)
	end
	row.MouseEnter:Connect(function() tween(row,0.15,{BackgroundColor3=col.panelHi}) end)
	row.MouseLeave:Connect(function() tween(row,0.2,{BackgroundColor3=col.panel}) end)
	row.Parent = list
	if not bulk and list.Visible and Main.Visible then
		fade(row,0,0); fade(row,1,0.3)
	end
	return row
end

local function clearList(list)
	for _, c in ipairs(list:GetChildren()) do
		if c:GetAttribute("IsRow") then c:Destroy() end
	end
end

local function copyId(id)
	if copy(id) then Stats.copies += 1; toast("Copied "..tostring(id), col.green)
	else toast("Clipboard unavailable", col.red) end
end

-- ==================== SEARCH ====================
local function attachSearch(list, placeholder)
	local holder = create("Frame",{
		Name="SearchHolder", Size=UDim2.new(1,-8,0,26),
		Position=UDim2.new(0,4,0,2), BackgroundColor3=col.panel,
		BorderSizePixel=0, Visible=false, ZIndex=10, Parent=list.Parent,
	},{corner(6), stroke()})
	local box = create("TextBox",{
		Name="SearchBox", AnchorPoint=Vector2.new(0.5,0.5),
		Position=UDim2.fromScale(0.5,0.5), Size=UDim2.new(1,-16,1,-6),
		BackgroundTransparency=1, FontFace=fontReg,
		PlaceholderText=placeholder or "Search...", PlaceholderColor3=col.dim,
		Text="", TextColor3=col.white, TextSize=13,
		TextXAlignment=Enum.TextXAlignment.Left, ClearTextOnFocus=false, Parent=holder,
	})
	local pad = list:FindFirstChildOfClass("UIPadding")
	if pad then pad.PaddingTop = UDim.new(0, 34) end

	local function apply()
		local q = box.Text:lower():gsub("^%s+",""):gsub("%s+$","")
		for _, c in ipairs(list:GetChildren()) do
			if c:GetAttribute("IsRow") then
				local t = c:FindFirstChild("Title")
				if q == "" then c.Visible = true
				else c.Visible = t and t.Text:lower():find(q,1,true) ~= nil end
			end
		end
	end
	box:GetPropertyChangedSignal("Text"):Connect(apply)
	box.Focused:Connect(function() tween(holder,0.15,{BackgroundColor3=col.panelHi}) end)
	box.FocusLost:Connect(function() tween(holder,0.15,{BackgroundColor3=col.panel}) end)
	list:GetPropertyChangedSignal("Visible"):Connect(function() holder.Visible = list.Visible end)
	return holder
end

attachSearch(ProductLogger, "Search logs...")
attachSearch(SupportedContainer, "Search supported games...")
attachSearch(GamepassList, "Search passes...")

-- ==================== PASSES ACTIONS (4 botones) ====================
local PassesActions = create("Frame",{
	Name="PassesActions", AnchorPoint=Vector2.new(1,1),
	Position=UDim2.new(1,-4,1,22), Size=UDim2.fromOffset(260,24),
	BackgroundTransparency=1, ZIndex=10, Parent=GamepassList.Parent,
},{create("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,
	HorizontalAlignment=Enum.HorizontalAlignment.Right, Padding=UDim.new(0,4)})})

local function miniBtn(parent, text, color, onClick, width)
	local b = create("TextButton",{
		Size=UDim2.fromOffset(width or 60,24), BackgroundColor3=col.panel,
		BorderSizePixel=0, Text=text, FontFace=fontBold, TextSize=11,
		TextColor3=color or col.white, AutoButtonColor=false, Parent=parent,
	},{corner(6), stroke(), create("UIScale")})
	local sc = b:FindFirstChildOfClass("UIScale")
	b.MouseEnter:Connect(function() tween(b,0.15,{BackgroundColor3=col.buttonHi}) end)
	b.MouseLeave:Connect(function() tween(b,0.2,{BackgroundColor3=col.panel}) end)
	b.MouseButton1Down:Connect(function() tween(sc,0.08,{Scale=0.9}) end)
	b.MouseButton1Up:Connect(function() tween(sc,0.35,{Scale=1},Enum.EasingStyle.Back) end)
	b.MouseButton1Click:Connect(onClick)
	return b
end

-- Scan button
miniBtn(PassesActions, "Rescan", col.blue, function()
	if scanning then return end
	if scanProducts then scanProducts() end
end, 60)

-- 🆕 Fake Detected button (green → rojo STOP cuando corre)
local FakeDetectedBtn = miniBtn(PassesActions, "Fake All", col.green, function() end, 68)

-- Copy All
miniBtn(PassesActions, "Copy IDs", col.green, function()
	local ids = {}
	for _, c in ipairs(GamepassList:GetChildren()) do
		if c:GetAttribute("IsRow") and c.Visible then
			local id = c:GetAttribute("ProductId")
			if id then table.insert(ids, tostring(id)) end
		end
	end
	if #ids == 0 then toast("No hay IDs", col.red); return end
	if copy(table.concat(ids, ",")) then
		Stats.copies += #ids
		toast(("Copiados %d IDs"):format(#ids), col.green)
	else toast("Clipboard no disponible", col.red) end
end, 62)

-- Clear
miniBtn(PassesActions, "Clear", col.red, function()
	clearList(GamepassList)
	toast("Lista limpiada")
end, 54)

-- ==================== INFO / KIND ====================
local knownKinds = {}
local infoTypes = {
	Product=getEnum("InfoType","Product"), Gamepass=getEnum("InfoType","GamePass"),
	Asset=getEnum("InfoType","Asset"), Bundle=getEnum("InfoType","Bundle"),
	Subscription=getEnum("InfoType","Subscription"),
}
local infoCache = {}
local function getInfo(kind, id)
	local key = kind..":"..tostring(id)
	if infoCache[key] ~= nil then return infoCache[key] end
	local info = false
	if infoTypes[kind] and tonumber(id) then
		local ok, res = pcall(function() return MarketplaceService:GetProductInfo(tonumber(id), infoTypes[kind]) end)
		if ok and type(res) == "table" then info = res end
	end
	infoCache[key] = info
	return info
end

local function sendToFaker(id)
	InpBox.Text = tostring(id)
	setTabByName("Faker")
	toast("ID loaded: "..tostring(id))
end

-- ==================== FAKE ENGINE ====================
local fire = {
	Product  = function(id) MarketplaceService:SignalPromptProductPurchaseFinished(LocalPlayer.UserId, id, true) end,
	Gamepass = function(id) MarketplaceService:SignalPromptGamePassPurchaseFinished(LocalPlayer, id, true) end,
	Asset    = function(id) MarketplaceService:SignalPromptPurchaseFinished(LocalPlayer, id, true) end,
	Bundle   = function(id) MarketplaceService:SignalPromptBundlePurchaseFinished(LocalPlayer, id, true) end,
}

local function tryFiresignal(id, kind)
	if typeof(firesignal) ~= "function" or typeof(getconnections) ~= "function" then return false end
	local sigMap = {
		Product="PromptProductPurchaseFinished", Gamepass="PromptGamePassPurchaseFinished",
		Asset="PromptPurchaseFinished", Bundle="PromptBundlePurchaseFinished",
	}
	local name = sigMap[kind]; if not name then return false end
	local sig = MarketplaceService[name]; if not sig then return false end
	local conns = getconnections(sig); if not conns or #conns == 0 then return false end
	for _, c in ipairs(conns) do
		local ok = pcall(function()
			if c.Fire then c:Fire(kind=="Product" and LocalPlayer.UserId or LocalPlayer, id, true)
			elseif c.fire then c:fire(kind=="Product" and LocalPlayer.UserId or LocalPlayer, id, true) end
		end)
		if ok then return true end
	end
	return false
end

local DETECT_ORDER = {"Product","Gamepass","Asset","Bundle"}
local function detectKind(id)
	local k = knownKinds[tostring(id)]
	if k and fire[k] then return k end
	for _, kind in ipairs(DETECT_ORDER) do
		if getInfo(kind, id) then knownKinds[tostring(id)] = kind; return kind end
	end
	return "Product"
end

local function improvedFake(id)
	local kind = detectKind(id)
	if pcall(fire[kind], id) then Stats.fakes += 1; return kind end
	if tryFiresignal(id, kind) then Stats.fakes += 1; return kind end
	if kind ~= "Product" and pcall(fire.Product, id) then Stats.fakes += 1; return "Product" end
	warn("[Product Faker] fake failed for "..tostring(id))
	return "fail"
end

-- ==================== SUBMIT + LOOP + MASS ====================
local loopState = {enabled=false, delay=0.5, running=false, task=nil}
local massState = {running=false, cancel=false, task=nil}

local function parseIds()
	local ids = {}
	for line in InpBox.Text:gmatch("[^\n]+") do
		local id = tonumber((line:gsub("%s","")):match("%d+"))
		if id then table.insert(ids, id) end
	end
	return ids
end

local function stopLoop()
	loopState.running = false
	if loopState.task then pcall(task.cancel, loopState.task); loopState.task = nil end
	FakeOneLbl.Text = "Fake One"; FakeAllLbl.Text = "Fake ALL"
	tween(FakeButton, 0.2, {BackgroundColor3=col.panel})
	tween(FakeAllBtn, 0.2, {BackgroundColor3=col.panel})
	setProgress(0, false, "")
end

local function stopMass()
	massState.cancel = true
	FakeDetectedBtn.Text = "Fake All"
	tween(FakeDetectedBtn, 0.2, {BackgroundColor3=col.panel})
	tween(FakeDetectedBtn, 0.2, {TextColor3=col.green})
end

local function stopAll()
	if loopState.running then stopLoop() end
	if massState.running then stopMass() end
end

local function fireAll(ids)
	local ok, fail = 0, 0
	for i, id in ipairs(ids) do
		if destroyed or loopState.cancel then break end
		local s, kind = pcall(improvedFake, id)
		if s and kind ~= "fail" then ok += 1 else fail += 1 end
		task.wait(0.08)
	end
	return ok, fail
end

local function startLoop(ids, source)
	if #ids == 0 then shake(IdInput, idInputPos); toast("No hay IDs", col.red); return end
	if massState.running then stopMass() end
	loopState.running = true; loopState.cancel = false

	if source == "all" then
		FakeAllLbl.Text = "STOP"; tween(FakeAllBtn, 0.2, {BackgroundColor3=Color3.fromRGB(150,40,40)})
	else
		FakeOneLbl.Text = "STOP"; tween(FakeButton, 0.2, {BackgroundColor3=Color3.fromRGB(150,40,40)})
	end
	toast(("Loop iniciado — %d ID(s) cada %.2fs"):format(#ids, loopState.delay), col.green)

	loopState.task = task.spawn(function()
		while loopState.running and not destroyed do
			fireAll(ids)
			if not loopState.running or destroyed then break end
			local t0 = os.clock()
			while loopState.running and not destroyed and (os.clock()-t0) < loopState.delay do
				task.wait(0.05)
			end
		end
	end)
end

local function submitFakeOne()
	local ids = parseIds()
	if #ids == 0 then
		shake(IdInput, idInputPos); IdStroke.Color = col.red; IdStroke.Transparency = 0.3
		tween(IdStroke, 0.6, {Color=col.white, Transparency=0.86})
		toast("Enter a valid ID", col.red); return
	end
	if loopState.running then stopLoop() return end
	if massState.running then stopMass() return end

	if loopState.enabled then
		startLoop({ids[1]}, "one")
	else
		local ok, kind = pcall(improvedFake, ids[1])
		if ok and kind ~= "fail" then toast(("Fired %s %d"):format(tostring(kind):lower(), ids[1]), col.green)
		else toast("Error, check console", col.red) end
	end
end

local function submitFakeAll()
	local ids = parseIds()
	if #ids == 0 then shake(IdInput, idInputPos); toast("No hay IDs", col.red); return end
	if loopState.running then stopLoop() return end
	if massState.running then stopMass() return end

	if loopState.enabled then
		startLoop(ids, "all")
	else
		toast(("Firing %d IDs..."):format(#ids))
		task.spawn(function()
			local ok, fail = 0, 0
			for i, id in ipairs(ids) do
				if destroyed then break end
				local s, kind = pcall(improvedFake, id)
				if s and kind ~= "fail" then ok += 1 else fail += 1 end
				setProgress(i/#ids, true, ("%d/%d"):format(i, #ids))
				task.wait(0.08)
			end
			setProgress(0, false, "")
			toast(("Batch done: %d ok, %d fail"):format(ok, fail), fail == 0 and col.green or col.yellow)
		end)
	end
end

-- 🆕 FAKE ALL DETECTED
local function fakeAllDetected()
	if massState.running then stopMass() return end
	if loopState.running then stopLoop() end

	local items = {}
	for _, c in ipairs(GamepassList:GetChildren()) do
		if c:GetAttribute("IsRow") then
			local id = c:GetAttribute("ProductId")
			if id then table.insert(items, {id = id, row = c}) end
		end
	end
	if #items == 0 then toast("No hay detectados — reescanea primero", col.red); return end

	massState.running = true; massState.cancel = false
	FakeDetectedBtn.Text = "STOP"
	tween(FakeDetectedBtn, 0.2, {BackgroundColor3=Color3.fromRGB(150,40,40)})
	tween(FakeDetectedBtn, 0.2, {TextColor3=col.white})

	toast(("Faking %d detectados..."):format(#items), col.green)

	massState.task = task.spawn(function()
		local ok, fail = 0, 0
		for i, item in ipairs(items) do
			if massState.cancel or destroyed then break end
			local s, kind = pcall(improvedFake, item.id)
			local success = s and kind ~= "fail"
			if success then ok += 1 else fail += 1 end

			-- tinte de fila verde/rojo
			if item.row and item.row.Parent then
				local tint = success and col.green or col.red
				tween(item.row, 0.1, {BackgroundColor3 = tint:Lerp(col.panel, 0.75)})
				task.delay(0.4, function()
					if item.row and item.row.Parent then
						tween(item.row, 0.3, {BackgroundColor3 = col.panel})
					end
				end)
			end
			setProgress(i/#items, true, ("%d/%d"):format(i, #items))
			task.wait(0.08)
		end
		massState.running = false
		FakeDetectedBtn.Text = "Fake All"
		tween(FakeDetectedBtn, 0.2, {BackgroundColor3=col.panel})
		tween(FakeDetectedBtn, 0.2, {TextColor3=col.green})
		task.wait(0.5)
		setProgress(0, false, "")
		toast(("Detected done: %d ok, %d fail"):format(ok, fail),
			fail == 0 and col.green or col.yellow)
	end)
end

FakeDetectedBtn.MouseButton1Click:Connect(fakeAllDetected)

LoopToggle.MouseButton1Click:Connect(function()
	loopState.enabled = not loopState.enabled
	LoopToggle.Text = loopState.enabled and "Loop: ON" or "Loop: OFF"
	LoopToggle.TextColor3 = loopState.enabled and col.green or col.red
end)

IntervalBox.FocusLost:Connect(function()
	local v = tonumber(IntervalBox.Text)
	if v and v >= 0.05 then loopState.delay = math.clamp(v, 0.05, 60) end
	IntervalBox.Text = tostring(loopState.delay)
end)

FakeButton.MouseButton1Click:Connect(submitFakeOne)
FakeAllBtn.MouseButton1Click:Connect(submitFakeAll)
InpBox.FocusLost:Connect(function(enterPressed)
	tween(IdStroke,0.2,{Transparency=0.86})
	tween(IdInput,0.2,{BackgroundColor3=col.panel})
	if enterPressed then submitFakeOne() end
end)

-- ==================== PASS FINDER ====================
local function addPass(data, bulk)
	knownKinds[tostring(data.id)] = data.kind
	local icon = data.icon
	if not icon and data.kind == "Gamepass" then
		icon = ("rbxthumb://type=GamePass&id=%d&w=150&h=150"):format(data.id)
	end
	local price = data.price and ("R$"..commas(data.price)) or "Offsale"
	return makeRow(GamepassList, {
		id = data.id,
		kind = data.kind,
		title = data.name or tostring(data.id),
		sub = data.kind.."  •  "..price,
		icon = icon, order = data.order,
		onClick = function() sendToFaker(data.id) end,
	}, img.copy, function() copyId(data.id) end, bulk)
end

local httpRequest = (typeof(request)=="function" and request)
	or (typeof(http_request)=="function" and http_request)
	or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request)

local function getJson(url)
	local body
	if httpRequest then
		local ok, res = pcall(httpRequest, {Url=url, Method="GET"})
		if ok and type(res)=="table" and (res.StatusCode==200 or (res.StatusCode==nil and res.Success)) then
			body = res.Body
		end
	end
	if not body then
		local ok, res = pcall(function() return game:HttpGet(url) end)
		if ok then body = res end
	end
	if type(body) ~= "string" or body == "" then return nil end
	local ok, data = pcall(HttpService.JSONDecode, HttpService, body)
	return ok and data or nil
end

local function nonEmpty(s) return type(s)=="string" and s~="" and s or nil end

local passSources = {
	{
		hosts = {"apis.roblox.com","apis.roproxy.com"},
		url = function(h, u, c)
			local p = c and "&pageToken="..HttpService:UrlEncode(c) or ""
			return ("https://%s/game-passes/v1/universes/%d/game-passes?passView=Full&pageSize=100%s"):format(h, u, p)
		end,
		parse = function(d)
			if type(d)~="table" or type(d.gamePasses)~="table" then return nil end
			local out = {}
			for _, p in ipairs(d.gamePasses) do
				local pi = type(p.priceInformation)=="table" and p.priceInformation or {}
				table.insert(out, {id=p.id or p.gamePassId, name=p.displayName or p.name,
					price=p.price or pi.defaultPriceInRobux or pi.price})
			end
			return out, nonEmpty(d.nextPageToken)
		end,
	},
	{
		hosts = {"games.roblox.com","games.roproxy.com"},
		url = function(h, u, c)
			local p = c and "&cursor="..HttpService:UrlEncode(c) or ""
			return ("https://%s/v1/games/%d/game-passes?limit=100&sortOrder=Asc%s"):format(h, u, p)
		end,
		parse = function(d)
			if type(d)~="table" or type(d.data)~="table" then return nil end
			local out = {}
			for _, p in ipairs(d.data) do
				table.insert(out, {id=p.id, name=p.displayName or p.name, price=p.price})
			end
			return out, nonEmpty(d.nextPageCursor)
		end,
	},
}

local function fetchGamepasses(universeId)
	for _, src in ipairs(passSources) do
		for _, host in ipairs(src.hosts) do
			local all, cursor = src.parse(getJson(src.url(host, universeId)))
			if all then
				local pages = 1
				while cursor and pages < 25 and not destroyed do
					local more, nc = src.parse(getJson(src.url(host, universeId, cursor)))
					if not more then break end
					for _, p in ipairs(more) do table.insert(all, p) end
					cursor, pages = nc, pages + 1
				end
				return all
			end
		end
	end
	return nil
end

local function fetchProducts()
	local ok, pages = pcall(function() return MarketplaceService:GetDeveloperProductsAsync() end)
	if not ok or not pages then return nil end
	local out = {}
	for _ = 1, 50 do
		local okP, page = pcall(function() return pages:GetCurrentPage() end)
		if not okP then break end
		for _, item in ipairs(page) do
			local iconId = item.IconImageAssetId
			table.insert(out, {
				id = item.ProductId or item.DeveloperProductId,
				name = item.Name or item.DisplayName,
				price = item.PriceInRobux,
				icon = iconId and iconId ~= 0 and ("rbxassetid://"..iconId) or nil,
			})
		end
		if pages.IsFinished or not pcall(function() pages:AdvanceToNextPageAsync() end) then break end
	end
	return out
end

local scanning = false
local function scanProducts()
	if scanning or destroyed then return end
	scanning = true
	clearList(GamepassList)
	local empty = emptyLabels[GamepassList]; empty.Text = "Scanning..."

	task.spawn(function()
		local passes, products
		local dP, dPr = false, false
		task.spawn(function() passes = fetchGamepasses(game.GameId) or false; dP = true end)
		task.spawn(function() products = fetchProducts() or false; dPr = true end)
		local t0 = os.clock()
		while (not dP or not dPr) and not destroyed do
			if os.clock()-t0 > 30 then break end; task.wait()
		end
		if destroyed then return end

		local function byPrice(a,b) return (a.price or math.huge) < (b.price or math.huge) end
		local order = 0
		for _, g in ipairs({{passes,"Gamepass"},{products,"Product"}}) do
			local items, kind = g[1], g[2]
			if items then
				table.sort(items, byPrice)
				for _, it in ipairs(items) do
					if it.id then
						order += 1
						addPass({id=it.id, name=it.name, price=it.price, icon=it.icon, kind=kind, order=order}, true)
					end
				end
			end
		end
		empty.Text = "Nothing found for this game."
		local nP, nPr = passes and #passes or 0, products and #products or 0
		if not passes and not products then toast("Couldn't fetch", col.red)
		elseif not passes then toast(("Found %d products"):format(nPr), col.yellow)
		elseif not products then toast(("Found %d gamepasses"):format(nP), col.yellow)
		else toast(("Found %d gamepasses, %d products"):format(nP, nPr), col.green) end
		scanning = false
	end)
end

-- ==================== LOGGER ====================
emptyLabels[ProductLogger].Text = "Waiting for purchase prompts..."
local logLimit, logOrder, logRows = 100, 0, {}
local lastPrompt, pendingRows = {}, {}

local function iconFor(kind, id, info)
	local n = tonumber(id)
	if n and kind == "Gamepass" then return ("rbxthumb://type=GamePass&id=%d&w=150&h=150"):format(n) end
	if n and kind == "Asset" then return ("rbxthumb://type=Asset&id=%d&w=150&h=150"):format(n) end
	if n and kind == "Bundle" then return ("rbxthumb://type=BundleThumbnail&id=%d&w=150&h=150"):format(n) end
	local ic = info and info.IconImageAssetId
	if ic and ic ~= 0 then return "rbxassetid://"..ic end
end

local function addLog(data)
	logOrder -= 1
	knownKinds[tostring(data.id)] = data.kind
	local sub = {data.kind}
	if data.price then table.insert(sub, "R$"..commas(data.price)) end
	table.insert(sub, os.date("%H:%M:%S"))
	local row = makeRow(ProductLogger, {
		id=data.id, kind=data.kind,
		title=data.name or tostring(data.id),
		sub=table.concat(sub, "  •  "),
		icon=data.icon, order=logOrder,
		onClick=function() sendToFaker(data.id) end,
	}, img.copy, function() copyId(data.id) end)
	table.insert(logRows, row)
	if #logRows > logLimit then table.remove(logRows, 1):Destroy() end
	return row
end

local function logPrompt(kind, id)
	if destroyed or id == nil then return end
	local key = kind..":"..tostring(id)
	local now = os.clock()
	if lastPrompt[key] and now - lastPrompt[key] < 0.5 then return end
	lastPrompt[key] = now
	task.spawn(function()
		local info = getInfo(kind, id)
		if destroyed then return end
		pendingRows[key] = addLog({
			id=id, kind=kind,
			name=info and (info.Name or info.DisplayName),
			price=info and (info.PriceInRobux or info.Price),
			icon=iconFor(kind, id, info),
		})
		if not ProductLogger.Visible then toast(("Logged %s %s"):format(kind:lower(), tostring(id))) end
	end)
end

local function markFinished(kind, id, purchased)
	local key = kind..":"..tostring(id)
	local row = pendingRows[key]; pendingRows[key] = nil
	local sub = row and row.Parent and row:FindFirstChild("Sub")
	if sub then
		sub.Text = sub.Text.."  •  "..(purchased and "Bought" or "Closed")
		tween(sub, 0.3, {TextColor3 = purchased and col.green or col.dim})
	end
end

local function firstId(...)
	for i = 1, select("#", ...) do
		local v = select(i, ...)
		if type(v) == "number" or (type(v) == "string" and v ~= "") then return v end
	end
end
local function lastBool(...)
	for i = select("#", ...), 1, -1 do
		local v = select(i, ...); if type(v) == "boolean" then return v end
	end
	return false
end

local promptKinds = {
	ProductPurchase="Product", GamePassPurchase="Gamepass", Purchase="Asset",
	BundlePurchase="Bundle", SubscriptionPurchase="Subscription",
}
for suffix, kind in pairs(promptKinds) do
	pcall(function()
		bind(MarketplaceService["Prompt"..suffix.."Requested"], function(_, ...) logPrompt(kind, firstId(...)) end)
	end)
	pcall(function()
		bind(MarketplaceService["Prompt"..suffix.."Finished"], function(_, ...) markFinished(kind, firstId(...), lastBool(...)) end)
	end)
end

-- ==================== SUPPORTED ====================
local function getFromHosts(path, hosts)
	for _, host in ipairs(hosts) do
		local d = getJson("https://"..host..path)
		if type(d) == "table" then return d end
	end
end
local universeCache = {}
local function getUniverseId(placeId)
	if placeId == game.PlaceId and game.GameId ~= 0 then return game.GameId end
	if universeCache[placeId] then return universeCache[placeId] end
	local d = getFromHosts("/universes/v1/places/"..placeId.."/universe", {"apis.roblox.com","apis.roproxy.com"})
	local id = d and tonumber(d.universeId); universeCache[placeId] = id; return id
end
local function getGameStats(ids)
	local out = {}
	for i = 1, #ids, 50 do
		local chunk = table.concat(ids, ",", i, math.min(i+49, #ids))
		local d = getFromHosts("/v1/games?universeIds="..chunk, {"games.roblox.com","games.roproxy.com"})
		if d and type(d.data) == "table" then for _, g in ipairs(d.data) do out[tonumber(g.id)] = g end end
	end
	return out
end

local loadingSupported = false
local function loadSupported()
	if loadingSupported or destroyed then return end
	loadingSupported = true
	local empty = emptyLabels[SupportedContainer]
	clearList(SupportedContainer); empty.Text = "Loading supported games..."

	task.spawn(function()
		local ok, list = pcall(function() return loadstring(game:HttpGet(supportedUrl))() end)
		if destroyed then return end
		if not ok or type(list) ~= "table" then
			empty.Text = "Couldn't load the supported games list."; loadingSupported = false; return
		end
		clearList(SupportedContainer); empty.Text = "No supported games listed."
		local entries, supportedHere = {}, false
		for i, entry in ipairs(list) do
			local placeId, name = entry, nil
			if type(entry) == "table" then placeId, name = entry.PlaceId or entry[1], entry.Name end
			placeId = tonumber(placeId)
			if placeId then
				local here = placeId == game.PlaceId
				supportedHere = supportedHere or here
				local row = makeRow(SupportedContainer, {
					title = name or "Place "..placeId,
					sub = here and "You're in this game" or "Loading...",
					icon = ("rbxthumb://type=Asset&id=%d&w=150&h=150"):format(placeId),
					order = here and -1 or i,
				}, img.join, function()
					if here then toast("You're already here", col.yellow)
					else toast("Teleporting..."); pcall(TeleportService.Teleport, TeleportService, placeId, LocalPlayer) end
				end, true)
				if here then row.Sub.TextColor3 = col.green end
				table.insert(entries, {row=row, placeId=placeId, here=here, named=name~=nil})
			end
		end
		if supportedHere then toast("This game is supported", col.green) end
		local pending = #entries
		for _, e in ipairs(entries) do
			task.spawn(function()
				local okId, id = pcall(getUniverseId, e.placeId)
				e.universeId = okId and id or nil; pending -= 1
			end)
		end
		local t0 = os.clock()
		while pending > 0 and not destroyed do
			if os.clock()-t0 > 30 then break end; task.wait()
		end
		if destroyed then return end
		local ids, seen = {}, {}
		for _, e in ipairs(entries) do
			if e.universeId and not seen[e.universeId] then seen[e.universeId] = true; table.insert(ids, e.universeId) end
		end
		local stats = #ids > 0 and getGameStats(ids) or {}
		for _, e in ipairs(entries) do
			local row = e.row
			if row.Parent then
				local g = e.universeId and stats[e.universeId]
				local prefix = e.here and "You're here  •  " or ""
				row.Sub.Text = (g and g.playing) and (prefix..commas(g.playing).." playing") or (prefix.."Players unavailable")
				if not e.named and g and g.name then row.Title.Text = g.name end
			end
		end
		loadingSupported = false
	end)
end

-- ==================== TABS / UI ====================
local tabs = {
	{name="Home", button=HomeButton, screen=HomeScreen},
	{name="Faker", button=FakerButton, screen=FakerScreen},
	{name="Logger", button=LoggerButton, screen=ProductLogger},
	{name="Supported", button=SupportedButton, screen=SupportedContainer},
	{name="Passes", button=PassListButton, screen=GamepassList},
}
local navActive = {BackgroundColor3=col.active, ImageColor3=col.white}
local currentTab

local function moveIndicator(instant)
	if not currentTab then return end
	local btn = tabs[currentTab].button
	local s = MainScale.Scale > 0 and MainScale.Scale or 1
	local x = (btn.AbsolutePosition.X + btn.AbsoluteSize.X/2 - BottomBar.AbsolutePosition.X)/s
	local pos = UDim2.new(0, x, 1, -2)
	if instant then Indicator.Position = pos else tween(Indicator, 0.4, {Position=pos}) end
end

local function setTab(index, instant)
	if index == currentTab then return end
	local prev = currentTab
	local dir = (prev and index < prev) and -1 or 1
	currentTab = index
	for i, tab in ipairs(tabs) do
		local goal = i == index and navActive or idle
		if instant then for k, v in pairs(goal) do tab.button[k] = v end
		else tween(tab.button, 0.2, goal) end
	end
	moveIndicator(instant)
	if prev then
		local old = tabs[prev].screen
		if instant then old.Visible = false
		else
			fade(old, 0, 0.15)
			tween(old, 0.25, {Position=UDim2.fromScale(-0.06*dir, 0)})
			task.delay(0.25, function()
				if tabs[currentTab].screen ~= old then old.Visible = false end
			end)
		end
	end
	local screen = tabs[index].screen
	screen.Visible = true
	if instant then screen.Position = UDim2.new(); fade(screen,1,0)
	else
		screen.Position = UDim2.fromScale(0.06*dir, 0)
		fade(screen,0,0); tween(screen,0.4,{Position=UDim2.new()}); fade(screen,1,0.3)
	end
end

local function setTabByName(name)
	for i, t in ipairs(tabs) do if t.name == name then setTab(i); return end end
end

for i, tab in ipairs(tabs) do
	buttonFx(tab.button, idle, hover, function() return currentTab == i end)
	tab.button.MouseButton1Click:Connect(function()
		if currentTab == i and tab.name == "Passes" and scanProducts then scanProducts()
		elseif currentTab == i and tab.name == "Supported" and loadSupported then loadSupported()
		else setTab(i) end
	end)
end

BottomBar:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() moveIndicator(true) end)
BottomBar:GetPropertyChangedSignal("AbsolutePosition"):Connect(function() moveIndicator(true) end)

-- Drag
do
	local dragging, dragStart, startPos
	TopBar.InputBegan:Connect(function(input)
		if not isClick(input) then return end
		local pos = input.Position
		local cp, cs = CloseButton.AbsolutePosition, CloseButton.AbsoluteSize
		if pos.X >= cp.X and pos.X <= cp.X+cs.X and pos.Y >= cp.Y and pos.Y <= cp.Y+cs.Y then return end
		dragging, dragStart, startPos = true, input.Position, Main.Position
		local c
		c = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false; c:Disconnect() end
		end)
	end)
	bind(UserInputService.InputChanged, function(input)
		if not dragging then return end
		local t = input.UserInputType
		if t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch then
			local d = input.Position - dragStart
			Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
		end
	end)
end

-- ==================== ASCII ====================
local ascii = {}
do
	local font = Enum.Font.Code
	local huge = Vector2.new(1e5, 1e5)
	local size = asciiCfg.textSize
	local cw = TextService:GetTextSize(string.rep("M",40), size, font, huge).X/40
	local h1 = TextService:GetTextSize("M", size, font, huge).Y
	local h11 = TextService:GetTextSize(string.rep("M\n",10).."M", size, font, huge).Y
	local ch = (h11-h1)/10
	if cw <= 0 then cw = size*0.6 end
	if ch <= 0 then ch = size end
	local layers = {{min=0.1,transparency=0.84},{min=0.4,transparency=0.62},{min=0.7,transparency=0.3}}
	local labels = {}
	for i in ipairs(layers) do
		labels[i] = create("TextLabel",{
			Name="Layer"..i, BackgroundTransparency=1, Font=font, TextSize=size,
			TextColor3=asciiCfg.color, TextTransparency=1,
			TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top,
			TextWrapped=false, RichText=false, Text="", ZIndex=1, Parent=AsciiHolder,
		})
	end
	local ramp = {}
	for i = 1, #asciiCfg.ramp do ramp[i] = asciiCfg.ramp:sub(i,i) end
	local rampLen = #ramp
	local cols, rows, offX, offY = 0,0,0,0
	local glow, bufs, lines = {}, {{},{},{}}, {{},{},{}}

	function ascii.rebuild(area, inner)
		cols = math.max(1, math.floor(area.X/cw)); rows = math.max(1, math.floor(area.Y/ch))
		offX = (area.X-cols*cw)/2; offY = (area.Y-rows*ch)/2
		for _, l in ipairs(labels) do
			l.Position = UDim2.fromOffset(offX, offY)
			l.Size = UDim2.fromOffset(cols*cw+4, rows*ch+4)
		end
		local cx, cy = area.X/2, area.Y/2
		local hw, hh = inner.X/2, inner.Y/2
		local pad = asciiCfg.padding
		table.clear(glow)
		for y = 0, rows-1 do
			local qy = math.max(math.abs(offY+(y+0.5)*ch-cy)-hh, 0)
			for x = 0, cols-1 do
				local qx = math.max(math.abs(offX+(x+0.5)*cw-cx)-hw, 0)
				local i = y*cols+x+1
				if qx == 0 and qy == 0 then glow[i] = -1
				else
					local g = math.clamp(1 - math.sqrt(qx*qx+qy*qy)/pad, 0, 1)
					glow[i] = g*g*(3-2*g)
				end
			end
		end
		for _, b in ipairs(bufs) do table.clear(b) end
	end

	local noise, sin, cos, sqrt, exp, floor = math.noise, math.sin, math.cos, math.sqrt, math.exp, math.floor
	local min1, min2, min3 = layers[1].min, layers[2].min, layers[3].min
	local aspect = ch/cw

	function ascii.render(t, alpha, mx, my)
		local mcx, mcy
		if mx then mcx, mcy = (mx-offX)/cw, (my-offY)/ch end
		local b1, b2, b3 = bufs[1], bufs[2], bufs[3]
		local l1, l2, l3 = lines[1], lines[2], lines[3]
		for y = 0, rows-1 do
			local base = y*cols
			local ny = y*0.11 - t*0.35
			local wy = cos(y*0.21 - t*0.7)
			for x = 0, cols-1 do
				local g = glow[base+x+1]
				local c1, c2, c3 = " ", " ", " "
				if g > 0 then
					local v = 0.45 + noise(x*0.055, ny, t*0.12)*1.3 + sin(x*0.12+t*1.1)*wy*0.18
					if mcx then
						local dx, dy = x-mcx, (y-mcy)*aspect
						local d = sqrt(dx*dx+dy*dy)
						v += sin(d*0.45-t*7)*exp(-d*0.09)*0.45
					end
					v *= g*alpha
					if v >= min1 then
						local idx = math.clamp(floor(v*rampLen)+1, 2, rampLen)
						local glyph = ramp[idx]
						if v >= min3 then c3 = glyph
						elseif v >= min2 then c2 = glyph
						else c1 = glyph end
					end
				end
				b1[x+1], b2[x+1], b3[x+1] = c1, c2, c3
			end
			l1[y+1] = table.concat(b1, "", 1, cols)
			l2[y+1] = table.concat(b2, "", 1, cols)
			l3[y+1] = table.concat(b3, "", 1, cols)
		end
		labels[1].Text = table.concat(l1, "\n", 1, rows)
		labels[2].Text = table.concat(l2, "\n", 1, rows)
		labels[3].Text = table.concat(l3, "\n", 1, rows)
		for i, layer in ipairs(layers) do
			labels[i].TextTransparency = 1 - (1-layer.transparency)*alpha
		end
	end
end

local asciiAlpha = Instance.new("NumberValue")
do
	local acc, lastArea = 0, nil
	local start = os.clock()
	bind(RunService.RenderStepped, function(dt)
		AsciiHolder.Position = Main.Position
		if not asciiCfg.enabled then return end
		local alpha = asciiAlpha.Value
		if alpha <= 0.001 then return end
		acc += dt
		if acc < 1/asciiCfg.fps then return end
		acc = 0
		local s = MainScale.Scale > 0 and MainScale.Scale or 1
		local abs = Main.AbsoluteSize
		local inner = Vector2.new(math.floor(abs.X/s+0.5), math.floor(abs.Y/s+0.5))
		local area = inner + Vector2.new(asciiCfg.padding*2, asciiCfg.padding*2)
		if area ~= lastArea then
			lastArea = area
			AsciiHolder.Size = UDim2.fromOffset(area.X, area.Y)
			ascii.rebuild(area, inner)
		end
		local mx, my
		if asciiCfg.mouse then
			local m = UserInputService:GetMouseLocation() - AsciiHolder.AbsolutePosition
			if m.X >= 0 and m.Y >= 0 and m.X <= area.X and m.Y <= area.Y then mx, my = m.X, m.Y end
		end
		ascii.render(os.clock()-start, alpha, mx, my)
	end)
end

-- ==================== UI OPEN/CLOSE ====================
local UI = {}
local isOpen = false

local function open()
	if isOpen or destroyed then return end
	isOpen = true
	Main.Visible = true
	AsciiHolder.Visible = asciiCfg.enabled
	MainScale.Scale = 0.88
	fade(Main, 0, 0)
	tween(MainScale, 0.55, {Scale=1}, Enum.EasingStyle.Back)
	fade(Main, 1, 0.35)
	tween(asciiAlpha, 1, {Value=1}, Enum.EasingStyle.Sine)
	scramble(Title, title, 0.6)
	task.defer(moveIndicator, true)
end

local function hide(callback)
	if not isOpen then if callback then callback() end return end
	isOpen = false
	tween(MainScale, 0.25, {Scale=0.9}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	fade(Main, 0, 0.22)
	tween(asciiAlpha, 0.35, {Value=0}, Enum.EasingStyle.Quad)
	task.delay(0.36, function()
		if not isOpen then Main.Visible = false; AsciiHolder.Visible = false end
		if callback then callback() end
	end)
end

function UI.Toggle()
	if destroyed then return end
	if isOpen then hide() else open() end
end

function UI.Destroy(instant)
	if destroyed then return end
	destroyed = true
	if loopState.running then
		loopState.running = false
		if loopState.task then pcall(task.cancel, loopState.task) end
	end
	if massState.running then
		massState.running = false
		massState.cancel = true
		if massState.task then pcall(task.cancel, massState.task) end
	end
	if antiAfkConn then antiAfkConn:Disconnect(); antiAfkConn = nil end
	local function finish()
		for _, c in ipairs(connections) do c:Disconnect() end
		asciiAlpha:Destroy()
		ScreenGui:Destroy()
		if env.__ProductFaker == UI then env.__ProductFaker = nil end
	end
	if instant then finish() else hide(finish) end
end

CloseButton.MouseButton1Click:Connect(function() UI.Destroy() end)
bind(UserInputService.InputBegan, function(input, gpe)
	if not gpe and input.KeyCode == toggleKey then UI.Toggle() end
end)

-- ==================== INIT ====================
setTab(1, true)
env.__ProductFaker = UI
open()
scanProducts()
loadSupported()
