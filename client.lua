local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local idVisable = true
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(10)
	end

	Citizen.Wait(2000)
	ESX.TriggerServerCallback('esx_scoreboard:getConnectedPlayers', function(connectedPlayers)
		UpdatePlayerTable(connectedPlayers)
	end)
end)

Citizen.CreateThread(function()
	Citizen.Wait(500)
	local ajdik = GetPlayerServerId(PlayerId())
	local nazwa = GetPlayerName(PlayerId())
	SendNUIMessage({
		action = 'updateServerInfo',

		maxPlayers = GetConvarInt('sv_maxclients', 128),
		uptime = '['..ajdik.. '] ' ..nazwa,
		playTime = '00h 00m'
	})
end)


--[[Citizen.CreateThread(function()
	Citizen.Wait(500)
	ajdik = GetPlayerServerId(PlayerId())
	nazwa = GetPlayerName(PlayerId())
	if ajdik == nil or ajdik == '' then
		ajdik = GetPlayerServerId(PlayerId())
	end
	SendNUIMessage({
		action = 'updateServerInfo',

		maxPlayers = GetConvarInt('sv_maxclients', 128),
		uptime = '['..ajdik.. '] ' ..nazwa,
	})
end)]]

RegisterNetEvent('esx_scoreboard:updateConnectedPlayers')
AddEventHandler('esx_scoreboard:updateConnectedPlayers', function(connectedPlayers)
	UpdatePlayerTable(connectedPlayers)
end)

RegisterNetEvent('esx_scoreboard:updatePing')
AddEventHandler('esx_scoreboard:updatePing', function(connectedPlayers)
	SendNUIMessage({
		action  = 'updatePing',
		players = connectedPlayers
	})
end)

RegisterNetEvent('esx_scoreboard:toggleID')
AddEventHandler('esx_scoreboard:toggleID', function(state)
	if state then
		idVisable = state
	else
		idVisable = not idVisable
	end

	SendNUIMessage({
		action = 'toggleID',
		state = idVisable
	})
end)

RegisterNetEvent('uptime:tick')
AddEventHandler('uptime:tick', function(uptime)
	SendNUIMessage({
		action = 'updateServerInfo',
		uptime = uptime
	})
end)

local ambulance, police, taxi, mecano, cardealer, players = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

function UpdatePlayerTable(connectedPlayers)
	local formattedPlayerList, num = {}, 1
	ambulance, police, taxi, mecano, cardealer, players= 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

	for k,v in pairs(connectedPlayers) do

		if num == 1 then
			table.insert(formattedPlayerList, ('<tr><td>%s</td><td>%s</td><td>%s</td>'):format(v.name, v.id, v.ping))
			num = 2
		elseif num == 2 then
			table.insert(formattedPlayerList, ('<td>%s</td><td>%s</td><td>%s</td></tr>'):format(v.name, v.id, v.ping))
			num = 1
		end

		players = players + 1

		if v.job == 'ambulance' then
			ambulance = ambulance + 1
		elseif v.job == 'police' then
			police = police + 1
		elseif v.job == 'taxi' then
			taxi = taxi + 1
		elseif v.job == 'mecano' then
			mecano = mecano + 1
		elseif v.job == 'cardealer' then
			cardealer = cardealer + 1
		end
	end

	if num == 1 then
		table.insert(formattedPlayerList, '</tr>')
	end

	SendNUIMessage({
		action  = 'updatePlayerList',
		players = table.concat(formattedPlayerList)
	})

	SendNUIMessage({
		action = 'updatePlayerJobs',
		jobs   = {ambulance = ambulance, police = police, taxi = taxi, mecano = mecano, cardealer= cardealer, player_count = players}
	})
end

local color = {r = 255, g = 162, b = 0}
local font = 1
timer = 0

--[[RegisterNetEvent('Z:chat')
AddEventHandler('Z:chat', function(id, color, message)
	local _source = PlayerId()
	local target = GetPlayerFromServerId(id)
	
	if target == _source then
		TriggerEvent('chat:addMessage', {
  template = '<div style="padding: 0.5vw;  margin: 0.5vw; background-color: rgba(255, 153, 0, 1); color: white; border-radius: 3px;"><i class="fas fa-user-edit "style="font-size:15px;color:rgb(255,255,255,0.8)"> <font color="#FFFFFF"></font>&ensp;<font color="white">{1}</font></div>',
        args = { "", message}
})
	elseif GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(_source)), GetEntityCoords(GetPlayerPed(target)), true) < 60 then
		TriggerEvent('chat:addMessage', {
  template = '<div style="padding: 0.5vw;  margin: 0.5vw; background-color: rgba(255, 153, 0, 1); color: white; border-radius: 3px;"><i class="fas fa-user-edit "style="font-size:15px;color:rgb(255,255,255,0.8)"> <font color="#FFFFFF"></font>&ensp;<font color="white">{1}</font></div>',
        args = { "", message}
})
	end
end)]]


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5)

		--[[if IsControlPressed(0, 20) and IsInputDisabled(0) then
			SendNUIMessage({
				action  = 'open'
			})
			Citizen.Wait(200)
		end]]
		if IsControlJustPressed(0, Keys['Z']) and IsInputDisabled(0) then
			SendNUIMessage({
				action  = 'open'
			})
		end
		if IsControlJustReleased(0, Keys['Z']) and IsInputDisabled(0) or IsControlJustPressed(0, Keys['X']) then
			SendNUIMessage({
				action  = 'close'
			})
		end
		if IsControlJustPressed(1, 20) and not IsPedSittingInAnyVehicle(GetPlayerPed(-1)) then
			--local essa = TaskStartScenarioInPlace(GetPlayerPed(-1), "WORLD_HUMAN_CLIPBOARD", 0, false)
			TaskStartScenarioInPlace(GetPlayerPed(-1), "WORLD_HUMAN_CLIPBOARD", 0, false)
			--essa
		end
		if IsControlJustReleased(1, 20) then 
			ClearPedTasks(GetPlayerPed(-1)) 
		end  
	end
