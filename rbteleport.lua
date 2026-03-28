-- [[ KORDİNAT IŞINLANMA SCRİPTİ ]] --

-- Buraya gitmek istediğin kordinatları yaz
local hedefX = 1226
local hedefY = 662
local hedefZ = -13369

-- [[ KOD BAŞLANGICI ]] --
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local lp = Players.LocalPlayer

local function createFloorAt(position)
    local floor = Instance.new("Part")
    floor.Name = "SafetyFloor"
    floor.Size = Vector3.new(100, 2, 100)
    floor.CFrame = CFrame.new(position)
    floor.Anchored = true
    floor.Transparency = 0.5 
    floor.BrickColor = BrickColor.new("Bright blue")
    floor.Parent = Workspace
    return floor
end

local function isinlanVePlatformYap()
    -- 1. Zemin Oluştur
    local targetPos = Vector3.new(hedefX, hedefY - 5, hedefZ)
    local floor = createFloorAt(targetPos)
    
    print("✅ 100x100 Zemin oluşturuldu: " .. tostring(floor.Position))

    -- 2. Oyuncuyu Işınla
    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        -- CFrame kullanarak ışınla
        lp.Character.HumanoidRootPart.CFrame = CFrame.new(hedefX, hedefY + 3, hedefZ)
        print("🚀 Oyuncu kordinata ışınlandı!")
    else
        warn("❌ Karakter veya HumanoidRootPart bulunamadı!")
    end
end

isinlanVePlatformYap()
