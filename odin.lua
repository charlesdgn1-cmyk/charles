-- =============================================
-- AUTO RAINBOW + AUTO CLAIM (Döngülü v4)
-- =============================================
-- DURDURMAK ICIN baska sekmede su kodu calistir:
--   _G.AutoRainbow = false
-- =============================================

_G.AutoRainbow = true
print("[AutoRainbow] Baslatildi. Durdurmak icin: _G.AutoRainbow = false")

local RS = game:GetService("ReplicatedStorage")

-- -----------------------------------------------
-- DOGRU ROOT TESPITI: StartRainbow'u iceren UUID'yi bul
-- -----------------------------------------------
local UUID_PATTERN = "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$"

local function findRoot()
	for _, child in ipairs(RS:GetChildren()) do
		if child.Name:match(UUID_PATTERN) then
			local funcs = child:FindFirstChild("Functions")
			if funcs and funcs:FindFirstChild("StartRainbow") then
				print("[AutoRainbow] Root bulundu:", child.Name)
				return child, funcs
			end
		end
	end
	warn("[AutoRainbow] StartRainbow bulunamadi, 2sn bekleniyor...")
	task.wait(2)
	for _, child in ipairs(RS:GetChildren()) do
		if child.Name:match(UUID_PATTERN) then
			local funcs = child:FindFirstChild("Functions")
			if funcs and funcs:FindFirstChild("StartRainbow") then
				print("[AutoRainbow] Root bulundu (2. deneme):", child.Name)
				return child, funcs
			end
		end
	end
	return nil, nil
end

local root, Functions = findRoot()
if not root then
	warn("[AutoRainbow] HATA: StartRainbow hicbir UUID klasorunde bulunamadi!")
	for _, child in ipairs(RS:GetChildren()) do
		if child.Name:match(UUID_PATTERN) then
			local funcs = child:FindFirstChild("Functions")
			if funcs then
				print("--- UUID:", child.Name, "---")
				for _, v in ipairs(funcs:GetChildren()) do
					print("  -", v.Name, "|", v.ClassName)
				end
			end
		end
	end
	error("Script durduruldu.")
end

-- -----------------------------------------------
-- Rainbow'a atilacak pet ID'leri
-- -----------------------------------------------
local petIDs = {
		"12491dc4-68b8-4470-8ff3-7b2b65ec1527",
		"36b72630-87b5-412e-a483-f2d3d06506c0",
		"f0e3c47d-feee-444c-bdf5-74c345d2befa",
		"6fdd9aea-ab45-45e5-815e-c150b26b3623",
		"35bf8d03-bdda-4b08-9e10-c090fe5aec2e"
}

local claimRemote = Functions:FindFirstChild("ClaimRainbow")
if not claimRemote then
	warn("[AutoRainbow] ClaimRainbow bulunamadi! Functions listesi:")
	for _, v in ipairs(Functions:GetChildren()) do
		print("  -", v.Name, "|", v.ClassName)
	end
	error("Script durduruldu.")
end

local turSayisi = 0

-- -----------------------------------------------
-- ANA DÖNGÜ
-- -----------------------------------------------
while _G.AutoRainbow do
	turSayisi = turSayisi + 1
	print("\n[AutoRainbow] ===== TUR " .. turSayisi .. " BASLADI =====")

	-- 1) StartRainbow
	print("[AutoRainbow] StartRainbow baslatiliyor...")
	local ok, rainbowResult = pcall(function()
		return Functions:WaitForChild("StartRainbow"):InvokeServer(petIDs)
	end)

	if ok then
		print("[AutoRainbow] StartRainbow OK -> Tip:", type(rainbowResult), "| Deger:", tostring(rainbowResult))
		if type(rainbowResult) == "table" then
			for k, v in pairs(rainbowResult) do
				print("   ", tostring(k), "=", tostring(v))
			end
		end
	else
		warn("[AutoRainbow] StartRainbow HATA:", tostring(rainbowResult))
		rainbowResult = nil
	end

	-- 2) Bekle (her saniye stop kontrolu)
	print("[AutoRainbow] 30 saniye bekleniyor...")
	for i = 30, 1, -1 do
		if not _G.AutoRainbow then
			print("[AutoRainbow] DURDURULDU (bekleme sirasinda).")
			break
		end
		if i % 5 == 0 or i <= 5 then
			print("[AutoRainbow] Kalan sure: " .. i .. " saniye")
		end
		task.wait(1)
	end

	if not _G.AutoRainbow then break end

	-- 3) ClaimRainbow - 4 kombinasyon dene
	print("[AutoRainbow] ClaimRainbow deneniyor...")

	-- Deneme 1: StartRainbow sonucuyla
	if rainbowResult ~= nil then
		local s, r = pcall(function()
			if type(rainbowResult) == "table" then
				return claimRemote:InvokeServer(unpack(rainbowResult))
			else
				return claimRemote:InvokeServer(rainbowResult)
			end
		end)
		print("[AutoRainbow] Deneme 1 (result):", s, tostring(r))
	end

	-- Deneme 2: petIDs tablo olarak
	local s2, r2 = pcall(function()
		return claimRemote:InvokeServer(petIDs)
	end)
	print("[AutoRainbow] Deneme 2 (petIDs tablo):", s2, tostring(r2))

	-- Deneme 3: Parametresiz
	local s3, r3 = pcall(function()
		return claimRemote:InvokeServer()
	end)
	print("[AutoRainbow] Deneme 3 (parametresiz):", s3, tostring(r3))

	-- Deneme 4: unpack ile
	local s4, r4 = pcall(function()
		return claimRemote:InvokeServer(unpack(petIDs))
	end)
	print("[AutoRainbow] Deneme 4 (unpack):", s4, tostring(r4))

	print("[AutoRainbow] ===== TUR " .. turSayisi .. " BITTI =====")

	-- Sonraki tura gecmeden once kisa bekleme
	if _G.AutoRainbow then
		print("[AutoRainbow] 3 saniye sonra yeni tur basliyor...")
		task.wait(1)
	end
end

print("[AutoRainbow] Script durduruldu. Toplam tur:", turSayisi)
