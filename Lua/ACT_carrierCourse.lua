cc = {}

cc.carrierName = "boatymcboatface"
cc.windDirection = 0
cc.intoWindDistance = 2000 -- Distance from carrier to new wp into wind in meters

function cc.getWind(vec3)
    local vec3mod = {}
    vec3mod = mist.utils.makeVec3GL ( vec3 )
    vec3mod.y = vec3mod.y + 10
    local windVec3 = {}
    windVec3 = atmosphere.getWind(vec3mod)

    --cc.notify (tostring (vec3mod.x), 5)
    --cc.notify (tostring (vec3mod.y), 5)
    --cc.notify (tostring (vec3mod.z), 5)
    
    --cc.notify ("wind x: " .. windVec3.x, 5)
    --cc.notify ("wind y: " .. windVec3.y, 5)
    --cc.notify ("wind z: " .. windVec3.z, 5)

    --cc.notify("Wind speed: "..mist.vec.mag(windVec3), 5)
    return windVec3
end

function cc.turnIntoWind(groupName)
    local groupVec3 = Group.getByName(groupName):getUnit(1):getPoint()
    local windVec3 = cc.getWind(groupVec3)
    local windmag = mist.vec.mag(windVec3)

    local _intoWindVec3 = mist.utils.makeVec3GL ( 
        mist.vec.add( groupVec3, mist.vec.scalar_mult(windVec3, cc.intoWindDistance / windmag )  )
     )
    
    cc.flareVec3 = _intoWindVec3
    cc.flareVec3 = groupVec3
    cc.smokeVec3 = groupVec3
    cc.smokeVec3 = _intoWindVec3
    
    cc.moveToVec3(groupName, _intoWindVec3)
end

function cc.moveToVec3(groupName, vec3)
	local _groupVec3  = Group.getByName(groupName):getUnit(1):getPosition()
	local _vec3GL = mist.utils.makeVec3GL(vec3)
	local path = {}
	path[#path + 1] = mist.ground.buildWP (_groupVec3)
	path[#path + 1] = mist.ground.buildWP (_vec3GL)
	
	mist.goRoute(groupName, path)

	cc.notify("moveToVec3onRoad func finished", 5)
end

function cc.notify(message, displayFor)
    trigger.action.outText(message, displayFor)
end

function cc.rotateOffset ( radian, offset ) --input degree and radius, rotates the vector and returns a vec3 offset
    local _offset = {
        x = offset,
        y = 0
    }
    local _offset = mist.utils.makeVec3( mist.vec.rotateVec2 ( _offset, radian ) )
    return _offset
end

function cc.getAngle (vec3From, vec3To)
    local _angleR = math.atan2 (vec3To.z - vec3From.z, vec3To.x - vec3From.x)-- - math.atan2 (vec3To.z, vec3To.x)
    if _angleR < 0 then
        _angleR = _angleR + 2 * math.pi
    end
    local _angleD = math.deg (_angleR)
    cc.notify("Angle(r): " .. _angleR .. "; angle(d): " .. _angleD, 5)
    return _angleR
end

function cc.smokeVec3 (vec3)
    local _vec3GL = mist.utils.makeVec3GL(vec3)
    trigger.action.smoke(_vec3GL,3)
end

function cc.flareVec3 (vec3)
    local _vec3GL = mist.utils.makeVec3GL(vec3)
    trigger.action.illuminationBomb(_vec3GL, 1000000)
end

do
    --windDirection = cc.getWind(Group.getByName(cc.carrierName):getUnit(1):getPoint())
    --windDirection = cc.getWind(mist.utils.makeVec3GL (mist.utils.zoneToVec3("zone-1")))

    cc.turnIntoWind(cc.carrierName)



    cc.notify ("carrierCourse loaded", 15)
end