-- [[ AYARLAR ]] --
local targetEggName = "Lucky Event"
local openAmount = 8 
local hatchSpeed = 0 

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local lp = Players.LocalPlayer

-- [[ 1. AGRESİF FPS BOOST (DÜNYAYI TEMİZLE) ]] --
local function nukeWorld()
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj.Name ~= lp.Name and 
           obj.Name ~= "Camera" and 
           obj.Name ~= "Eggs" and 
           obj.Name ~= "SafetyFloor" and -- Mavi zemini silmemesi için koruma
           not obj:IsA("Terrain") then
            pcall(function() obj:Destroy() end)
        end
    end

    local eggsFolder = Workspace:FindFirstChild("Eggs")
    if eggsFolder then
        for _, egg in pairs(eggsFolder:GetChildren()) do
            -- Sadece Lucky Event yumurtasını bırak, diğerlerini sil
            if not egg.Name:find(targetEggName) then
                pcall(function() egg:Destroy() end)
            end
        end
    end
    Workspace.Terrain:Clear()
end

-- [[ 5. HAVA DURUMUNU VE EFEKTLERİ SIFIRLA ]] --
local function cleanLighting()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 1
    Lighting.ClockTime = 12
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") or effect:IsA("Sky") or effect:IsA("Clouds") then
            effect:Destroy()
        end
    end
    
    local sky = Instance.new("Sky", Lighting)
    sky.SunTextureId = ""
    sky.MoonTextureId = ""
end

-- [[ 2. YUMURTAYI GİZLE ]] --
local function hideEgg(eggModel)
    if eggModel then
        for _, part in pairs(eggModel:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                part.Transparency = 1 
                part.CastShadow = false
            elseif part:IsA("Decal") or part:IsA("Texture") then
                part:Destroy()
            elseif part:IsA("ParticleEmitter") or part:IsA("Trail") then
                part.Enabled = false
            end
        end
    end
end

-- [[ 3. GÜVENLİ ZEMİN ]] --
local function createFloorAtEgg(target)
    local floor = Instance.new("Part")
    floor.Name = "SafetyFloor"
    floor.Size = Vector3.new(50, 2, 50)
    floor.CFrame = target:GetPivot() * CFrame.new(0, -5, 0)
    floor.Anchored = true
    floor.Transparency = 0.5 
    floor.BrickColor = BrickColor.new("Bright blue")
    floor.Parent = Workspace
    return floor
end

-- [[ 4. REMOTE BULUCU ]] --
local function getOpenEggRemote()
    for _, obj in ipairs(ReplicatedStorage:GetChildren()) do
        local functions = obj:FindFirstChild("Functions")
        if functions and functions:FindFirstChild("OpenEgg") then
            return functions.OpenEgg
        end
    end
    return nil
end

-- [[ ÇALIŞTIRMA ]] --
local eggsFolder = Workspace:FindFirstChild("Eggs")
local eggModel = eggsFolder and (eggsFolder:FindFirstChild(targetEggName) or eggsFolder:FindFirstChild(targetEggName .. " Egg"))

if eggModel then
    nukeWorld()
    cleanLighting()
    createFloorAtEgg(eggModel)
    hideEgg(eggModel)
    
    task.wait(0.2)
    if lp.Character then
        lp.Character:PivotTo(eggModel:GetPivot() * CFrame.new(0, 0, 2))
    end
    
    _G.AutoHatch = true
    print("🚀 Sistem Aktif: Lucky Event yumurtasi aciliyor!")

    task.spawn(function()
        while _G.AutoHatch do
            local remote = getOpenEggRemote()
            if remote then
                -- Önce Lucky Event, olmazsa Lucky Event Egg olarak dene
                local success = remote:InvokeServer(targetEggName, openAmount)
                if not success then
                    remote:InvokeServer(targetEggName .. " Egg", openAmount)
                end
            end
            task.wait(hatchSpeed)
        end
    end)
else
    warn("❌ Hedef yumurta (" .. targetEggName .. ") haritada bulunamadı!")
end
