local AUTO_FISH_LABEL = "auto_fish_main"
local AUTO_REEL_LABEL = "auto_fish_reel"

local enabled = false
local lock = true
local reelDelayMs = 300
local recastDelayMs = 800

local function toScreenCenterOfLocal()
	local me = getLocal()
	if not me then return nil end
	local px = ((me.pos.x // 32) + 1) * 32 + 16
	local py = ((me.pos.y // 32) + 1) * 32 + 16
	return worldToScreen(px, py)
end

local function tap()
	local vec = toScreenCenterOfLocal()
	if not vec then return end
	local cmd = string.format("input tap %f %f", vec.x, vec.y)
	os.execute(string.format("su --mount-master -c \"%s\"", cmd))
	sleep(80)
	os.execute(cmd)
end

local function castOnce()
	tap()
end

local function reelOnce()
	sleep(reelDelayMs)
	tap()
end

local function startLoop()
	if enabled then return end
	enabled = true
	lock = true
	runThread(function()
		while enabled do
			if lock then
				castOnce()
				sleep(1200)
			else
				sleep(50)
			end
		end
	end, AUTO_FISH_LABEL)
	callToast("Auto Fish ON", 0)
end

local function stopLoop()
	enabled = false
	killThread(AUTO_FISH_LABEL)
	killThread(AUTO_REEL_LABEL)
	callToast("Auto Fish OFF", 0)
end

-- Commands: /fish on, /fish off, /fish delay 250
AddHook("OnTextPacket", "auto_fish_cmd", function(flag, pkt)
	if flag ~= 0 then return end
	if not pkt then return end
	if string.sub(pkt, 1, 6) ~= "action" then return end
	local msg = pkt:match("text\124(.-)\124") or ""
	if msg == "" then return end
	if msg:sub(1, 5) == "/fish" then
		local args = {}
		for w in msg:gmatch("%S+") do table.insert(args, w) end
		local sub = args[2] or ""
		if sub == "on" then
			startLoop()
			return true
		elseif sub == "off" then
			stopLoop()
			return true
		elseif sub == "delay" and args[3] then
			reelDelayMs = tonumber(args[3]) or reelDelayMs
			callToast("Reel delay set to "..tostring(reelDelayMs).." ms", 0)
			return true
		end
	end
end)

-- Heuristic unlock: waiting state
AddHook("OnGameUpdatePacket", "auto_fish_state", function(raw)
	local me = getLocal()
	if not me then return end
	if raw.type == 17 and raw.netid == me.netId and raw.speedx == 0 and raw.speedy == 0 then
		lock = false
	end
end)

-- Splash detection: audio/splash.wav
AddHook("OnVarlist", "auto_fish_splash", function(v, _)
	if not enabled then return end
	if v[0] == "OnPlayPositioned" and v[1] == "audio/splash.wav" and not lock then
		lock = true
		runThread(function()
			reelOnce()
			sleep(recastDelayMs)
			lock = true
		end, AUTO_REEL_LABEL)
	end
end)

-- Safety: stop on disconnect
AddHook("OnGameUpdatePacket", "auto_fish_disconnect", function(raw)
	if raw.type == 26 then
		stopLoop()
	end
end)
