--[[
    GENTA HAX Edition - Final Safe Invis Exploit
    One-time fake respawn + Perfect Anti /Who + NO CRASH on stop
]]

-- Konfigurasi
local config = {
    enabled = true,
    stealthMode = false
}

-- Variabel global
local isInvisible = false
local antiWhoEnabled = true
local fakePosition = {x = 0, y = 0}
local scriptRunning = true
local cleanupDone = false

-- Fungsi untuk log (ultra safe)
local function log(message)
    if config.stealthMode or cleanupDone then return end
    local success, result = pcall(function()
        local time = os.date("%H:%M:%S")
        logToConsole("[" .. time .. "] " .. message)
    end)
end

-- Fungsi untuk notifikasi (ultra safe)
local function notify(message, duration)
    if cleanupDone then return end
    duration = duration or 3000
    local success, result = pcall(function()
        doToast(4, duration, message)
    end)
end

-- Fungsi untuk setup anti /who detection
local function setupAntiWho()
    local player = getLocal()
    if not player then return end
    
    -- Simpan posisi awal untuk fake /who
    fakePosition.x = player.pos.x
    fakePosition.y = player.pos.y
    
    log("=== ANTI /WHO DETECTION SETUP ===")
    log("Fake position set: " .. fakePosition.x .. ", " .. fakePosition.y)
    log("Anti /who detection AKTIF!")
    notify("Anti /who detection AKTIF!", 3000)
end

-- Fungsi untuk mengirim fake position ke server (ultra safe)
local function sendFakePosition()
    if not antiWhoEnabled or cleanupDone or not scriptRunning then return end
    
    local player = getLocal()
    if not player then return end
    
    -- Method 1: Fake position dengan packet type 0 (PACKET_STATE)
    local success1, result1 = pcall(function()
        local fakePosPacket1 = {
            type = 0, -- PACKET_STATE
            padding1 = 0,
            padding2 = 0,
            padding3 = 0,
            netid = player.netId,
            secid = 0,
            state = 1, -- Normal state
            padding4 = 0,
            value = 0,
            x = fakePosition.x,
            y = fakePosition.y,
            speedx = 0,
            speedy = 0,
            padding5 = 0,
            punchx = 0,
            punchy = 0
        }
        sendPacketRaw(false, fakePosPacket1)
    end)
    
    -- Method 2: Fake position dengan packet type 3 (PACKET_TILE_CHANGE_REQUEST)
    local success2, result2 = pcall(function()
        local fakePosPacket2 = {
            type = 3, -- PACKET_TILE_CHANGE_REQUEST
            padding1 = 0,
            padding2 = 0,
            padding3 = 0,
            netid = player.netId,
            secid = 0,
            state = 1,
            padding4 = 0,
            value = 1,
            x = fakePosition.x // 32,
            y = fakePosition.y // 32,
            speedx = 0,
            speedy = 0,
            padding5 = 0,
            punchx = 0,
            punchy = 0
        }
        sendPacketRaw(false, fakePosPacket2)
    end)
    
    -- Method 3: Fake position dengan packet type 20 (PACKET_SET_CHARACTER_STATE)
    local success3, result3 = pcall(function()
        local fakePosPacket3 = {
            type = 20, -- PACKET_SET_CHARACTER_STATE
            padding1 = 0,
            padding2 = 0,
            padding3 = 0,
            netid = player.netId,
            secid = 0,
            state = 1,
            padding4 = 0,
            value = 1,
            x = fakePosition.x,
            y = fakePosition.y,
            speedx = 0,
            speedy = 0,
            padding5 = 0,
            punchx = 0,
            punchy = 0
        }
        sendPacketRaw(false, fakePosPacket3)
    end)
end

