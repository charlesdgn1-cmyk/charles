--[[ 
    CHARLES PROTECTED SOURCE
    FPS BOOST + AUTO HATCH (FIXED)
]]--

local _S = {"\82\101\112\108\105\99\97\116\101\100\83\116\111\114\97\103\101", "\87\111\114\107\115\112\97\99\101", "\80\108\97\121\101\114\115", "\76\105\103\104\116\105\110\103", "\83\110\111\119\109\97\110", "\69\103\103\115"}
local RS = game:GetService(_S[1])
local WS = game:GetService(_S[2])
local PL = game:GetService(_S[3])
local LG = game:GetService(_S[4])
local LP = PL.LocalPlayer

local cfg = {egg = _S[5], amt = 8, spd = 0}

-- [[ FPS BOOST - AGRESİF MOD ]] --
local function _boost()
    -- Gökyüzü ve Işıklandırma Temizliği
    LG.GlobalShadows = false
    LG.FogEnd = 9e9
    for _, v in pairs(LG:GetChildren()) do
        if v:IsA("\80\111\115\116\69\102\102\101\99\116") or v:IsA("\83\107\121") or v:IsA("\67\108\111\117\100\115") then
            v:Destroy()
        end
    end
    
    -- Dünyayı Nuke'le (FPS için en kritik yer)
    for _, obj in pairs(WS:GetChildren()) do
        if obj.Name ~= LP.Name and obj.Name ~= "\67\97\109\101\114\97" and obj.Name ~= _S[6] and not obj:IsA("\84\101\114\114\97\105\110") then
            pcall(function() obj:Destroy() end)
        end
    end
    WS.Terrain:Clear()
end

local function _hide(m)
    if m then
        for _, v in pairs(m:GetDescendants()) do
            if v:IsA("\66\97\115\101\80\97\114\116") then
                v.Transparency = 1
                v.CastShadow = false
            elseif v:IsA("\68\101\99\97\108") or v:IsA("\84\101\120\116\117\114\101") or v:IsA("\80\97\114\116\105\99\108\101\69\109\105\116\116\101\114") then
                pcall(function() v:Destroy() end)
            end
        end
    end
end

local function _getRemote()
    for _, v in ipairs(RS:GetChildren()) do
        local f = v:FindFirstChild("\70\117\110\99\116\105\111\110\115")
        if f and f:FindFirstChild("\79\112\101\110\69\103\103") then
            return f.OpenEgg
        end
    end
end

local eggDir = WS:FindFirstChild(_S[6])
local target = eggDir and (eggDir:FindFirstChild(cfg.egg) or eggDir:FindFirstChild(cfg.egg .. " \69\103\103"))

if target then
    _boost() -- FPS Boost önce çalışır
    _hide(target)
    
    if LP.Character then
        LP.Character:PivotTo(target:GetPivot() * CFrame.new(0, 0, 2))
    end
    
    _G.AutoHatch = true
    task.spawn(function()
        while _G.AutoHatch do
            local rem = _getRemote()
            if rem then
                local s = rem:InvokeServer(cfg.egg, cfg.amt)
                if not s then rem:InvokeServer(cfg.egg .. " \69\103\103", cfg.amt) end
            end
            task.wait(cfg.spd)
        end
    end)
end
