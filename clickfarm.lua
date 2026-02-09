-- [[ CHARLES CLICKS MODE: CYBERPUNK ]] --
-- [[ ONLY TELEPORT & ULTRA FPS BOOST ]] --

local teleportZoneName = "Cyberpunk" 

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local lp = Players.LocalPlayer

-- [[ 1. DİNAMİK REMOTE BULUCU ]] --
local function getTeleportRemote()
    for _, obj in ipairs(ReplicatedStorage:GetChildren()) do
        local functions = obj:FindFirstChild("Functions")
        if functions then
            local target = functions:FindFirstChild("TeleportZone")
            if target then return target end
        end
    end
    return nil
end

-- [[ 2. ULTRA AGRESİF FPS BOOST ]] --
-- Tıklama kasmak için sadece karakterin ve zeminin kalması yeterlidir.
local function ultraNuke()
    -- Işıklandırma ve Efektleri Kökten Sil
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 0 -- Göz yormaz
    for _, v in pairs(Lighting:GetChildren()) do
        pcall(function() v:Destroy() end)
    end

    -- Dünyadaki HER ŞEYİ Sil (Karakter ve Temel Gereksinimler Hariç)
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj.Name ~= lp.Name and 
           obj.Name ~= "Camera" and 
           obj.Name ~= "SafetyFloor" and 
           not obj:IsA("Terrain") then
            pcall(function() obj:Destroy() end)
        end
    end
    
    -- Dokuları ve Efektleri Sil (CPU/GPU Tasarrufu)
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("Decal") or v:IsA("Texture") or v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
            pcall(function() v:Destroy() end)
        end
    end

    Workspace.Terrain:Clear()
end

-- [[ 3. GÜVENLİ ZEMİN OLUŞTUR ]] --
local function createFarmPlatform()
    if not Workspace:FindFirstChild("SafetyFloor") then
        local floor = Instance.new("Part")
        floor.Name = "SafetyFloor"
        floor.Size = Vector3.new(100, 1, 100)
        floor.CFrame = CFrame.new(0, 1000, 0) -- Çok yükseğe veya merkeze alalım
        floor.Anchored = true
        floor.Transparency = 0.5
        floor.BrickColor = BrickColor.new("Really black")
        floor.Parent = Workspace
        return floor
    end
end

-- [[ ÇALIŞTIRICI ]] --

-- ADIM 1: Işınlanma
local tpRemote = getTeleportRemote()
if tpRemote then
    print("🌐 Cyberpunk bölgesine geçiliyor...")
    tpRemote:InvokeServer(teleportZoneName)
    task.wait(1.5) -- Yüklenmesi için kısa süre bekle
end

-- ADIM 2: Temizlik ve Platform
local platform = createFarmPlatform()
ultraNuke()

-- ADIM 3: Karakteri Güvenli Platforma Al
if lp.Character and platform then
    lp.Character:PivotTo(platform.CFrame * CFrame.new(0, 5, 0))
end

print("🚀 Clicks Modu Aktif! Dunya temizlendi, sadece tiklamaya odaklanabilirsin.")