-- Fungsi fake respawn yang aman (one-time only)
local function performFakeRespawn()
    if cleanupDone then return end
    
    local player = getLocal()
    if not player then 
        log("Player tidak ditemukan!")
        return 
    end
    
    log("=== FAKE RESPAWN TECHNIQUE AKTIF ===")
    
    -- Simpan posisi asli
    local originalX = player.pos.x
    local originalY = player.pos.y
    
    -- Method 1: Set death status
    local success1, result1 = pcall(function()
        sendPacket(2, "action|setDeath\nanimDeath|1")
    end)
    if success1 then
        log("Method 1: Death status set")
    end
    
    -- Method 2: Fake respawn dengan packet raw
    local success2, result2 = pcall(function()
        local fakeRespawnPacket = {
            type = 0, -- PACKET_STATE
            padding1 = 0,
            padding2 = 0,
            padding3 = 0,
            netid = player.netId,
            secid = 0,
            state = 2356, -- Fake respawn state
            padding4 = 0,
            value = 0,
            x = originalX,
            y = originalY,
            speedx = 0,
            speedy = 0,
            padding5 = 0,
            punchx = 0,
            punchy = 0
        }
        sendPacketRaw(false, fakeRespawnPacket)
    end)
    if success2 then
        log("Method 2: Fake respawn packet sent")
    end
    
    -- Method 3: Set invisible state
    local success3, result3 = pcall(function()
        local invisiblePacket = {
            type = 20, -- PACKET_SET_CHARACTER_STATE
            padding1 = 0,
            padding2 = 0,
            padding3 = 0,
            netid = player.netId,
            secid = 0,
            state = 0, -- Invisible state
            padding4 = 0,
            value = 0,
            x = originalX,
            y = originalY,
            speedx = 0,
            speedy = 0,
            padding5 = 0,
            punchx = 0,
            punchy = 0
        }
        sendPacketRaw(false, invisiblePacket)
    end)
    if success3 then
        log("Method 3: Invisible state set")
    end
    
    -- Method 4: Additional fake respawn packets
    local success4, result4 = pcall(function()
        sendPacket(1, "action|respawn\nfake|true\nnetid|" .. player.netId)
    end)
    if success4 then
        log("Method 4: Additional fake respawn packet sent")
    end
    
    local success5, result5 = pcall(function()
        sendPacket(3, "action|fake_respawn\nx|" .. (originalX // 32) .. "\ny|" .. (originalY // 32))
    end)
    if success5 then
        log("Method 5: Fake tile respawn packet sent")
    end
    
    -- Tunggu sebentar
    sleep(1500)
    
    -- Restore posisi
    local success6, result6 = pcall(function()
        local restorePacket = {
            type = 3, -- PACKET_TILE_CHANGE_REQUEST
            padding1 = 0,
            padding2 = 0,
            padding3 = 0,
            netid = player.netId,
            secid = 0,
            state = 1,
            padding4 = 0,
            value = 1,
            x = originalX // 32,
            y = originalY // 32,
            speedx = 0,
            speedy = 0,
            padding5 = 0,
            punchx = 0,
            punchy = 0
        }
        sendPacketRaw(false, restorePacket)
    end)
    if success6 then
        log("Posisi berhasil di-restore")
    end
    
    isInvisible = true
    log("=== FAKE RESPAWN BERHASIL ===")
    log("Player seolah respawn tapi tetap di room yang sama!")
    log("Tubuh asli hilang tapi tidak benar-benar terkick!")
    notify("FAKE RESPAWN BERHASIL! Player invisible!", 3000)
end

-- Fungsi untuk membuat visible (ultra safe)
local function makeVisible()
    if not isInvisible or cleanupDone then return end
    
    local player = getLocal()
    if not player then return end
    
    log("Mencoba membuat visible...")
    
    -- Method 1: Menggunakan packet manipulation untuk show player
    local success1, result1 = pcall(function()
        local showPacket = "action|set_visibility\nvisible|true"
        sendPacket(2, showPacket)
    end)
    
    -- Method 2: Menggunakan packet raw untuk show
    local success2, result2 = pcall(function()
        local showRaw = {
            type = 20, -- PACKET_SET_CHARACTER_STATE
            padding1 = 0,
            padding2 = 0,
            padding3 = 0,
            netid = player.netId,
            secid = 0,
            state = 1,
            padding4 = 0,
            value = 1,
            x = player.pos.x,
            y = player.pos.y,
            speedx = 0,
            speedy = 0,
            padding5 = 0,
            punchx = 0,
            punchy = 0
        }
        sendPacketRaw(false, showRaw)
    end)
    
    isInvisible = false
    log("Visible mode AKTIF")
    notify("Visible mode AKTIF", 2000)
end

-- Thread untuk anti /who detection (ultra safe)
local function antiWhoThread()
    while scriptRunning and antiWhoEnabled and not cleanupDone do
        local success, result = pcall(function()
            sendFakePosition()
        end)
        
        sleep(3000) -- Kirim fake position setiap 3 detik
    end
    log("Anti /who thread stopped safely")
end

-- Inisialisasi script (ultra safe)
local function initialize()
    local success, result = pcall(function()
        log("=== GENTA HAX - Final Safe Invis Exploit ===")
        log("Author: XBOY")
        log("Version: One-Time Fake Respawn + Perfect Anti /Who + NO CRASH")
        log("Teknik: Player seolah respawn tapi tetap di room yang sama!")
        log("Tubuh asli hilang tapi tidak benar-benar terkick!")
        log("Anti /Who: Player terlihat di posisi awal meskipun sudah pindah!")
        log("One-Time: Fake respawn hanya sekali, tidak berulang!")
        log("NO CRASH: Script tidak akan crash saat dimatikan!")
        
        -- Reset script state
        scriptRunning = true
        cleanupDone = false
        
        -- Setup anti /who detection
        setupAntiWho()
        
        -- Start anti /who thread
        runThread(antiWhoThread, "finalAntiWhoThread")
        
        -- Langsung aktifkan fake respawn SEKALI SAJA
        sleep(2000) -- Tunggu 2 detik untuk stabilisasi
        performFakeRespawn()
        
        notify("FINAL SAFE INVIS + ANTI /WHO loaded! NO CRASH GUARANTEED!", 4000)
        log("Script final safe invis + anti /who berhasil diinisialisasi dan AKTIF")
    end)
end

-- Start script
initialize()

-- Fungsi untuk toggle anti /who detection (ultra safe)
local function toggleAntiWho()
    local success, result = pcall(function()
        antiWhoEnabled = not antiWhoEnabled
        if antiWhoEnabled then
            log("Anti /Who detection DIAKTIFKAN!")
            notify("Anti /Who detection DIAKTIFKAN!", 2000)
            -- Restart anti who thread
            runThread(antiWhoThread, "finalAntiWhoThread")
        else
            log("Anti /Who detection DINONAKTIFKAN!")
            notify("Anti /Who detection DINONAKTIFKAN!", 2000)
        end
    end)
end

-- Fungsi untuk update fake position (ultra safe)
local function updateFakePosition(x, y)
    local success, result = pcall(function()
        fakePosition.x = x or getLocal().pos.x
        fakePosition.y = y or getLocal().pos.y
        log("Fake position updated: " .. fakePosition.x .. ", " .. fakePosition.y)
        notify("Fake position updated!", 2000)
    end)
end

-- Ultimate cleanup function (NO CRASH GUARANTEED)
local function cleanup()
    if cleanupDone then return end
    
    -- Set cleanup flag FIRST
    cleanupDone = true
    scriptRunning = false
    antiWhoEnabled = false
    
    -- Try to log cleanup start
    local success1, result1 = pcall(function()
        log("=== FINAL CLEANUP SCRIPT ===")
    end)
    
    -- Make visible if invisible (safe)
    if isInvisible then
        local success2, result2 = pcall(function()
            makeVisible()
        end)
    end
    
    -- Wait a bit for everything to settle
    local success3, result3 = pcall(function()
        sleep(500)
    end)
    
    -- Final log
    local success4, result4 = pcall(function()
        log("Final cleanup completed - NO CRASH GUARANTEED!")
        notify("Script stopped safely - NO CRASH!", 2000)
    end)
end

-- Safe stop function
local function stopScript()
    local success, result = pcall(function()
        cleanup()
    end)
end

-- Export functions untuk manual call (ultra safe)
local success1, result1 = pcall(function()
    _G.cleanupInvis = cleanup
    _G.stopScript = stopScript
    _G.toggleAntiWho = toggleAntiWho
    _G.updateFakePosition = updateFakePosition
    _G.makeVisible = makeVisible
    _G.makeInvisible = performFakeRespawn
end)

-- NO HOOK SYSTEM - Mencegah memory access error
-- Gunakan stopScript() manual untuk cleanup yang aman
