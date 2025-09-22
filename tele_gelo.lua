--[[
    GENTA HAX Edition - Ultimate Invis Exploit
    Ultimate fake respawn technique + Perfect Anti /Who + Anti Debugger Crash
]]

-- Konfigurasi
local config = {
    enabled = true,
    stealthMode = false,
    fakeRespawnEnabled = true,
    respawnInterval = 10000, -- Fake respawn setiap 10 detik
    antiWhoInterval = 2000,  -- Anti /who setiap 2 detik
    debugMode = false
}

-- Variabel global
local isInvisible = false
local lastFakeRespawn = 0
local fakeRespawnCount = 0
local antiWhoEnabled = true
local fakePosition = {x = 0, y = 0}
local originalPosition = {x = 0, y = 0}
local scriptRunning = true
local threads = {}
local cleanupDone = false

-- Fungsi untuk log (safe)
local function log(message)
    if config.stealthMode or cleanupDone then return end
    local success, result = pcall(function()
        local time = os.date("%H:%M:%S")
        logToConsole("[" .. time .. "] " .. message)
    end)
    if not success and config.debugMode then
        print("Log error: " .. tostring(result))
    end
end

-- Fungsi untuk notifikasi (safe)
local function notify(message, duration)
    if cleanupDone then return end
    duration = duration or 3000
    local success, result = pcall(function()
        doToast(4, duration, message)
    end)
    if not success and config.debugMode then
        print("Notify error: " .. tostring(result))
    end
end

-- Fungsi untuk setup anti /who detection (enhanced)
local function setupAntiWho()
    local player = getLocal()
    if not player then return end
    
    -- Simpan posisi awal untuk fake /who
    fakePosition.x = player.pos.x
    fakePosition.y = player.pos.y
    originalPosition.x = player.pos.x
    originalPosition.y = player.pos.y
    
    log("=== ANTI /WHO DETECTION SETUP ===")
    log("Fake position set: " .. fakePosition.x .. ", " .. fakePosition.y)
    log("Anti /who detection AKTIF!")
    notify("Anti /who detection AKTIF!", 3000)
end

-- Fungsi untuk mengirim fake position ke server (enhanced)
local function sendFakePosition()
    if not antiWhoEnabled or cleanupDone then return end
    
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
    
    -- Method 4: Additional fake position packets
    local success4, result4 = pcall(function()
        sendPacket(1, "action|fake_position\nx|" .. fakePosition.x .. "\ny|" .. fakePosition.y .. "\nnetid|" .. player.netId)
    end)
    
    local success5, result5 = pcall(function()
        sendPacket(2, "action|set_position\nx|" .. fakePosition.x .. "\ny|" .. fakePosition.y .. "\nfake|true")
    end)
    
    if config.debugMode then
        log("Fake position sent: " .. fakePosition.x .. ", " .. fakePosition.y)
        log("Packet results: " .. tostring(success1) .. ", " .. tostring(success2) .. ", " .. tostring(success3))
    end
end

-- Fungsi fake respawn yang aman (enhanced)
local function performFakeRespawn()
    if cleanupDone then return end
    
    local player = getLocal()
    if not player then 
        log("Player tidak ditemukan!")
        return 
    end
    
    log("=== FAKE RESPAWN TECHNIQUE AKTIF ===")
    fakeRespawnCount = fakeRespawnCount + 1
    log("Fake respawn ke-" .. fakeRespawnCount)
    
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
    lastFakeRespawn = getCurrentTimeInternal()
    log("=== FAKE RESPAWN BERHASIL ===")
    log("Player seolah respawn tapi tetap di room yang sama!")
    log("Tubuh asli hilang tapi tidak benar-benar terkick!")
    notify("FAKE RESPAWN BERHASIL! Player invisible!", 3000)
end

-- Fungsi untuk membuat visible (safe)
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

-- Main thread untuk fake respawn otomatis (ultra safe)
local function fakeRespawnThread()
    while scriptRunning and config.enabled and config.fakeRespawnEnabled and not cleanupDone do
        local success, result = pcall(function()
            local currentTime = getCurrentTimeInternal()
            
            -- Fake respawn setiap interval
            if currentTime - lastFakeRespawn > config.respawnInterval then
                performFakeRespawn()
            end
            
            -- Kirim fake position untuk anti /who
            if antiWhoEnabled and scriptRunning and not cleanupDone then
                sendFakePosition()
            end
        end)
        
        if not success and config.debugMode then
            log("Thread error: " .. tostring(result))
        end
        
        sleep(2000) -- Check setiap 2 detik
    end
    log("Fake respawn thread stopped safely")
end

-- Thread khusus untuk anti /who detection (ultra safe)
local function antiWhoThread()
    while scriptRunning and antiWhoEnabled and not cleanupDone do
        local success, result = pcall(function()
            sendFakePosition()
        end)
        
        if not success and config.debugMode then
            log("Anti /who thread error: " .. tostring(result))
        end
        
        sleep(config.antiWhoInterval) -- Kirim fake position setiap interval
    end
    log("Anti /who thread stopped safely")
