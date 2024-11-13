local QBCore = exports['qb-core']:GetCoreObject()
local isLyingDown = false

local function LayDown(coords, heading)
    TaskStartScenarioAtPosition(PlayerPedId(), "WORLD_HUMAN_SUNBATHE_BACK", coords.x, coords.y, coords.z, heading, 0, true, true)
    isLyingDown = true
end

local function GetUp()
    ClearPedTasksImmediately(PlayerPedId())
    isLyingDown = false
end

CreateThread(function()
    for i, bed in ipairs(Config.BedLocations) do
        exports['qb-target']:AddBoxZone("bed_"..i, bed.coords, 1.0, 1.0, {
            name = "bed_"..i,
            heading = bed.heading,
            debugPoly = false,
            minZ = bed.coords.z - 1.0,
            maxZ = bed.coords.z + 1.0
        }, {
            options = {
                {
                    type = "client",
                    event = "qb-bed-lying:client:LayDown",
                    icon = "fas fa-bed",
                    label = "Połóż się na łóżku",
                    coords = bed.coords,
                    heading = bed.heading,
                    canInteract = function()
                        return not isLyingDown
                    end
                },
                {
                    type = "client",
                    event = "qb-bed-lying:client:GetUp",
                    icon = "fas fa-walking",
                    label = "Wstań z łóżka",
                    canInteract = function()
                        return isLyingDown
                    end
                },
            },
            distance = 2.0
        })
    end
end)

RegisterNetEvent('qb-bed-lying:client:LayDown', function(data)
    LayDown(data.coords, data.heading)
end)

RegisterNetEvent('qb-bed-lying:client:GetUp', function()
    GetUp()
end)

RegisterCommand('wstan', function()
    if isLyingDown then
        GetUp()
    else
        QBCore.Functions.Notify("Nie leżysz na łóżku!", "error")
    end
end, false)
