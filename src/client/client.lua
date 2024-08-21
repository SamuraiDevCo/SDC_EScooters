local loadedClient = false
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if NetworkIsSessionStarted() then
			Citizen.Wait(200)
			loadedClient = true
            TriggerServerEvent("SDES:Server:LoadedIn")
			return -- break the loop
		end
	end
end)

local myIdent = nil
local allScoots = {}
local allScootTimes = {}
local spawnedScoots = {}
local highlighted = nil
local allScootBlips = {}

RegisterNetEvent("SDES:Client:UpdateScootTable")
AddEventHandler("SDES:Client:UpdateScootTable", function(tab, tab2)
	allScoots = tab
	allScootTimes = tab2
end)
RegisterNetEvent("SDES:Client:UpdateIdent")
AddEventHandler("SDES:Client:UpdateIdent", function(ident)
	myIdent = ident
end)

Citizen.CreateThread(function()
	while true do
		local ped = PlayerPedId()
		local pcoords = GetEntityCoords(ped)
		
		LoadPropDict(SDC.EScooterModel)
		for plate, sdata in pairs(allScoots) do
			if sdata.Localize then
				if not spawnedScoots[plate] and Vdist(pcoords.x, pcoords.y, pcoords.z, sdata.Coords) <= SDC.SpawnScooterDist then
					local veh = CreateVehicle(SDC.EScooterModel, sdata.Coords.x, sdata.Coords.y, sdata.Coords.z, sdata.Coords.w, false, false)
					SetVehicleNumberPlateText(veh, plate)
					PlaceObjectOnGroundProperly(veh)
					SetEntityHeading(veh, sdata.Coords.w)
					SetVehicleDoorsLocked(veh, 10)
					AddTargetToScooter(veh, "SDES:Client:ScooterMenu", plate)
					spawnedScoots[plate] = veh
				elseif spawnedScoots[plate] and Vdist(pcoords.x, pcoords.y, pcoords.z, sdata.Coords) > SDC.SpawnScooterDist then
					if DoesEntityExist(spawnedScoots[plate]) then
						DeleteEntity(spawnedScoots[plate])
					end
					spawnedScoots[plate] = nil
				elseif spawnedScoots[plate] and not DoesEntityExist(spawnedScoots[plate]) and Vdist(pcoords.x, pcoords.y, pcoords.z, sdata.Coords) <= SDC.SpawnScooterDist then
					local veh = CreateVehicle(SDC.EScooterModel, sdata.Coords.x, sdata.Coords.y, sdata.Coords.z, sdata.Coords.w, false, false)
					SetVehicleNumberPlateText(veh, plate)
					PlaceObjectOnGroundProperly(veh)
					SetEntityHeading(veh, sdata.Coords.w)
					SetVehicleDoorsLocked(veh, 10)
					AddTargetToScooter(veh, "SDES:Client:ScooterMenu", plate)
					spawnedScoots[plate] = veh
				end
			elseif not sdata.Localize and spawnedScoots[plate] then
				if DoesEntityExist(spawnedScoots[plate]) then
					DeleteEntity(spawnedScoots[plate])
				end
				spawnedScoots[plate] = nil
			end
		end
		SetModelAsNoLongerNeeded(SDC.EScooterModel)

		if SDC.DrawScooterBlips.Enabled then
			for k,v in pairs(allScoots) do
				if not allScootBlips[k] and v.Localize then
					local scootBlip = AddBlipForCoord(v.Coords.x, v.Coords.y, v.Coords.z)
					SetBlipSprite(scootBlip, SDC.DrawScooterBlips.Sprite)
					SetBlipScale(scootBlip, SDC.DrawScooterBlips.Size)
					SetBlipColour(scootBlip, SDC.DrawScooterBlips.Color)
					BeginTextCommandSetBlipName("STRING")
					AddTextComponentString(SDC.Lang.ScooterMain3)
					EndTextCommandSetBlipName(scootBlip)
					allScootBlips[k] = scootBlip
				elseif allScootBlips[k] and not v.Localize then
					RemoveBlip(allScootBlips[k])
					allScootBlips[k] = nil
				end
			end
		end

		local veh = GetVehiclePedIsIn(ped, false)
		if veh > 0 then
			local plate = GetVehicleNumberPlateText(veh)
			if string.match(plate, "LEMON") then
				if not allScootTimes[plate] or not allScootTimes[plate].Owner or allScootTimes[plate].Owner ~= myIdent then
					TaskLeaveVehicle(ped, veh, 256)
					TriggerEvent("SDES:Client:Notification", SDC.Lang.YouArntRentingThisScooter, "error")
					Citizen.Wait(1500)
				end
			end
		end
		Citizen.Wait(500)
	end
end)

