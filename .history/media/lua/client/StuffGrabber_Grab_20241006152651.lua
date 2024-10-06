
local rad = 15 --SandboxVars.StuffGrabber.radius or 15
local pl = getPlayer()
local csq = pl:getCurrentSquare()
local stuff = {}
local cell = pl:getCell()
local x, y, z = pl:getX(), pl:getY(), pl:getZ()
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
local pl = getPlayer()
local csq = pl:getCurrentSquare()
ISTimedActionQueue.add(DropItemsToDestSquare:new(pl, csq))



function ISWalkToTimedAction:perform()
    local itemCount = 0
    for i = 1, count  do
        local item = inv:FindAndReturn('Base.Log')
        if item then
            ISTimedActionQueue.add(ISInventoryTransferAction:new(pl, item, item:getContainer(), ISInventoryPage.floorContainer[pl:getPlayerNum() + 1]))
        end
    end
    self.character:getPathFindBehavior2():cancel()
    self.character:setPath2(nil);
    ISBaseTimedAction.perform(self);
    if self.onCompleteFunc then
        local args = self.onCompleteArgs
        self.onCompleteFunc(args[1], args[2], args[3], args[4])
    end
end




revert()









function getFloorContainer(sq)
    if sq then
        local world = sq:getWorldObjects()
        for i=0, world:size()-1 do
            local obj = world:get(i)
            local cont = obj:getContainer()
            if cont then
                local contType = cont:getType()
                if contType == "floor" then
                    return cont
                end
            end
        end
    end
    return nil
end












local rad = 15 --SandboxVars.StuffGrabber.radius or 15
local pl = getPlayer()
local stuff = {}
local cell = pl:getCell()
local x, y, z = pl:getX(), pl:getY(), pl:getZ() -- Starting location
local csq = pl:getCurrentSquare() -- Player's starting square
local inv = pl:getInventory()
local count = 0
local time = 0
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


                    --ISTimedActionQueue.add(ISDropItemAction:new(pl, item))
               --[[      table.insert(stuff, item:getItem())
                    count = count + 1 ]]
                end
            end
        end
    end
end
ISTimedActionQueue.add(ISWalkToTimedAction:new(pl, csq))


           ISTimedActionQueue.add(ISDropItemAction:new(pl, item))
-- Queue the walk back to the starting location
ISTimedActionQueue.add(ISWalkToTimedAction:new(pl, csq))

-- After walking back, drop all the logs
for _, log in ipairs(stuff) do
    ISTimedActionQueue.add(ISDropItemAction:new(pl, log))
end

local player = getPlayer() -- Get the player object
local square = player:getCurrentSquare() -- Get the current square the player is standing on

-----------------------            ---------------------------


StuffGrabber = StuffGrabber or {}
function StuffGrabber.act()
    local rad = 15 --SandboxVars.StuffGrabber.radius or 15
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
                    local name = item:getName()
                    if name and name == 'Log' then
                        ISTimedActionQueue.add(ISWalkToTimedAction:new(pl, targSq))
                        local time = ISWorldObjectContextMenu.grabItemTime(pl, item)
                        ISTimedActionQueue.add(ISGrabItemAction:new(pl, item, time))
                        table.insert(stuff, item:getItem())
                        count = count + 1
                    end
                end
            end
        end
    end
    --ISTimedActionQueue.add(ISWalkToTimedAction:new(pl, csq))
    ISTimedActionQueue.add(DropItemsToDestSquare:new(pl, csq))

end

StuffGrabber.act()



-----------------------            ---------------------------
        Events.OnTick.Remove()
    end
end
Events.OnTick.Remove()
Events.OnTick.Add()