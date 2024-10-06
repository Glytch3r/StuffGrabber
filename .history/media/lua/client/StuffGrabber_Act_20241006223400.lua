
require "TimedActions/ISBaseTimedAction"

DropItemsToDestSquare = ISBaseTimedAction:derive("DropItemsToDestSquare");

function DropItemsToDestSquare:isValid()
	if self.character:getVehicle() then return false end
    return getGameSpeed() <= 2;
end

function DropItemsToDestSquare:update()

    if instanceof(self.character, "IsoPlayer") and
            (self.character:pressedMovement(false) or self.character:pressedCancelAction()) then
        self:forceStop()
        return
    end

    self.result = self.character:getPathFindBehavior2():update();

    if self.result == BehaviorResult.Failed then
        self:forceStop();
        return;
    end

    if self.result == BehaviorResult.Succeeded then
        self:forceComplete();
    end
end
function DropItemsToDestSquare:waitToStart()
	self.character:getPathFindBehavior2():pathToLocation(self.location:getX(), self.location:getY(), self.location:getZ());
end

function DropItemsToDestSquare:start()


	self:setActionAnim("Loot")
	self.character:SetVariable("LootPosition", "Low")
	self:setOverrideHandModels(nil, nil)
	self.character:reportEvent("EventLootItem");

end

function DropItemsToDestSquare:stop()
    ISBaseTimedAction.stop(self);
	self.character:getPathFindBehavior2():cancel()
    self.character:setPath2(nil);
end

function DropItemsToDestSquare:perform()
	self.character:getPathFindBehavior2():cancel()
    self.character:setPath2(nil);



    ISBaseTimedAction.perform(self);

    if self.onCompleteFunc then
        local args = self.onCompleteArgs
        self.onCompleteFunc(args[1], args[2], args[3], args[4])
    end


    self:DropLogs(self.character, self.location, self.toDrop)
end

function DropItemsToDestSquare:setOnComplete(func, arg1, arg2, arg3, arg4)
    self.onCompleteFunc = func
    self.onCompleteArgs = { arg1, arg2, arg3, arg4 }
end

function DropItemsToDestSquare:new(character, location, toDrop)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character;
    o.toDrop = toDrop
    o.stopOnWalk = false;
    o.stopOnRun = false;
    o.maxTime = -1;
    o.location = location;
    o.pathIndex = 0;

    return o
end

function DropItemsToDestSquare:DropLogs(pl, dest, toDrop) -- self:DropLogs()

    local count = 0
    local inv = pl:getInventory()

    if inv:contains(toDrop) then
        local itemsToDrop = {}
        for i = 1, inv:getItems():size() do
            local item = inv:getItems():get(i - 1)
            if item and item:getFullType() == toDrop then
                table.insert(itemsToDrop, item)
            end
        end

        for _, item in ipairs(itemsToDrop) do
            count = count + 1


            ISTimedActionQueue.add(ISDropWorldItemAction:new(pl, item, pl:getCurrentSquare(), 0, 0, 0, 0, true))
        end
        print('dropped: '..tostring(count))
        ISInventoryPage.renderDirty = true
    end
end