RegisterNetEvent("SDES:Client:ScooterMenu")
AddEventHandler("SDES:Client:ScooterMenu", function(dat)
	if allScoots[dat.daplate] then
		local veh = spawnedScoots[dat.daplate]
		highlighted = veh
		SetEntityDrawOutline(veh, true)
		SetEntityDrawOutlineColor(SDC.HighlightedColor.r, SDC.HighlightedColor.g, SDC.HighlightedColor.b, SDC.HighlightedColor.a)
		lib.registerContext({
			id = 'scoot_main',
			title = SDC.Lang.ScooterMain1,
			onExit = function()
				SetEntityDrawOutline(highlighted, false)
				highlighted = nil
			end,
			options = {
			  {
				title = SDC.Lang.ScooterMain2,
				description = SDC.Lang.Plate..": "..dat.daplate,
				icon = 'id-card',
			  },
			  {
				title = SDC.Lang.ScooterMain3,
				description = SDC.Lang.ScooterMain4,
				icon = 'hand-holding-dollar',
				onSelect = function()
					input = lib.inputDialog(SDC.Lang.ScooterMain3, {
						{type = 'number', label = SDC.Lang.Hours, description = SDC.Lang.ScooterMain5, icon = 'clock', required= true, default = 0, min = 0, max = SDC.MaxRentTime.Hours},
						{type = 'number', label = SDC.Lang.Minutes, description = SDC.Lang.ScooterMain5, icon = 'clock', required= true, default = 0, min = 0, max = SDC.MaxRentTime.Minutes},
					})

					if input and input[1] and input[2] then
						if (input[1] > 0) or (input[2] > 0) then
							totalTime = input[2] + (input[1]*60)

							if input[1] <= SDC.MaxRentTime.Hours and input[2] <= SDC.MaxRentTime.Minutes then
								if totalTime > 0 then
									TriggerServerEvent("SDES:Server:TryToRent", dat.daplate, totalTime)
									SetEntityDrawOutline(highlighted, false)
									highlighted = nil
								else
									TriggerEvent("SDES:Client:Notification", SDC.Lang.NoSpecifiedTimeGiven, "error")
									lib.showContext('scoot_main')
								end
							else
								TriggerEvent("SDES:Client:Notification", SDC.Lang.InvalidTime..": "..SDC.MaxRentTime.Hours.."("..SDC.Lang.Hours.."), "..SDC.MaxRentTime.Minutes.."("..SDC.Lang.Minutes..")", "error")
								lib.showContext('scoot_main')
							end
						else
							TriggerEvent("SDES:Client:Notification", SDC.Lang.NoSpecifiedTimeGiven, "error")
							lib.showContext('scoot_main')
						end
					else
						lib.showContext('scoot_main')
					end
				end,
			  }
			}
		})
		 
		lib.showContext('scoot_main')
	else
		TriggerEvent("SDES:Client:Notification", SDC.Lang.IssueWithPlate, "error")
	end
end)

RegisterNetEvent("SDES:Client:GiveKeys")
AddEventHandler("SDES:Client:GiveKeys", function(plate)
	Wait(500)
	local daveh = nil
	local timeout = 0
	repeat
		for veh in EnumerateVehicles() do
			if GetVehicleNumberPlateText(veh) == plate then
				daveh = veh
			end
		end

		if not daveh then
			timeout = timeout + 1
		end
		Wait(500)
		if timeout > 10 then
			print("^1Issue Retrieving Plate For Keys^0")
			return
		end
	until daveh
	GiveKeysToVehicle(daveh)
end)


RegisterNetEvent("SDES:Client:GetOffScooter")
AddEventHandler("SDES:Client:GetOffScooter", function(plate)
	local ped = PlayerPedId()
	local veh = GetVehiclePedIsIn(ped, false)

	if veh ~= 0 and GetVehicleNumberPlateText(veh) == plate then
		TaskLeaveVehicle(ped, veh, 256)
	end
end)


