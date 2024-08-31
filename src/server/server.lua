local loaded = false
local allScoots = {}
local serverScoots = {}
local identToSrc = {}


Citizen.CreateThread(function()
    for i=1, #SDC.Spawnpoints do
        local newplate = nil
        newplate = "LEMON"..i
        for i=1, (8 - #newplate) do
            newplate = newplate.." "
        end
        allScoots[newplate] = {SpawnPoint = i, Coords = SDC.Spawnpoints[i], Localize = true}
    end
    loaded = true
    while true do
        if loaded then
            TriggerClientEvent("SDES:Client:UpdateScootTable", -1, allScoots, serverScoots)
            Citizen.Wait(1000*SDC.SyncTimer)
        else
            Citizen.Wait(500)
        end
    end
end)

RegisterServerEvent("SDES:Server:LoadedIn")
AddEventHandler("SDES:Server:LoadedIn", function()
    local src = source
    local ident = GetPlayerIdentifierByType(src, SDC.Identifier)

    identToSrc[ident] = src
    TriggerClientEvent("SDES:Client:UpdateScootTable", src, allScoots, serverScoots)
    TriggerClientEvent("SDES:Client:UpdateIdent", src, ident)
end)
AddEventHandler('playerDropped', function(reason) 
    local src = nil
    src = source
    local ident = nil
    ident = GetPlayerIdentifierByType(src, SDC.Identifier)
    if ident then
        identToSrc[ident] = nil
    elseif src then
        for k,v in pairs(identToSrc) do
            if v == src then
                identToSrc[k] = nil
            end
        end
    end
end)

RegisterServerEvent("SDES:Server:TryToRent")
AddEventHandler("SDES:Server:TryToRent", function(plate, timeWanted)
    local src = source
    local ident = GetPlayerIdentifierByType(src, SDC.Identifier)
    totalPrice = math.ceil(timeWanted*SDC.PricePerMin)
    theirBank = GetCurrentBankAmount(src) 

    if allScoots[plate] and allScoots[plate].Localize then
        if theirBank and theirBank >= totalPrice then
            if RemoveBankMoney(src, totalPrice) then
                allScoots[plate].Localize = false
                TriggerClientEvent("SDES:Client:UpdateScootTable", -1, allScoots, serverScoots)
                TriggerClientEvent("SDES:Client:Notification", src, SDC.Lang.ProccessingPayment, "primary")
                Wait(1000)
                local veh = CreateVehicle(SDC.EScooterModel, allScoots[plate].Coords.x, allScoots[plate].Coords.y, allScoots[plate].Coords.z, allScoots[plate].Coords.w, true, false)
                SetVehicleNumberPlateText(veh, plate)
                serverScoots[plate] = {InitTime = timeWanted*60, TimeLeft = timeWanted*60, Owner = ident, Vdata = veh}
                TriggerClientEvent("SDES:Client:GiveKeys", src, plate)
                TriggerClientEvent("SDES:Client:Notification", src, SDC.Lang.RentedScooter..": ("..plate..")", "success")
            else
                TriggerClientEvent("SDES:Client:Notification", src, SDC.Lang.NotEnoughInBank, "error")
            end
        else
            TriggerClientEvent("SDES:Client:Notification", src, SDC.Lang.NotEnoughInBank, "error")
        end
    else
        TriggerClientEvent("SDES:Client:Notification", src, SDC.Lang.AlreadyPurchased, "error")
    end
end)
RegisterServerEvent("SDES:Server:TryToAddTime")
AddEventHandler("SDES:Server:TryToAddTime", function(plate, timeWanted)
    local src = source
    local ident = GetPlayerIdentifierByType(src, SDC.Identifier)
    totalPrice = math.ceil(timeWanted*SDC.PricePerMin)
    theirBank = GetCurrentBankAmount(src) 

    if allScoots[plate] and serverScoots[plate] then
        if theirBank and theirBank >= totalPrice then
            if RemoveBankMoney(src, totalPrice) then
                newtime = serverScoots[plate].TimeLeft+(timeWanted*60)
                serverScoots[plate].InitTime = newtime
                serverScoots[plate].TimeLeft = newtime
                TriggerClientEvent("SDES:Client:UpdateScootTable", -1, allScoots, serverScoots)
                TriggerClientEvent("SDES:Client:Notification", src, SDC.Lang.AddedTime..": ("..plate..")", "success")
            else
                TriggerClientEvent("SDES:Client:Notification", src, SDC.Lang.NotEnoughInBank, "error")
            end
        else
            TriggerClientEvent("SDES:Client:Notification", src, SDC.Lang.NotEnoughInBank, "error")
        end
    else
        TriggerClientEvent("SDES:Client:Notification", src, SDC.Lang.IssueProccessingPayment, "error")
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if loaded then
            for k,v in pairs(serverScoots) do
                serverScoots[k].TimeLeft = v.TimeLeft - 1

                if serverScoots[k].TimeLeft <= 0 then
                    if identToSrc[serverScoots[k].Owner] then
                        TriggerClientEvent("SDES:Client:GetOffScooter", identToSrc[serverScoots[k].Owner], k)
                        TriggerClientEvent("SDES:Client:Notification", identToSrc[serverScoots[k].Owner], SDC.Lang.ScooterRentalExpired.." ("..k..")", "error")
                    end
                    Citizen.Wait(500)
                    if DoesEntityExist(serverScoots[k].Vdata) then
                        if not SDC.PersistantScooters then
                            DeleteEntity(serverScoots[k].Vdata)
                            serverScoots[k] = nil
                            allScoots[k].Localize = true
                            TriggerClientEvent("SDES:Client:UpdateScootTable", -1, allScoots, serverScoots)
                        else
                            cc = GetEntityCoords(serverScoots[k].Vdata)
                            allScoots[k].Coords = vec4(cc.x, cc.y, cc.z, GetEntityHeading(serverScoots[k].Vdata))
                            DeleteEntity(serverScoots[k].Vdata)
                            serverScoots[k] = nil
                            allScoots[k].Localize = true
                            TriggerClientEvent("SDES:Client:UpdateScootTable", -1, allScoots, serverScoots)
                        end
                    else
                        serverScoots[k] = nil
                        allScoots[k].Localize = true
                        TriggerClientEvent("SDES:Client:UpdateScootTable", -1, allScoots, serverScoots)
                    end
                end
                Citizen.Wait(10)
            end
        end
    end
end)
RegisterServerEvent("SDES:Server:UpdateCoords")
AddEventHandler("SDES:Server:UpdateCoords", function(plate, coords)
    local src = source

    if serverScoots[plate] and allScoots[plate] then
        allScoots[plate].Coords = coords
    end
end)


AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
		for k,v in pairs(serverScoots) do
			if DoesEntityExist(v.Vdata) then
				DeleteEntity(v.Vdata)
			end
		end
	end
end)