

function ResourceDepot.initialize()
    local station = Entity()

    if station.title == "" then
        station.title = "Resource Depot"%_t
    end

    for i = 1, NumMaterials() do
        sellPrice[i] = 10 * Material(i - 1).costFactor
        buyPrice[i] = 10 * Material(i - 1).costFactor
    end

    if onServer() then
        math.randomseed(Sector().seed + Sector().numEntities)

        -- best buy price: 1 iron for 10 credits
        -- best sell price: 1 iron for 10 credits
        stock = ResourceDepot.getInitialResources()

        -- resource shortage
        shortageTimer = -random():getInt(15 * 60, 60 * 60)

        local faction = Faction()
        if faction and faction.isAIFaction then
            Sector():registerCallback("onRestoredFromDisk", "onRestoredFromDisk")
        end

        if station.type == EntityType.Station then
            local isplayerbuild = Faction().isPlayer or Faction().isAlliance

            local x,y = Sector():getCoordinates()

            local sx, sy = Player(1):getHomeSectorCoordinates()
            local isInStartsector = false
            if x == sx and y == sy then
                isInStartsector = true
            end

            local hx, hy = faction:getHomeSectorCoordinates()
            local isInFactionhome = false
            if x == hx and y == hy then
                isInFactionhome = true
            end

            if isplayerbuild or isInStartsector or isInFactionhome then
                station:addScriptOnce("data/scripts/entity/merchants/refinery.lua")
            else
                math.randomseed(Sector().seed)
                if  math.random(0,4) == 1 then --1 in 5
                    station.title = "Resource Depot & Refining"%_t
                    station:addScriptOnce("data/scripts/entity/merchants/refinery.lua")
                else

                    station:removeScript("data/scripts/entity/merchants/refinery.lua")
                end
            end
        end
    end

    -- reset random
    math.randomseed(appTimeMs())
    if onClient() then
        if station.title == "Resource Depot & Refining"%_t then
            EntityIcon().icon = "data/textures/icons/pixel/combined-refining.png"
        else
            EntityIcon().icon = "data/textures/icons/pixel/resources.png"
        end
        InteractionText(station.index).text = Dialog.generateStationInteractionText(station, random())
    end

end


-- shortages are broken, so better deactivate them
function ResourceDepot.updateServer(timeStep)

end
