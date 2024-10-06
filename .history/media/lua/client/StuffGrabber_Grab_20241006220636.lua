StuffGrabber = StuffGrabber or {}


function StuffGrabber.getRad()
    return SandboxVars.StuffGrabber.GrabRadius or 4
end

function StuffGrabber.getStuffList()
    return SandboxVars.StuffGrabber.StuffList or  "Base.Katana;Base.Apple;Base.Log"
end
function StuffGrabber.parseList()
    local items = {}
    local strList = StuffGrabber.getStuffList()
    for item in string.gmatch(strList, "[^;]+") do
        table.insert(items, item)
    end
    return items
end

function StuffGrabber.isAlwaysShowOption()
    return
end
function StuffGrabber.context(player, context, worldobjects, test)
	local pl = getSpecificPlayer(player)
	local dropPoint = clickedSquare
    local nearbyStuff = false
    local ico = nil
    local isAlwaysShowOption = StuffGrabber.isAlwaysShowOption()
	if dropPoint then
		local Main = context:addOptionOnTop("Gather: ")
		Main.iconTexture = getTexture("media/ui/emotes/autowalk_on.png")
		local opt = ISContextMenu:getNew(context)
		context:addSubMenu(Main, opt)

        local stuff = StuffGrabber.parseList()

        for _, toGrab in ipairs(stuff) do

            local ref = getScriptManager():FindItem(toGrab)
            if ref then
                ico = ref:getIcon()
            end

            local grabOpt = opt:addOption(tostring(toGrab), worldobjects, function()
                StuffGrabber.func(toGrab, dropPoint)
            end)
            if ico then
                grabOpt.iconTexture = getTexture(ico)
            end
            if not isAlwaysShowOption then
                nearbyStuff = nearbyStuff or not grabOpt.notAvailable
                if not StuffGrabber.isCanGrab(toGrab, dropPoint) then
                    grabOpt.notAvailable = true
                end
            end
        end
        if not isAlwaysShowOption then
            if not nearbyStuff then
                context:removeOptionByName("Gather: ")
            end
        end
	end
end
Events.OnFillWorldObjectContextMenu.Remove(StuffGrabber.context)
Events.OnFillWorldObjectContextMenu.Add(StuffGrabber.context)


function StuffGrabber.isCanGrab(toGrab, dropPoint)
    local rad = StuffGrabber.getRad()
    local pl = getPlayer()
    local stuff = {}
    local cell = pl:getCell()
    local x, y, z = dropPoint:getX(), dropPoint:getY(), dropPoint:getZ()
    local count = 0
    for xDelta = -rad, rad do
        for yDelta = -rad, rad do
            local targSq = cell:getOrCreateGridSquare(x + xDelta, y + yDelta, z)
            for i = 0, targSq:getObjects():size() - 1 do
                local item = targSq:getObjects():get(i)
                if instanceof(item, "IsoWorldInventoryObject") then
                    local name = item:getItem():getFullType()
                    if name and name == toGrab then
                        return true
                    end
                end
            end
        end
    end
    return false
end



function StuffGrabber.func(toGrab, dropPoint)
    local rad = StuffGrabber.getRad()
    local pl = getPlayer()
    local inv = pl:getInventory()


    local cell = pl:getCell()
    local x, y, z = dropPoint:getX(), dropPoint:getY(), dropPoint:getZ()


    local maxWeight = pl:getMaxWeight()
    local currentWeight = inv:getCapacityWeight()
    local totalItemWeight = 0
    local itemsToGrab = {}

    local canPickupCount = 0
    local count = 0
    for xDelta = -rad, rad do
        for yDelta = -rad, rad do
            local targSq = cell:getOrCreateGridSquare(x + xDelta, y + yDelta, z)
            for i = 0, targSq:getObjects():size() - 1 do
                local item = targSq:getObjects():get(i)
                if instanceof(item, "IsoWorldInventoryObject") then
                    local name = item:getItem():getFullType()
                    if name and name == toGrab then
                        local itemWeight = item:getItem():getActualWeight()
                        totalItemWeight = totalItemWeight + itemWeight
                        count = count + 1
                        if (currentWeight + totalItemWeight) <= maxWeight or pl:isUnlimitedCarry() then
                            canPickupCount = canPickupCount + 1
                            table.insert(itemsToGrab, item)
                        end
                    end
                end
            end
        end
    end

    for _, item in ipairs(itemsToGrab) do
        local targSq = item:getSquare()
        ISTimedActionQueue.add(ISWalkToTimedAction:new(pl, targSq))
        local time = ISWorldObjectContextMenu.grabItemTime(pl, item)
        ISTimedActionQueue.add(ISGrabItemAction:new(pl, item, time))
    end

    if getCore():getDebug() then
        local msg = 'Grabbing [ '..tostring(canPickupCount)..' / '..tostring(count)..' ] '.. tostring(toGrab)
        pl:setHaloNote(tostring(msg),150,250,150,900)
        print(msg)
    end
    ISTimedActionQueue.add(DropItemsToDestSquare:new(pl, dropPoint, toGrab))
    ISInventoryPage.renderDirty = true
end
