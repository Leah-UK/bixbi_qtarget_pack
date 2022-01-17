-- RegisterNetEvent('bixbi_target:RepairVehicle')
AddEventHandler('bixbi_target:RepairVehicle', function(data)
    local itemCount = exports['bixbi_core']:itemCount('repairkit')
    if itemCount ~= 0 then
        local vehicle, distance = ESX.Game.GetClosestVehicle()
        if (vehicle ~= nil and distance < 2.0) then
            TriggerServerEvent('bixbi_core:removeItem', nil, 'repairkit', 1)

            exports['bixbi_core']:Loading(10000, 'Repairing Vehicle')
            exports['bixbi_core']:playAnim(PlayerPedId(), 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', 'machinic_loop_mechandplayer', -1, false)
            Citizen.Wait(10000)

            SetVehicleFixed(vehicle)
            SetVehicleDeformationFixed(vehicle)
            SetVehicleUndriveable(vehicle, false)

            exports['bixbi_core']:Notify('', 'Vehicle Repaired.')
        end
    end
end)

-- RegisterNetEvent('bixbi_target:Hospital')
AddEventHandler('bixbi_target:Hospital', function(data)
    local dialog = exports['zf_dialog']:DialogInput({
        header = "Send to Hospital", 
        rows = {
            {
                id = 0, 
                txt = "Length (1 = 1 Minute)"
            },
            {
                id = 1, 
                txt = "Location (P = Pillbox, S = Sandy, B = Paleto Bay)"
            },
        }
    })
    if dialog ~= nil then
        if dialog[1].input == nil or dialog[2].input == nil then return end
        TriggerServerEvent('bixbi_hospitaltp:Hospital', GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)), tonumber(dialog[1].input), dialog[2].input)
    end
end)

-- RegisterNetEvent('bixbi_target:Bandage')
AddEventHandler('bixbi_target:Bandage', function(data)
    local playerPed = PlayerPedId()
    local distance = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(data.entity))
    if (distance > 3.0) then return end
    
    ESX.TriggerServerCallback('bixbi_core:itemCount', function(quantity)
        if quantity > 0 then
            local health = GetEntityHealth(NetworkGetPlayerIndexFromPed(data.entity))

            if health > 0 then
                TriggerEvent('bixbi_core:Loading', 10000, 'Bandaging...')
                TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
                Citizen.Wait(10000)
                ClearPedTasks(playerPed)

                TriggerServerEvent('esx_ambulancejob:removeItem', 'bandage')
                TriggerServerEvent('esx_ambulancejob:heal', GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)), 'big')
                TriggerEvent('bixbi_core:Notify', 'success', 'Bandaged')
            else
                TriggerEvent('bixbi_core:Notify', 'error', 'Player isn\'t conscious')
            end
        else
            TriggerEvent('bixbi_core:Notify', 'error', 'Not enough bandages')
        end
    end, 'bandage')
end)

-- RegisterNetEvent('bixbi_target:Prison')
AddEventHandler('bixbi_target:Prison', function(data)
    local dialog = exports['zf_dialog']:DialogInput({
        header = "Send to Prison", 
        rows = {
            {
                id = 0, 
                txt = "Length (1 = 1 Minute)"
            },
            {
                id = 1, 
                txt = "Reason"
            }
        }
    })
    if dialog ~= nil then
        if dialog[1].input == nil or dialog[2].input == nil then return end
        TriggerServerEvent('bixbi_prison:JailPlayer', GetPlayerServerId(PlayerId()), GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)), dialog[1].input, dialog[2].input)
    end
end)

local isDragged = false
draggingEntity = nil
-- RegisterNetEvent('bixbi_target:DragStart')
AddEventHandler('bixbi_target:DragStart', function(data)
    draggingEntity = data.entity
    TriggerServerEvent('bixbi_target:DragServer', GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity)))
end)

RegisterNetEvent('bixbi_target:Drag')
AddEventHandler('bixbi_target:Drag', function(draggerId, needsCuff)
    local playerPed = PlayerPedId()
    local isHandcuffed = exports['esx_policejob']:IsHandcuffed()
    if (needsCuff) then
        print('')
        while (isHandcuffed == nil) do
            Citizen.Wait(500)
        end
        print('')
    end

    -- Citizen.Wait(500)
    print('')
    isDragged = not isDragged

    if (needsCuff and not isHandcuffed) then return end
    if (not isDragged) then return end
    local targetPed = GetPlayerPed(GetPlayerFromServerId(draggerId))
    local distance = #(GetEntityCoords(playerPed) - GetEntityCoords(targetPed))
    if (distance > 3.0) then return end

    Citizen.CreateThread(function()
        while (isDragged) do
            if DoesEntityExist(targetPed) and IsPedOnFoot(targetPed) and not IsPedDeadOrDying(targetPed, true) then
                AttachEntityToEntity(playerPed, targetPed, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
            else
                isDragged = false
            end
            Citizen.Wait(1000)
        end
        DetachEntity(playerPed, true, false)
    end)
end)

-- RegisterNetEvent('bixbi_target:PutInVehicleStart')
AddEventHandler('bixbi_target:PutInVehicleStart', function(data)
    local distance = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(draggingEntity))
    if (draggingEntity == nil or distance > 2.0) then
        exports['bixbi_core']:Notify('error', 'You\'re not dragging anyone.')
        draggingEntity = nil
        return
    end

    local netID = NetworkGetNetworkIdFromEntity(data.entity)
    SetNetworkIdExistsOnAllMachines(netID, true)
    TriggerServerEvent('bixbi_target:PutInVehicleServer', GetPlayerServerId(NetworkGetPlayerIndexFromPed(draggingEntity)), netID)
    draggingEntity = nil
end)

