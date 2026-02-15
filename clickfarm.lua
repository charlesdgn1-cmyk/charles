-- [[ AYARLAR ]] --
local teleportZoneName = "Rainbow" -- Işınlanılacak ada adı

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local lp = Players.LocalPlayer

-- [[ 1. DİNAMİK REMOTE BULUCU ]] --
local function getGameRemote(remoteName)
    for _, obj in ipairs(ReplicatedStorage:GetChildren()) do
        local functions = obj:FindFirstChild("Functions")
        if functions then
            local target = functions:FindFirstChild(remoteName)
            if target then
                return target
            end
        end
    end
    return nil
end

-- [[ 2. AGRESİF FPS BOOST (DÜNYAYI TEMİZLE) ]] --
local function nukeWorld()
    -- Işıklandırma ve Gölgeleri Kapat
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 1
    
    for _, obj in pairs(Workspace:GetChildren()) do
        -- Kendimizi, kamerayı ve temel sistemleri koru, gerisini sil
        if obj.Name ~= lp.Name and 
           obj.Name ~= "Camera" and 
           not obj:IsA("Terrain") then
            pcall(function() obj:Destroy() end)
        end
    end
    
    -- Efektleri (Blur, Bloom vb.) sil
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") or effect:IsA("Sky") then
            effect:Destroy()
        end
    end

    Workspace.Terrain:Clear()
end

-- [[ 3. GÜVENLİ ZEMİN OLUŞTUR ]] --
local function createSafetyFloor()
    local floor = Instance.new("Part")
    floor.Name = "SafetyFloor"
    floor.Size = Vector3.new(100, 2, 100)
    -- Karakterin olduğu yere veya merkeze zemin koy
    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        floor.CFrame = lp.Character.HumanoidRootPart.CFrame * CFrame.new(0, -5, 0)
    else
        floor.CFrame = CFrame.new(0, 100, 0)
    end
    floor.Anchored = true
    floor.Transparency = 0.5 
    floor.BrickColor = BrickColor.new("Bright blue")
    floor.Parent = Workspace
    return floor
end

-- [[ ANA ÇALIŞTIRICI ]] --

-- ADIM 1: Adaya Işınlan
local tpRemote = getGameRemote("TeleportZone")
if tpRemote then
    print("🌐 " .. teleportZoneName .. " adasına ışınlanılıyor...")
    tpRemote:InvokeServer(teleportZoneName)
    task.wait(1.5) -- Işınlanma ve adanın yüklenmesi için süre
end

-- ADIM 2: FPS Boost ve Temizlik
nukeWorld()
createSafetyFloor()

print("🚀 FPS Boost Aktif: Harita temizlendi ve Cyberpunk bölgesindesin.")
