repeat task.wait() until game:IsLoaded()
if shared["oofer-vape"] then shared["oofer-vape"]:Uninject() end

-- why do exploits fail to implement anything correctly? Is it really that hard?
if identifyexecutor then
	if table.find({'Argon', 'Wave'}, ({identifyexecutor()})[1]) then
		getgenv().setthreadidentity = nil
	end
end

local oofer
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and oofer then
		oofer:CreateNotification('oofer-vape', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end

local queue_on_teleport = queue_on_teleport or function() end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end

local cloneref = cloneref or function(obj)
	return obj
end

local playersService = cloneref(game:GetService('Players'))

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/ooferowner/oofer-vape/'..readfile('oofer-vape/profiles/commit.txt')..'/'..select(1, path:gsub('oofer%-vape/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after oofer-vape updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function finishLoading()
	oofer.Init = nil
	oofer:Load()
	task.spawn(function()
		repeat
			oofer:Save()
			task.wait(10)
		until not oofer.Loaded
	end)

	local teleportedServers
	oofer:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
		if (not teleportedServers) and (not shared.OoferIndependent) then
			teleportedServers = true
			local teleportScript = [[
				shared.ooferreload = true
				if shared.OoferDeveloper then
					loadstring(readfile('oofer-vape/loader.lua'), 'loader')()
				else
					loadstring(game:HttpGet('https://raw.githubusercontent.com/ooferowner/oofer-vape/'..readfile('oofer-vape/profiles/commit.txt')..'/loader.lua', true), 'loader')()
				end
			]]
			if shared.OoferDeveloper then
				teleportScript = 'shared.OoferDeveloper = true\n'..teleportScript
			end
			if shared.OoferCustomProfile then
				teleportScript = 'shared.OoferCustomProfile = "'..shared.OoferCustomProfile..'"\n'..teleportScript
			end
			oofer:Save()
			queue_on_teleport(teleportScript)
		end
	end))

	if not shared.ooferreload then
		if not oofer.Categories then return end
		if oofer.Categories.Main.Options['GUI bind indicator'].Enabled then
			oofer:CreateNotification('Finished Loading', oofer.OoferButton and 'Press the button in the top right to open GUI' or 'Press '..table.concat(oofer.Keybind, ' + '):upper()..' to open GUI', 5)
		end
	end
end

if not isfile('oofer-vape/profiles/gui.txt') then
	writefile('oofer-vape/profiles/gui.txt', 'new')
end

local gui = readfile('oofer-vape/profiles/gui.txt')

if not isfolder('oofer-vape/assets/'..gui) then
	makefolder('oofer-vape/assets/'..gui)
end

oofer = loadstring(downloadFile('oofer-vape/guis/'..gui..'.lua'), 'gui')()
shared["oofer-vape"] = oofer

if not shared.OoferIndependent then
	loadstring(downloadFile('oofer-vape/games/universal.lua'), 'universal')()
	if isfile('oofer-vape/games/'..game.PlaceId..'.lua') then
		loadstring(readfile('oofer-vape/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
	else
		if not shared.OoferDeveloper then
			local suc, res = pcall(function()
				return game:HttpGet('https://raw.githubusercontent.com/ooferowner/oofer-vape/'..readfile('oofer-vape/profiles/commit.txt')..'/games/'..game.PlaceId..'.lua', true)
			end)
			if suc and res ~= '404: Not Found' then
				loadstring(downloadFile('oofer-vape/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
			end
		end
	end
	finishLoading()
else
	oofer.Init = finishLoading
	return oofer
end
