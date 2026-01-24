local lastProps = {
    [0] = { drawable = -1, texture = -1, dropped = false },
    [1] = { drawable = -1, texture = -1, dropped = false }
}
local assignedEntities = {}

local function GetObjectSize(entity)
    local min, max = GetModelDimensions(GetEntityModel(entity))
    return #(max - min)
end

local function AttachTarget(entity, propId, data)
    local label = propId == 0 and _L('pickup_hat') or _L('pickup_glasses')
    SetEntityAsMissionEntity(entity, true, true)
    
    assignedEntities[entity] = { propId = propId, coords = GetEntityCoords(entity) }

    exports.ox_target:addLocalEntity(entity, {
        {
            name = "drop_" .. entity .. "_" .. propId,
            label = label,
            icon = 'fa-solid fa-hand',
            distance = 2.0,
            onSelect = function()
                if lib.progressBar({
                    duration = 800,
                    label = _L('picking_up'),
                    useWhileDead = false,
                    canCancel = true,
                    disable = { move = true },
                    anim = { dict = 'random@domestic', clip = 'pickup_low' }
                }) then
                    if DoesEntityExist(entity) then DeleteEntity(entity) end
                    SetPedPropIndex(cache.ped, propId, data.drawable, data.texture, true)
                    assignedEntities[entity] = nil
                end
            end
        }
    })
end

CreateThread(function()
    local cleanupTimer = 0
    while true do
        local ped = cache.ped
        local sleep = 1500

        if ped then
            local hasSomething = false
            local droppedSlots = {}

            for i = 0, 1 do
                local current = GetPedPropIndex(ped, i)
                if current ~= -1 then
                    lastProps[i].drawable = current
                    lastProps[i].texture = GetPedPropTextureIndex(ped, i)
                    lastProps[i].dropped = false
                    hasSomething = true
                else
                    if lastProps[i].drawable ~= -1 and not lastProps[i].dropped then
                        lastProps[i].dropped = true
                        table.insert(droppedSlots, i)
                    end
                end
            end

            if hasSomething then sleep = 500 end

            if #droppedSlots > 0 then
                sleep = 0
                Wait(300)
                local coords = GetEntityCoords(ped)
                local nearby = lib.getNearbyObjects(coords, Config.Settings.SearchRadius)
                local foundObjects = {}

                for i=1, #nearby do
                    local ent = nearby[i].object
                    if DoesEntityExist(ent) and not assignedEntities[ent] then
                        table.insert(foundObjects, { ent = ent, size = GetObjectSize(ent) })
                    end
                end

                table.sort(foundObjects, function(a, b) return a.size > b.size end)

                if #foundObjects > 0 then
                    if #droppedSlots == 2 and #foundObjects >= 2 then
                        AttachTarget(foundObjects[1].ent, 0, {drawable = lastProps[0].drawable, texture = lastProps[0].texture})
                        AttachTarget(foundObjects[2].ent, 1, {drawable = lastProps[1].drawable, texture = lastProps[1].texture})
                        lastProps[0].drawable, lastProps[1].drawable = -1, -1
                    else
                        local slot = droppedSlots[1]
                        AttachTarget(foundObjects[1].ent, slot, {drawable = lastProps[slot].drawable, texture = lastProps[slot].texture})
                        lastProps[slot].drawable = -1
                    end
                end
                for i=0, 1 do lastProps[i].dropped = false end
            end

            cleanupTimer = cleanupTimer + 1
            if cleanupTimer >= 10 then
                if next(assignedEntities) then
                    local pCoords = GetEntityCoords(ped)
                    for ent, info in pairs(assignedEntities) do
                        if DoesEntityExist(ent) then
                            if #(pCoords - GetEntityCoords(ent)) > Config.Settings.CleanupDistance then
                                DeleteEntity(ent)
                                assignedEntities[ent] = nil
                            end
                        else assignedEntities[ent] = nil end
                    end
                end
                cleanupTimer = 0
            end
        end
        Wait(sleep)
    end
end)