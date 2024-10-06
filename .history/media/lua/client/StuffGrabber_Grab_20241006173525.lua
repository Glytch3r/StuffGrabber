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



function StuffGrabber.isCanGrab(toGrab)
    local rad = StuffGrabber.getRad()
    local pl = getPlayer()
    local stuff = {}
    local cell = pl:getCell()
    local x, y, z = pl:getX(), pl:getY(), pl:getZ()
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




function StuffGrabber.context(player, context, worldobjects, test)
	local pl = getSpecificPlayer(player)
	local sq = clickedSquare
	local targ = clickedPlayer
    local nearbyStuff = false
	if sq then

		local Main = context:addOptionOnTop("Gather: ")
		Main.iconTexture = getTexture("media/ui/emotes/autowalk_on.png")
		local opt = ISContextMenu:getNew(context)
		context:addSubMenu(Main, opt)

        local stuff = StuffGrabber.parseList()

        for _, toGrab in ipairs(stuff) do
            local grabOpt = opt:addOption(tostring(toGrab), worldobjects, function()
                StuffGrabber.func(toGrab)
            end)
            nearbyStuff = true
            if not StuffGrabber.isCanGrab(toGrab) then
                grabOpt.notAvailable = true
            end
        end

        if not nearbyStuff then
            context:removeOptionByName(getText("Gather: "))
        end

	end
end
Events.OnFillWorldObjectContextMenu.Remove(StuffGrabber.context)
Events.OnFillWorldObjectContextMenu.Add(StuffGrabber.context)

function StuffGrabber.func(toGrab)
    local rad = StuffGrabber.getRad()
    local pl = getPlayer()
    local stuff = {}
    local cell = pl:getCell()
    local x, y, z = pl:getX(), pl:getY(), pl:getZ()
    local csq = pl:getCurrentSquare()
    local inv = pl:getInventory()
    local count = 0

    for xDelta = -rad, rad do
        for yDelta = -rad, rad do
            local targSq = cell:getOrCreateGridSquare(x + xDelta, y + yDelta, z)
            for i = 0, targSq:getObjects():size() - 1 do
                local item = targSq:getObjects():get(i)
                if instanceof(item, "IsoWorldInventoryObject") then
                    local name = item:getItem():getFullType()
                    if name and name == toGrab then
                        ISTimedActionQueue.add(ISWalkToTimedAction:new(pl, targSq))
                        local time = ISWorldObjectContextMenu.grabItemTime(pl, item)
                        ISTimedActionQueue.add(ISGrabItemAction:new(pl, item, time))
                        count = count + 1
                    end
                end
            end
        end
    end
    if getCore():getDebug() then
        local msg = 'Grabbed a '.. tostring(toGrab)
        if count > 1 then
            msg = 'Grabbed '..tostring(count)..' '.. tostring(toGrab)..'s'
        end
        pl:setHaloNote(tostring(msg),150,250,150,900)
        print(msg)
    end
    ISInventoryPage.renderDirty = true

    ISTimedActionQueue.add(StuffGrabber_Act:new(pl, csq, toGrab))
end
