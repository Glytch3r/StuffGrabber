
StuffGrabber = StuffGrabber or {}

function StuffGrabber.isFirearm(pl, wpn)
	if not wpn then return false end
	if wpn:isAimedFirearm() then return true end
	if tostring(WeaponType.getWeaponType(pl)) == "barehand" or (wpn and wpn:getCategories():contains("Unarmed")) then return false end
	return wpn:getScriptItem() and wpn:getScriptItem():isRanged()
end

function StuffGrabber.doDrop(pl)
	local pr = pl:getPrimaryHandItem()
	if not pr then return end
	if tostring(WeaponType.getWeaponType(pl)) == 'barehand' or  pr:getCategories():contains("Unarmed") then return end
	pl:fallenOnKnees()
end


function StuffGrabber.getRandPart(pl)
	return pl:getBodyDamage():getBodyPart(BodyPartType.FromIndex(ZombRand(BodyPartType.ToIndex(BodyPartType.MAX))));
end




-----------------------            ---------------------------

function StuffGrabber.getCar()
	local car = nil;
	local pl = getPlayer();
	if pl:getVehicle() then
		car = pl:getVehicle();
	elseif pl:getNearVehicle() then
		car = pl:getNearVehicle();
	elseif pl:getUseableVehicle() then
		car = pl:getUseableVehicle();
	end
	return car
end
-----------------------            ---------------------------

function StuffGrabber.doRoll(percent) if percent >= ZombRand(1, 101) then return true end return false end
-----------------------            ---------------------------
function StuffGrabber.checkDist(pl, zed)
	local dist = pl:DistTo(zed:getX(), zed:getY())
    return math.floor(dist)
end

function StuffGrabber.isWithinRange(pl, zed, range)
	local dist = pl:DistTo(zed:getX(), zed:getY())
    return dist <= range
end

function StuffGrabber.isClosestPl(pl, zed)
	if not StuffGrabber.isStuffGrabber(zed) then return end
	local plDist = StuffGrabber.checkDist(pl, zed)
	local compare = round(zed:distToNearestCamCharacter())
	if plDist == compare then
		return true
	end
	return false
end
-----------------------            ---------------------------
function StuffGrabber.getCol(int)
    local defaultColor = { r=1, g=1, b=1 }
    if not int then return defaultColor end

    local colors = {

        [1] = { r=1, g=0, b=0 },     -- Red
        [2] = { r=1, g=0.5, b=0 },   -- Orange
        [3] = { r=1, g=1, b=0 },     -- Yellow
        [4] = { r=0, g=1, b=0 },     -- Green
        [5] = { r=0, g=0, b=1 },     -- Blue
        [6] = { r=0.29, g=0, b=0.51 }, -- Indigo
        [7] = { r=0.56, g=0, b=1 },  -- Violet
        [8] = { r=1, g=1, b=1 },      -- White
        [9] = { r=0, g=0, b=0 },     -- Black
    }

    return colors[int] or defaultColor
end
