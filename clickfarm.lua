-- [[ CHARLES CLICKS MODE - FIXED VERSION ]] --

local teleportZoneName = "Cyberpunk" 

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local lp = Players.LocalPlayer

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

local function safeNuke()
    -- Işıklandırma temizliği
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 0
    for _, v in pairs(Lighting:GetChildren()) do
        pcall(function() v:Destroy() end)
    end

    -- Dünyayı temizle ama Karakterin İÇİNE dokunma (Hata veren kısım burasıydı)
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj.Name ~= lp.Name and 
           obj.Name ~= "Camera" and 
           obj.Name ~= "SafetyFloor" and 
           not obj:IsA("Terrain") then
            pcall(function() obj:Destroy() end)
        end
    end
    
    -- Sadece karakterin dışındaki dokuları sil
    for _, v in pairs(Workspace:GetDescendants()) do
        if not v:IsDescendantOf(lp.Character) then -- Karakterin parçalarını koru
            if v:IsA("Decal") or v:IsA("Texture") or v:IsA("ParticleEmitter") or v:IsA("Trail") then
                pcall(function() v:Destroy() end)
            end
        end
    end

    Workspace.Terrain:Clear()
end

local function createFarmPlatform()
    if not Workspace:FindFirstChild("SafetyFloor") then
        local floor = Instance.new("Part")
        floor.Name = "SafetyFloor"
        floor.Size = Vector3.new(100, 1, 100)
        floor.CFrame = CFrame.new(0, 1000, 0)
        floor.Anchored = true
        floor.Transparency = 0.5
        floor.BrickColor = BrickColor.new("Really black")
        floor.Parent = Workspace
        return floor
    end
    return Workspace:FindFirstChild("SafetyFloor")
end

-- ÇALIŞTIRICI
local tpRemote = getTeleportRemote()
if tpRemote then
    tpRemote:InvokeServer(teleportZoneName)
    task.wait(1.5)
end

local platform = createFarmPlatform()
safeNuke()

if lp.Character and platform then
    lp.Character:PivotTo(platform.CFrame * CFrame.new(0, 5, 0))
end

print("🚀 Hata Düzeltildi & Clicks Modu Aktif!")