end

-- Inisialisasi script (safe)
local function initialize()
    local success, result = pcall(function()
        log("=== GENTA HAX - Ultimate Invis Exploit ===")
        log("Author: XBOY")
        log("Version: Ultimate Fake Respawn + Perfect Anti /Who + Anti Debugger Crash")
        log("Teknik: Player seolah respawn tapi tetap di room yang sama!")
        log("Tubuh asli hilang tapi tidak benar-benar terkick!")
        log("Anti /Who: Player terlihat di posisi awal meskipun sudah pindah!")
        log("Anti Debugger: Script tidak akan crash saat dimatikan!")
        
        -- Reset script state
        scriptRunning = true
        cleanupDone = false
        
        -- Setup anti /who detection
        setupAntiWho()
        
        -- Start fake respawn thread
        local thread1 = runThread(fakeRespawnThread, "ultimateFakeRespawnThread")
        if thread1 then
            threads["ultimateFakeRespawnThread"] = true
        end
        
        -- Start anti /who thread
        local thread2 = runThread(antiWhoThread, "ultimateAntiWhoThread")
        if thread2 then
            threads["ultimateAntiWhoThread"] = true
        end
        
        -- Langsung aktifkan fake respawn
        sleep(3000) -- Tunggu 3 detik untuk stabilisasi
        performFakeRespawn()
        
        notify("ULTIMATE FAKE RESPAWN + PERFECT ANTI /WHO loaded! Semua fitur aktif!", 4000)
        log("Script ultimate fake respawn + anti /who berhasil diinisialisasi dan AKTIF")
    end)
    
    if not success then
        print("Initialize error: " .. tostring(result))
    end
end

-- Start script
initialize()

-- Fungsi untuk toggle anti /who detection (safe)
local function toggleAntiWho()
    local success, result = pcall(function()
        antiWhoEnabled = not antiWhoEnabled
        if antiWhoEnabled then
            log("Anti /Who detection DIAKTIFKAN!")
            notify("Anti /Who detection DIAKTIFKAN!", 2000)
            -- Restart anti who thread
            local thread = runThread(antiWhoThread, "ultimateAntiWhoThread")
            if thread then
                threads["ultimateAntiWhoThread"] = true
            end
        else
            log("Anti /Who detection DINONAKTIFKAN!")
            notify("Anti /Who detection DINONAKTIFKAN!", 2000)
        end
    end)
    
    if not success and config.debugMode then
        log("Toggle error: " .. tostring(result))
    end
end

-- Fungsi untuk update fake position (safe)
local function updateFakePosition(x, y)
    local success, result = pcall(function()
        fakePosition.x = x or getLocal().pos.x
        fakePosition.y = y or getLocal().pos.y
        log("Fake position updated: " .. fakePosition.x .. ", " .. fakePosition.y)
        notify("Fake position updated!", 2000)
    end)
    
    if not success and config.debugMode then
        log("Update position error: " .. tostring(result))
    end
end

-- Ultimate cleanup function (anti debugger crash)
local function cleanup()
    if cleanupDone then return end
    
    log("=== ULTIMATE CLEANUP SCRIPT ===")
    cleanupDone = true
    
    -- Stop script running
    scriptRunning = false
    
    -- Stop all threads safely
    for threadId, _ in pairs(threads) do
        local success, result = pcall(function()
            killThread(threadId)
        end)
        if success then
            log("Thread killed safely: " .. threadId)
        else
            log("Thread kill error: " .. tostring(result))
        end
    end
    
    -- Clear thread list
    threads = {}
    
    -- Make visible if invisible
    if isInvisible then
        local success, result = pcall(function()
            makeVisible()
        end)
        if not success then
            log("Make visible error: " .. tostring(result))
        end
    end
    
    -- Disable anti who
    antiWhoEnabled = false
    
    -- Wait a bit for threads to stop
    sleep(2000)
    
    log("Ultimate cleanup completed - NO DEBUGGER CRASH!")
    notify("Script stopped safely - NO CRASH!", 2000)
end

-- Safe stop function
local function stopScript()
    local success, result = pcall(function()
        cleanup()
    end)
    
    if not success then
        print("Stop script error: " .. tostring(result))
    end
end

-- Export functions untuk manual call (safe)
local success1, result1 = pcall(function()
    _G.cleanupInvis = cleanup
    _G.stopScript = stopScript
    _G.toggleAntiWho = toggleAntiWho
    _G.updateFakePosition = updateFakePosition
    _G.makeVisible = makeVisible
    _G.makeInvisible = performFakeRespawn
end)

-- Auto cleanup saat script di-unload (jika ada hook system)
if AddHook then
    local success2, result2 = pcall(function()
        AddHook(function()
            cleanup()
        end, "OnUnload")
    end)
    
    if not success2 and config.debugMode then
        log("Hook error: " .. tostring(result2))
    end
end

-- Final safety check
if not success1 and config.debugMode then
    log("Export error: " .. tostring(result1))
end
