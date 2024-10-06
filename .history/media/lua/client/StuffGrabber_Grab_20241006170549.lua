StuffGrabber = StuffGrabber or {}

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

function StuffGrabber.context(player, context, worldobjects, test)
	local pl = getSpecificPlayer(player)
	local sq = clickedSquare
	local targ = clickedPlayer
	if sq then
		local Main = context:addOptionOnTop("StuffGrabber: ")
		Main.iconTexture = getTexture("media/ui/chop_tree.png")
		local opt = ISContextMenu:getNew(context)
		context:addSubMenu(Main, opt)
		local optTip = opt:addOption('stuff', worldobjects, function()
			context:hideAndChildren()
		end)
		local tip = ISWorldObjectContextMenu.addToolTip()
		tip.description = ""
		optTip.toolTip:setName(Main:getName())
		optTip.toolTip = tip
		optTip.notAvailable = true
	end
end
Events.OnFillWorldObjectContextMenu.Remove(StuffGrabber.context)
Events.OnFillWorldObjectContextMenu.Add(StuffGrabber.context)

function StuffGrabber.func(toGrab)
    local rad = SandboxVars.StuffGrabber.GrabRadius or 4
    local pl = getPlayer()
    local stuff = {}
    local cell = pl:getCell()
    local x, y, z = pl:getX(), pl:getY(), pl:getZ() -- Starting location
    local csq = pl:getCurrentSquare() -- Player's starting square
    local inv = pl:getInventory()
    local count = 0

    for xDelta = -rad, rad do
        for yDelta = -rad, rad do
            local targSq = cell:getOrCreateGridSquare(x + xDelta, y + yDelta, z)
            for i = 0, targSq:getObjects():size() - 1 do
                local item = targSq:getObjects():get(i)
                if instanceof(item, "IsoWorldInventoryObject") then
                    local name = item:getName()
                    if name and name == 'Log' then
                        ISTimedActionQueue.add(ISWalkToTimedAction:new(pl, targSq))
                        local time = ISWorldObjectContextMenu.grabItemTime(pl, item)
                        ISTimedActionQueue.add(ISGrabItemAction:new(pl, item, time))
                    end
                end
            end
        end
    end
    ISTimedActionQueue.add(StuffGrabber_Act:new(pl, csq))
end