-- RegisterNetEvent('bixbi_target:PutInVehicle')
AddEventHandler('bixbi_target:PutInVehicle', function(vehicleId)
    local vehicle = NetworkGetEntityFromNetworkId(vehicleId)
    if (IsEntityAVehicle(vehicle)) then
        local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(vehicle)
        for i=maxSeats - 1, 0, -1 do
            if IsVehicleSeatFree(vehicle, i) then
                freeSeat = i
                break
            end
        end

        if freeSeat then
            TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, freeSeat)
            isDragged = false
        end
    end
end)

-- RegisterNetEvent('bixbi_target:PullOutVehicleStart')
AddEventHandler('bixbi_target:PullOutVehicleStart', function(data)
    if (IsEntityAVehicle(data.entity)) then
        local netID = NetworkGetNetworkIdFromEntity(data.entity)
        SetNetworkIdExistsOnAllMachines(netID, true)

        for i = 6, 1, -1 do
            local ped = GetPedInVehicleSeat(data.entity, i - 2)
            if (ped ~= 0) then
                local playerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped))
                TriggerServerEvent('bixbi_target:PullOutVehicleServer', playerId, netID)
            end
        end
    end
end)

-- RegisterNetEvent('bixbi_target:PullOutVehicle')
AddEventHandler('bixbi_target:PullOutVehicle', function(vehicleId)
    local vehicle = NetworkGetEntityFromNetworkId(vehicleId)
    if (IsEntityAVehicle(vehicle)) then
        TaskLeaveVehicle(PlayerPedId(), vehicle, 0)
    end
end)

-- RegisterNetEvent('bixbi_target:ForceOpen')
AddEventHandler('bixbi_target:ForceOpen', function(data)
    if GetVehicleDoorLockStatus(data.entity) == 1 or GetVehicleDoorLockStatus(data.entity) == 0 then
        exports['bixbi_core']:Notify('error', 'Vehicle isn\'t locked')
        return
    end
    local playerPed = PlayerPedId()
    TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_WELDING', 0, true)
    exports['bixbi_core']:Loading(20000, 'Picking Lock...')
    Citizen.Wait(20000)
    ClearPedTasksImmediately(playerPed)

    SetVehicleDoorsLocked(data.entity, 1)
    SetVehicleDoorsLockedForAllPlayers(data.entity, false)
    exports['bixbi_core']:Notify('', 'Vehicle Unlocked')
end)

-- RegisterNetEvent('bixbi_target:Lockpick')
AddEventHandler('bixbi_target:Lockpick', function(data)
    if GetVehicleDoorLockStatus(data.entity) == 1 or GetVehicleDoorLockStatus(data.entity) == 0 then
        exports['bixbi_core']:Notify('error', 'Vehicle isn\'t locked')
        return
    end

    local itemCount = exports['bixbi_core']:itemCount('lockpick')
    while (itemCount == nil) do
        Citizen.Wait(100)
    end
    if (itemCount == 0) then
        exports['bixbi_core']:Notify('error', 'You need a lockpick')
        return 
    end

    local playerPed = PlayerPedId()
    TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_WELDING', 0, true)
    TriggerServerEvent('bixbi_core:removeItem', nil, 'lockpick', 1)
    exports['bixbi_core']:Loading(20000, 'Picking Lock...')
    Citizen.Wait(20000)
    ClearPedTasksImmediately(playerPed)

    math.randomseed(GetGameTimer())
    local random = math.random(1, 3)
    if (random == 1) then
        exports['bixbi_core']:Notify('error', 'You failed to lockpick the vehicle.')
    else
        SetVehicleDoorsLocked(data.entity, 1)
        SetVehicleDoorsLockedForAllPlayers(data.entity, false)
        exports['bixbi_core']:Notify('', 'Vehicle Unlocked')
    end
end)

-- RegisterNetEvent('bixbi_target:RepairVehicle')
AddEventHandler('bixbi_target:RepairVehicle', function(data)
    local itemCount = exports['bixbi_core']:itemCount('repairkit')
    while (itemCount == nil) do Citizen.Wait(100) end
    if (itemCount == 0) then
        exports['bixbi_core']:Notify('error', 'You need a repair kit')
        return 
    end

    local playerPed = PlayerPedId()
    TaskStartScenarioInPlace(playerPed, 'PROP_HUMAN_BUM_BIN', 0, true)
    TriggerServerEvent('bixbi_core:removeItem', nil, 'repairkit', 1)
    exports['bixbi_core']:Loading(20000, 'Repairing Vehicle...')
    Citizen.Wait(20000)

    SetVehicleFixed(data.entity)
    SetVehicleDeformationFixed(data.entity)
    SetVehicleUndriveable(data.entity, false)
    SetVehicleEngineOn(data.entity, true, true)
    ClearPedTasksImmediately(playerPed)

    exports['bixbi_core']:Notify('', 'Vehicle Repaired')
end)

-- RegisterNetEvent('bixbi_target:CleanVehicle')
AddEventHandler('bixbi_target:CleanVehicle', function(data)
    local playerPed = PlayerPedId()
    TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_MAID_CLEAN', 0, true)
    exports['bixbi_core']:Loading(10000, 'Cleaning Vehicle...')
    Citizen.Wait(10000)

    ClearPedTasksImmediately(playerPed)
    SetVehicleDirtLevel(data.entity, 0)

    exports['bixbi_core']:Notify('', 'Vehicle Cleaned')
end)

RegisterNetEvent('bixbi_target:EscortToggle')
AddEventHandler('bixbi_target:EscortToggle', function(data)
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    if closestPlayer ~= -1 and closestDistance <= 2.0 then
        TriggerServerEvent('bixbi_target:DragServer', GetPlayerServerId(closestPlayer))
    end
end)