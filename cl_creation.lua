local emsTag = "[EMS] "
local pdTag = "[PD] "
local mechTag = "[MECH] "

exports['qtarget']:Vehicle({
    options = {
        {
            event = "bixbi_target:PutInVehicleStart",
            icon = "fas fa-car-side",
            label = "[PD] Put in Vehicle",
            job = "police",
            canInteract = function(entity)
                if (draggingEntity == nil) then return false end
                return true
            end,
        },
        {
            event = "bixbi_target:PullOutVehicleStart",
            icon = "fas fa-user-minus",
            label = "[PD] Pull Out of Vehicle",
            job = "police"
        },
        {
            event = "bixbi_target:ForceOpen",
            icon = "fas fa-file-invoice-dollar",
            label = "[PD] Unlock Vehicle",
            job = "police"
        },
        {
            event = "bixbi_target:PutInVehicleStart",
            icon = "fas fa-car-side",
            label = "[EMS] Put in Vehicle",
            job = "ambulance",
            canInteract = function(entity)
                if (draggingEntity == nil) then return false end
                return true
            end,
        },
        {
            event = "bixbi_target:PullOutVehicleStart",
            icon = "fas fa-user-minus",
            label = "[EMS] Pull Out of Vehicle",
            job = "ambulance"
        },
        {
            event = "bixbi_target:RepairVehicle",
            icon = "fas fa-toolbox",
            label = "[MECH] Repair",
            item = 'repairkit',
            job = "mechanic"
        },
        {
            event = "bixbi_target:CleanVehicle",
            icon = "fas fa-hand-sparkles",
            label = "[MECH] Clean",
            job = "mechanic"
        },
        {
            event = "bixbi_target:ForceOpen",
            icon = "fas fa-unlock",
            label = "[MECH] Unlock Vehicle",
            job = "mechanic"
        },
        {
            event = "bixbi_target:Lockpick",
            icon = "fas fa-unlock",
            item = 'lockpick',
            label = 'Lockpick Vehicle',
            canInteract = function(entity)
                if (ESX.PlayerData.job.name == 'police' or ESX.PlayerData.job.name == 'mechanic') then return false end
                return true
            end, 
        },
    },
    distance = 2.0
})

exports['qtarget']:Player({
    options = {
        {
            icon = "fak fa-handcuffs",
            label = "[PD] Handcuffs",
            job = "police",
            action = function(entity)
                TriggerServerEvent('esx_policejob:handcuff', GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity)))
            end,
            canInteract = function(entity)
                if IsPedAPlayer(entity) then 
                    return (not IsPedDeadOrDying(entity, 1))
                end
            end
        },
        {
            icon = "fas fa-briefcase",
            label = "[PD] Search",
            job = "police",
            action = function(entity)
                exports.ox_inventory:OpenNearbyInventory()
            end,
            canInteract = function(entity)
                if IsPedAPlayer(entity) then
                    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                    return (Player(targetId).state.handsup or Player(targetId).state.handcuffed or Player(targetId).state.ziptied)
                end
            end
        },
        {
            event = "bixbi_target:DragStart",
            icon = "fas fa-users",
            label = "[PD] Escort",
            job = "police",
            canInteract = function(entity)
                if IsPedAPlayer(entity) then
                    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                    return (Player(targetId).state.handcuffed and not IsPedDeadOrDying(entity, 1) or Player(targetId).state.ziptied)
                end
            end
        },
        {
            event = "bixbi_target:Prison",
            icon = "fas fa-house-user",
            label = "[PD] Prison",
            job = "police",
            canInteract = function(entity)
                if IsPedAPlayer(entity) then
                    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                    return (Player(targetId).state.handcuffed and not IsPedDeadOrDying(entity, 1))
                end
            end
        },
        {
            event = "bixbi_target:DragStart",
            icon = "fas fa-users",
            label = "[EMS] Escort",
            job = "ambulance",
            canInteract = function(entity)
                if IsPedAPlayer(entity) then 
                    return (not IsPedDeadOrDying(entity, 1))
                end
            end,
        },
        {
            event = "bixbi_target:Revive",
            icon = "fas fa-hand-holding-medical",
            label = "[EMS] Revive",
            job = "ambulance",
            canInteract = function(entity)
                if IsPedAPlayer(entity) then 
                    return (IsPedDeadOrDying(entity, 1))
                end
            end,
            action = function(entity)
                exports['esx_ambulancejob']:revivePlayer(NetworkGetPlayerIndexFromPed(entity))
            end
        },
        {
            event = "bixbi_target:Bandage",
            icon = "fas fa-prescription-bottle",
            label = "[EMS] Bandage",
            job = "ambulance",
            canInteract = function(entity)
                if IsPedAPlayer(entity) then 
                    return (GetPedMaxHealth(entity) ~= GetEntityHealth(entity) and not IsPedDeadOrDying(entity, 1))
                end
            end,
        },
        {
            event = "bixbi_target:Hospital",
            icon = "fas fa-hospital",
            label = "[EMS] Hospital",
            job = "ambulance",
            canInteract = function(entity)
                if IsPedAPlayer(entity) then 
                    return (not IsPedDeadOrDying(entity, 1))
                end
            end,
        },
        {
            -- event = "bixbi_target:OpenTargetInventory",
            icon = "fa-solid fa-sack-dollar",
            label = "Rob",
            canInteract = function(entity)
                if IsPedAPlayer(entity) then 
                    if (ESX.PlayerData.job.name == 'police' or ESX.PlayerData.job.name == 'ambulance') then return false end
                    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                    return ((Player(targetId).state.handsup or Player(targetId).state.ziptied) and (IsPedArmed(PlayerPedId(), 4) or IsPedArmed(PlayerPedId(), 1)))
                end
            end, 
            action = function(entity)
                exports.ox_inventory:OpenNearbyInventory()
            end
        },
        {
            icon = "fas fa-user-ninja",
            label = "Take Hostage",
            canInteract = function(entity)
                if IsPedAPlayer(entity) then 
                    if (ESX.PlayerData.job.name == 'police' or ESX.PlayerData.job.name == 'ambulance') then return false end
                    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                    return ((Player(targetId).state.handsup or Player(targetId).state.ziptied) and (IsPedArmed(PlayerPedId(), 4) or IsPedArmed(PlayerPedId(), 1)) and not IsPedDeadOrDying(entity, 1))
                end
            end, 
            action = function(entity)
                TriggerEvent('TakeHostage:Start', GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity)))
            end
        },
    },
    distance = 2.0
})