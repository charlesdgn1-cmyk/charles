-- [[ CHARLES PROTECTED SOURCE ]] --
-- [[ TARGET: CYBERPUNK - BASE FIXED ]] --

local _0x82 = {"\82\101\112\108\105\99\97\116\101\100\83\116\111\114\97\103\101", "\87\111\114\107\115\112\97\99\101", "\80\108\97\121\101\114\115", "\76\105\103\104\116\105\110\103", "\67\121\98\101\114\112\117\110\107", "\69\103\103\115", "\67\97\109\101\114\97", "\84\101\114\114\97\105\110", "\83\97\102\101\116\121\70\108\111\111\114"}
local _v1 = game:GetService(_0x82[1])
local _v2 = game:GetService(_0x82[2])
local _v3 = game:GetService(_0x82[3])
local _v4 = game:GetService(_0x82[4])
local _v5 = _v3.LocalPlayer

local _0xCFG = {
    egg = _0x82[5], -- Artık "Cyberpunk" byte kodunu temsil ediyor
    amt = 8,
    spd = 0
}

local function _0xNK()
    for _, v in pairs(_v2:GetChildren()) do
        if v.Name ~= _v5.Name and v.Name ~= _0x82[7] and v.Name ~= _0x82[6] and v.Name ~= _0x82[9] and not v:IsA(_0x82[8]) then
            pcall(function() v:Destroy() end)
        end
    end
    local _ef = _v2:FindFirstChild(_0x82[6])
    if _ef then
        for _, e in pairs(_ef:GetChildren()) do
            if not e.Name:find(_0xCFG.egg) then
                pcall(function() e:Destroy() end)
            end
        end
    end
    _v2.Terrain:Clear()
end

local function _0xCL()
    _v4.GlobalShadows = false
    _v4.FogEnd = 9e9
    _v4.Brightness = 1
    _v4.ClockTime = 12
    for _, v in pairs(_v4:GetChildren()) do
        if v:IsA("\80\111\115\116\69\102\102\101\99\116") or v:IsA("\83\107\121") or v:IsA("\67\108\111\117\100\115") then
            v:Destroy()
        end
    end
    local _s = Instance.new("\83\107\121", _v4)
    _s.SunTextureId = ""
    _s.MoonTextureId = ""
end

local function _0xBF(_t)
    local _f = Instance.new("\80\97\114\116")
    _f.Name = _0x82[9]
    _f.Size = Vector3.new(50, 2, 50)
    _f.CFrame = _t:GetPivot() * CFrame.new(0, -5, 0)
    _f.Anchored = true
    _f.Transparency = 0.5 
    _f.BrickColor = BrickColor.new("\66\114\105\103\104\116\32\98\108\117\101")
    _f.Parent = _v2
    return _f
end

local function _0xHG(_m)
    if _m then
        for _, v in pairs(_m:GetDescendants()) do
            if v:IsA("\66\97\115\101\80\97\114\116") or v:IsA("\77\101\115\104\80\97\114\116") then
                v.Transparency = 1
                v.CastShadow = false
            elseif v:IsA("\68\101\99\97\108") or v:IsA("\84\101\120\116\117\114\101") then
                pcall(function() v:Destroy() end)
            elseif v:IsA("\80\97\114\116\105\99\108\101\69\109\105\116\116\101\114") or v:IsA("\84\114\97\105\108") then
                v.Enabled = false
            end
        end
    end
end

local function _0xOR()
    for _, v in ipairs(_v1:GetChildren()) do
        local f = v:FindFirstChild("\70\117\110\99\116\105\111\110\115")
        if f and f:FindFirstChild("\79\112\101\110\69\103\103") then
            return f.OpenEgg
        end
    end
end

local _0xEG = _v2:FindFirstChild(_0x82[6])
local _0xMDL = _0xEG and (_0xEG:FindFirstChild(_0xCFG.egg) or _0xEG:FindFirstChild(_0xCFG.egg .. " \69\103\103"))

if _0xMDL then
    _0xNK()
    _0xCL()
    _0xBF(_0xMDL)
    _0xHG(_0xMDL)
    
    task.wait(0.2)
    if _v5.Character then
        _v5.Character:PivotTo(_0xMDL:GetPivot() * CFrame.new(0, 0, 2))
    end
    
    _G.AutoHatch = true
    task.spawn(function()
        while _G.AutoHatch do
            local rem = _0xOR()
            if rem then
                local s = rem:InvokeServer(_0xCFG.egg, _0xCFG.amt)
                if not s then rem:InvokeServer(_0xCFG.egg .. " \69\103\103", _0xCFG.amt) end
            end
            task.wait(_0xCFG.spd)
        end
    end)
end