end)


-- Close scoreboard when game is paused
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(300)

		if IsPauseMenuActive() and not IsPaused then
			IsPaused = true
			SendNUIMessage({
				action  = 'close'
			})
		elseif not IsPauseMenuActive() and IsPaused then
			IsPaused = false
		end
	end
end)

--[[Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if IsControlJustReleased(0,20) then
			SendNUIMessage({
				action  = 'close'
			})
		end
	end
end)]]

function ToggleScoreBoard()
	SendNUIMessage({
		action = 'toggle'
	})
end

Citizen.CreateThread(function()
	local playMinute, playHour = 0, 0

	while true do
		Citizen.Wait(1000 * 60) -- every minute
		playMinute = playMinute + 1
	
		if playMinute == 60 then
			playMinute = 0
			playHour = playHour + 1
		end

		SendNUIMessage({
			action = 'updateServerInfo',
			playTime = string.format("%02dh %02dm", playHour, playMinute)
		})
	end
end)

function BierFrakcje(what)
	if what == 'ambulance' then
		return ambulance
	elseif what == 'mecano' then
		return mecano
	elseif what == 'police' then
		return police
	elseif what == 'players' then
		return players
	end
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5)
			if IsControlJustPressed(1, 20) then
										TriggerServerEvent('esx_scoreboard:Show', "przeglada wykaz mieszkancow")
		end
	end
end)

local color = {r = 255, g = 162, b = 0}
local font = 1
timer = 0
local showPlayerBlips = false
local ignorePlayerNameDistance = false
local playerNamesDist = 0
local displayIDHeight = 0.0 --Height of ID above players head(starts at center body mass)
--Set Default Values for Colors
local red = 255
local green = 255
local blue = 255
function DrawText3D(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())

    SetTextScale(0.40, 0.40)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end
function DrawText3SD(x,y,z, text) 
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)

    local scale = (1/dist)*2
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
    
    if onScreen then
        SetTextScale(1.0*scale, 1.55*scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(red, green, blue, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        World3dToScreen2d(x,y,z, 0) --Added Here
        DrawText(_x,_y)
    end
end

Citizen.CreateThread(function()
    while true do
          if IsControlPressed(0, 48)--[[ INPUT_PHONE ]] then
        for i=0,99 do
            N_0x31698aa80e0223f8(i)
        end
        for id = 0, 256 do
            if  ((NetworkIsPlayerActive( id )) and GetPlayerPed( id ) ~= GetPlayerPed( -1 )) then
                ped = GetPlayerPed( id )
                blip = GetBlipFromEntity( ped ) 
 
                x1, y1, z1 = table.unpack( GetEntityCoords( GetPlayerPed( -1 ), true ) )
                x2, y2, z2 = table.unpack( GetEntityCoords( GetPlayerPed( id ), true ) )
                distance = math.floor(GetDistanceBetweenCoords(x1,  y1,  z1,  x2,  y2,  z2,  true))

                if(ignorePlayerNameDistance) then
                    if NetworkIsPlayerTalking(id) then
                        red = 0
                        green = 0
                        blue = 255
                        DrawText3D(x2, y2, z2 + displayIDHeight, GetPlayerServerId(id))
                    else
                        red = 255
                        green = 255
                        blue = 255
                        DrawText3D(x2, y2, z2 + displayIDHeight, GetPlayerServerId(id))
                    end
                end

                if ((distance < playerNamesDist)) then
                    if not (ignorePlayerNameDistance) then
                        if NetworkIsPlayerTalking(id) then
                            red = 0
                            green = 0
                            blue = 255
                            DrawText3D(x2, y2, z2 + displayIDHeight, GetPlayerServerId(id))
                        else
                            red = 255
                            green = 255
                            blue = 255
                            DrawText3D(x2, y2, z2 + displayIDHeight, GetPlayerServerId(id))
                        end
                    end
                end  
            end
        end
    end
        Citizen.Wait(15)
    end
end)
