local QBCore = nil
local ESX = nil

if SDC.Framework == "qb-core" then
    QBCore = exports['qb-core']:GetCoreObject()
elseif SDC.Framework == "esx" then
    ESX = exports["es_extended"]:getSharedObject()
end

function GiveKeysToVehicle(veh)
    if SDC.Framework == "qb-core" then
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
    else
        --Here is where you would put your resource for vehicle keys!
    end
end

function AddTargetToScooter(veh, eventtotrigger, plate)
    if SDC.Target == "qb-target" then
        exports['qb-target']:AddTargetEntity(veh, { 
            options = {  
                {  
                    type = "client", 
                    event = eventtotrigger,  
                    icon = 'fas fa-hand',  
                    label = SDC.Lang.InteractWithScooter,
					daplate = plate
                }
            },
            distance = 1.5, 
        })
    elseif SDC.Target == "ox-target" then
        exports.ox_target:addLocalEntity(veh, {
            {  
                label = SDC.Lang.InteractWithScooter, 
                icon = 'fa-hand', 
                distance = 1.5,
                event = eventtotrigger, 
				daplate = plate
            }
        })
    end
end


RegisterNetEvent("SDES:Client:Notification")
AddEventHandler("SDES:Client:Notification", function(msg, extra)
	if SDC.NotificationSystem == 'tnotify' then
		exports['t-notify']:Alert({
			style = 'message', 
			message = msg
		})
	elseif SDC.NotificationSystem == 'mythic_old' then
		exports['mythic_notify']:DoHudText('inform', msg)
	elseif SDC.NotificationSystem == 'mythic_new' then
		exports['mythic_notify']:SendAlert('inform', msg)
	elseif SDC.NotificationSystem == 'okoknotify' then
		exports['okokNotify']:Alert(SDC.Lang.DealershipLabel, msg, 3000, 'neutral')
	elseif SDC.NotificationSystem == 'print' then
		print(msg)
	elseif SDC.NotificationSystem == 'framework' then
        if SDC.Framework == "qb-core" then
            QBCore.Functions.Notify(msg, extra)
        elseif SDC.Framework == "esx" then
            ESX.ShowNotification(msg)
        end
	end 
end)