Citizen.CreateThread(function()
	while true do
		local ped = PlayerPedId()
		local veh = GetVehiclePedIsIn(ped, false)
		if veh ~= 0 then
			local plate = GetVehicleNumberPlateText(veh)
			local vcoords = GetEntityCoords(veh)
			if string.match(plate, "LEMON") then
				TriggerServerEvent("SDES:Server:UpdateCoords", plate, vec4(vcoords.x, vcoords.y, vcoords.z, GetEntityHeading(veh)))
			end
			Citizen.Wait(1000*SDC.SyncTimer)
		else
			Citizen.Wait(1000)
		end
	end
end)

local showingUI = false
local inMenu = false
Citizen.CreateThread(function()
	while true do
		local ped = PlayerPedId()
		local veh = GetVehiclePedIsIn(ped, false)
		if veh ~= 0 then
			local plate = GetVehicleNumberPlateText(veh)
			local vcoords = GetEntityCoords(veh)
			if string.match(plate, "LEMON") and allScootTimes[plate] and allScootTimes[plate].Owner and allScootTimes[plate].Owner == myIdent then
				if GetEntitySpeed(veh)*2.236936 < 1.0 and not inMenu then
					if not showingUI then
						showingUI = true
						lib.showTextUI(SDC.Lang.OpenScooterMenu, {
							position = "right-center",
							icon = 'rectangle-list',
							style = {
								borderRadius = 0,
								backgroundColor = '#636363',
								color = 'white'
							}
						})
					end
					if IsControlJustReleased(0, SDC.ScooterMenuKeybind) and not inMenu then
						inMenu = true
						SetEntityDrawOutline(veh, true)
						SetEntityDrawOutlineColor(SDC.HighlightedColor.r, SDC.HighlightedColor.g, SDC.HighlightedColor.b, SDC.HighlightedColor.a)
						highlighted = veh
						local daopts = {}
						table.insert(daopts, {
							title = SDC.Lang.ScooterMain2,
							description = SDC.Lang.Plate..": "..plate,
							icon = 'id-card',
						})

						local color = nil
						if math.ceil((allScootTimes[plate].TimeLeft/allScootTimes[plate].InitTime)*100) > 60 then
							color = "green"
						elseif math.ceil((allScootTimes[plate].TimeLeft/allScootTimes[plate].InitTime)*100) > 30 then
							color = "yellow"
						else
							color = "red"
						end
						table.insert(daopts, {
							title = SDC.Lang.ScooterMenu5,
							progress = (allScootTimes[plate].TimeLeft/allScootTimes[plate].InitTime)*100,
							colorScheme = color,
							metadata = {
								{label = 'Percentage', value = math.ceil((allScootTimes[plate].TimeLeft/allScootTimes[plate].InitTime)*100).."%"}
							},
							icon = 'clock',
						})


						table.insert(daopts, {
							title = SDC.Lang.ScooterMenu1,
							description = SDC.Lang.ScooterMenu2,
							icon = 'hand-holding-dollar',
							onSelect = function()
								input = lib.inputDialog(SDC.Lang.ScooterMain3, {
									{type = 'number', label = SDC.Lang.Hours, description = SDC.Lang.ScooterMenu3, icon = 'clock', required= true, default = 0, min = 0, max = SDC.MaxRentTime.Hours},
									{type = 'number', label = SDC.Lang.Minutes, description = SDC.Lang.ScooterMenu4, icon = 'clock', required= true, default = 0, min = 0, max = SDC.MaxRentTime.Minutes},
								})
			
								if input and input[1] and input[2] then
									if (input[1] > 0) or (input[2] > 0) then
										totalTime = input[2] + (input[1]*60)
			
										if input[1] <= SDC.MaxRentTime.Hours and input[2] <= SDC.MaxRentTime.Minutes then
											if totalTime > 0 then
												if ((totalTime*60)+allScootTimes[plate].TimeLeft) <= (((SDC.MaxRentTime.Hours*60)+SDC.MaxRentTime.Minutes)*60) then
													TriggerServerEvent("SDES:Server:TryToAddTime", plate, totalTime)
													SetEntityDrawOutline(highlighted, false)
													highlighted = nil
													inMenu = false
												else
													TriggerEvent("SDES:Client:Notification", SDC.Lang.InvalidTime2, "error")
													lib.showContext('scoot_menu')
												end
											else
												TriggerEvent("SDES:Client:Notification", SDC.Lang.NoSpecifiedTimeGiven, "error")
												lib.showContext('scoot_menu')
											end
										else
											TriggerEvent("SDES:Client:Notification", SDC.Lang.InvalidTime..": "..SDC.MaxRentTime.Hours.."("..SDC.Lang.Hours.."), "..SDC.MaxRentTime.Minutes.."("..SDC.Lang.Minutes..")", "error")
											lib.showContext('scoot_menu')
										end
									else
										TriggerEvent("SDES:Client:Notification", SDC.Lang.NoSpecifiedTimeGiven, "error")
										lib.showContext('scoot_menu')
									end
								else
									lib.showContext('scoot_menu')
								end
							end,
						})

						lib.registerContext({
							id = 'scoot_menu',
							title = SDC.Lang.ScooterMain1,
							onExit = function()
								SetEntityDrawOutline(highlighted, false)
								highlighted = nil
								inMenu = false
							end,
							options = daopts
						})
						 
						lib.showContext('scoot_menu')
					end
				elseif showingUI then
					showingUI = false
					lib.hideTextUI()
				end
				Citizen.Wait(1)
			else
				Citizen.Wait(500)
			end
		else
			if showingUI then
				showingUI = false
				lib.hideTextUI()
			end
			Citizen.Wait(1000)
		end
	end
end)


