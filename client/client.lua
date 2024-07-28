local humanPeds       = json.decode(LoadResourceFile(GetCurrentResourceName(), 'data/human-peds.json'))

local targeting       = false
local targetedPed     = nil
local lastTargetedPed = nil

-- Threads

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(1000)

    local playerId = PlayerPedId()
    local playerCoordinates = GetEntityCoords(playerId)
    local streetHash, crossStreetHash = GetStreetNameAtCoord(table.unpack(playerCoordinates))
    local streetName = GetStreetNameFromHashKey(streetHash)
    local crossStreetName = GetStreetNameFromHashKey(crossStreetHash)

    LocalPlayer.state:set('curStreetName', streetName, true)
    LocalPlayer.state:set('curCrossStreetName', crossStreetName, true)
  end
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)

    local playerId = PlayerPedId()
    local playerCoordinates = GetEntityCoords(playerId)
    local hit, entityHit, endCoords = raycastFromCamera(8)

    if hit == 1 then
      local distance = #(playerCoordinates - endCoords)
      local pedModel = tostring(GetEntityModel(entityHit))

      if distance < 3.0 and humanPeds[pedModel] then
        targeting   = true
        targetedPed = entityHit
      else
        targeting   = false
        targetedPed = nil
      end
    else
      targeting   = false
      targetedPed = nil
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)

    if not targeting then
      if lastTargetedPed then
        handleDetarget()
      end

      goto continue
    end

    if targeting then
      if lastTargetedPed and lastTargetedPed ~= targetedPed then
        handleDetarget()
      end

      if not lastTargetedPed then
        lastTargetedPed = targetedPed

        LocalPlayer.state:set('targetedPed', NetworkGetNetworkIdFromEntity(targetedPed), true)

        ClearPedTasksImmediately(targetedPed)

        TaskTurnPedToFaceEntity(targetedPed, PlayerPedId(), 1000)

        Citizen.Wait(1000)

        FreezeEntityPosition(targetedPed, true)
      end

      TaskStandStill(targetedPed, 1000)
    end

    ::continue::
  end
end)

-- Functions

function handleDetarget()
  if DoesEntityExist(lastTargetedPed) then
    FreezeEntityPosition(lastTargetedPed, false)
    TaskWanderStandard(lastTargetedPed, 10.0, 10)
  end

  LocalPlayer.state:set('targetedPed', nil, true)

  lastTargetedPed = nil
end

function raycastFromCamera(flag)
  local coords, normal = GetWorldCoordFromScreenCoord(0.5, 0.5)
  local destination    = coords + normal * 10

  local handle         = StartShapeTestLosProbe(
    coords.x,
    coords.y,
    coords.z,
    destination.x,
    destination.y,
    destination.z,
    flag,
    PlayerPedId(),
    4
  )

  while true do
    Citizen.Wait(0)

    local retVal, hit, endCoords, surfaceNormal, materialHash, entityHit = GetShapeTestResultIncludingMaterial(handle)

    if retVal ~= 1 then
      return hit, entityHit, endCoords, surfaceNormal, materialHash
    end
  end
end