if SDC.DrawScooterIcon.Enabled then
	Citizen.CreateThread(function()
		while not HasStreamedTextureDictLoaded("escooters") do
			Citizen.Wait(10)
			RequestStreamedTextureDict("escooters", true)
		end
	
		while true do
			if myIdent then
				local drawing = false
				local ped = PlayerPedId()
				local pcoords = GetEntityCoords(ped)
				local vehh = GetVehiclePedIsIn(ped, false)
				for plate,veh in pairs(spawnedScoots) do
					if Vdist(pcoords.x, pcoords.y, pcoords.z, GetEntityCoords(veh)) <= SDC.DrawScooterIcon.DistanceToSee and vehh == 0 then
						local drawC = GetOffsetFromEntityInWorldCoords(veh, 0.0, -0.2, 0.5)
						SetDrawOrigin(drawC.x, drawC.y, drawC.z, 0)
						DrawSprite("escooters", "lemonlogo", 0.0, 0.0, 0.04, 0.05, 0, 230, 230, 230, 255)
						ClearDrawOrigin()
						drawing = true
					end
				end
		
				if drawing then
					Citizen.Wait(1)
				else
					Citizen.Wait(500)
				end
			else
				Citizen.Wait(1000)
			end
		end
	end)
end













AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
		for k,v in pairs(spawnedScoots) do
			if DoesEntityExist(v) then
				DeleteEntity(v)
			end
		end

		for k,v in pairs(allScootBlips) do
			if DoesBlipExist(v) then
				RemoveBlip(v)
			end
		end
	end
end)

---------------------------------------------------------------------
-------------------------Functions-----------------------------------
---------------------------------------------------------------------
function MakeEntityFaceEntity(entity1, entity2)
	local p1 = GetEntityCoords(entity1, true)
	local p2 = GetEntityCoords(entity2, true)

	local dx = p2.x - p1.x
	local dy = p2.y - p1.y

	local heading = GetHeadingFromVector_2d(dx, dy)
	SetEntityHeading( entity1, heading )
end

function LoadPropDict(model)
	while not HasModelLoaded(GetHashKey(model)) do
	  RequestModel(GetHashKey(model))
	  Wait(10)
	end
end

function LoadAnim(dict)
	while not HasAnimDictLoaded(dict) do
	  RequestAnimDict(dict)
	  Wait(10)
	end
end

--Enums
local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
	return coroutine.wrap(function()
		local iter, id = initFunc()
		if not id or id == 0 then
			disposeFunc(iter)
			return
		end

		local enum = {handle = iter, destructor = disposeFunc}
		setmetatable(enum, entityEnumerator)
		local next = true

		repeat
			coroutine.yield(id)
			next, id = moveFunc(iter)
		until not next

		enum.destructor, enum.handle = nil, nil
		disposeFunc(iter)
	end)
end

function EnumerateEntitiesWithinDistance(entities, isPlayerEntities, coords, maxDistance)
	local nearbyEntities = {}

	if coords then
		coords = vector3(coords.x, coords.y, coords.z)
	else
		local playerPed = PlayerPedId()
		coords = GetEntityCoords(playerPed)
	end

	for k,entity in pairs(entities) do
		local distance = #(coords - GetEntityCoords(entity))

		if distance <= maxDistance then
			table.insert(nearbyEntities, isPlayerEntities and k or entity)
		end
	end

	return nearbyEntities
end

function EnumerateObjects()
	return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

function EnumeratePeds()
	return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

function EnumerateVehicles()
	return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

function EnumeratePickups()
	return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup)
end