PhysicsDebugDraw = class()
    
function PhysicsDebugDraw:init()
    self.drawer = ShapeDrawer()
    self.bodies = {}
    self.joints = {}
    self.touchMap = {}
    self.contacts = {}
    self.stacks = {}
    parameter.action("List DebugDraw bodies", function()
        print("debugDraw keys/identifiers: "..self:bodiesList())
    end)
    parameter.boolean("screenReport", false)
end

function PhysicsDebugDraw:addBody(body)
    for i, thisBody in ipairs(self.bodies) do
        if thisBody == body then
            return
        end
    end
    self.bodies[#self.bodies+1] = body
end

function PhysicsDebugDraw:bodiesList()
    local cardsString = ""
    for key, body in pairs(self.bodies) do
        local identifier = body.shortName or body
        cardsString = cardsString.."["..tostring(key).."]:"..tostring(identifier).."   "
    end
    return cardsString
end

function PhysicsDebugDraw:removeBody(removeMe)
        remove(self.bodies, removeMe)
end

function PhysicsDebugDraw:removeAndDestroyThoughYouStillGottaNilManually(obliterateMe)
    self:removeBody(obliterateMe)
    obliterateMe:destroy()
end

function PhysicsDebugDraw:hasBody(verifyMe)
    local validKeys = {}
    for key, value in pairs(self.bodies) do
        validKeys[value] = true
    end
    if validKeys[verifyMe] then
        return true, verifyMe
    else
        return false
    end
end

function PhysicsDebugDraw:addTouchToTouchMap(touch, body)
    local touchPoint = vec2(touch.pos.x, touch.pos.y)
    local touchAnchor = body:getLocalPoint(touchPoint)
    local centerAnchor = vec2(0,0)
    self.touchMap[touch.id] = {
        tp = touchPoint, body = body, anchor = touchAnchor, 
        stack = {body}, state = touch.state}
end

function PhysicsDebugDraw:addJoint(joint)
    table.insert(self.joints,joint)
end

function PhysicsDebugDraw:clear()
    for i,body in ipairs(self.bodies) do
        body:destroy()
    end    
    for i,joint in ipairs(self.joints) do
        joint:destroy()
    end  
    self.bodies = {}
    self.joints = {}
    self.contacts = {}
    self.touchMap = {}
end

function PhysicsDebugDraw:draw()   
    local shouldDraw = true
    if shouldDraw then
        self.drawer:drawDebugging(self, screenReport, shouldDraw)
    end    
    for touchId, mappedTouch in pairs(self.touchMap) do
        --print("tracking "..touchId)
        local gain = 100 --affects how far cards go when flung
        local damp = 8 --affects how quickly they slow down
        local topCardCenter = mappedTouch.body:getWorldPoint(vec2(0, 0))
        local worldAnchor = mappedTouch.body:getWorldPoint(mappedTouch.anchor) --where the point the body was first touched is now in world coordinates
        local touchPoint = mappedTouch.tp --where the actual touch is now
        local diff = (touchPoint - worldAnchor) * 10 --result is vec2
        local vel = mappedTouch.body:getLinearVelocityFromWorldPoint(worldAnchor) --??
        --v.body:applyForce( (1/1) * diff * gain - vel * damp, worldAnchor)
        mappedTouch.body:applyForce( (1/1) * diff * gain - vel * damp, worldAnchor) --shove the body
        line(touchPoint.x, touchPoint.y, worldAnchor.x, worldAnchor.y)
        --set a slightly different force to give any cards following this touch
        gain =  90
        damp =  7
        --get main body angle as modulo of 360
        local bodyAngleMod = mappedTouch.body.angle % 360
        --figure out if or how to push each of the other cards
        for i, thisBody in ipairs(mappedTouch.stack) do
            if i ~= 1 then                
                --shove the followers to follow the lead card?
                if mappedTouch.state == ENDED or mappedTouch.state == CANCELLED then
                else
                    local thisAngleMod = thisBody.angle % 360
                    local diff = ((thisAngleMod - bodyAngleMod) % 360) 
                    local absDiff = math.floor(math.abs(diff))
                    if absDiff > 180 then absDiff = 180 - absDiff end
                    if math.abs(absDiff) > 4 then
                        local nextAngle = thisAngleMod + (thisBody.angularVelocity / 3)
                        local totalRotation 
                        if diff > 0 then
                            totalRotation = bodyAngleMod - nextAngle
                        else
                            totalRotation = nextAngle - bodyAngleMod
                        end
                        local torque = 1000
                        if totalRotation < 0 then torque = torque * -1 end
                        thisBody:applyTorque(torque)      
                    end
                    local thisBodyWorldCenter = thisBody:getWorldPoint(vec2(0,0))
                    vel = thisBody:getLinearVelocityFromWorldPoint(topCardCenter)
                    diff = (topCardCenter - thisBodyWorldCenter) * 10
                   -- thisBody:applyForce( (1/1) * diff * gain - vel * damp, thisBody:getWorldPoint(vec2(0,0)))--shove the body 
                end
            end
        end 
    end 
end 

function PhysicsDebugDraw:touched(touch)
    --grab the touch as a vec2
    local touchPoint = vec2(touch.pos.x, touch.pos.y)
    local firstBodyTouched
    local returnValue = false
    --when a touch starts on a dynamic body, log it in touchMap
    if touch.state == BEGAN then
        --count backwards through bodies
        for i=#self.bodies, 1, -1 do
            --check if body belongs to a card
            local body = self.bodies[i]
            if body.owningClass == "card" then 
                --check if touch is indside body
                if body.type == DYNAMIC and body:testPoint(touchPoint) then
                    --create touchMap for touch
                    self:addTouchToTouchMap(touch, body)
                    --move body to end of bodies
                    table.remove(self.bodies, i)
                    table.insert(self.bodies, body)
                    --set flag to send this touch to the table
                    returnValue = true
                    firstBodyTouched = body
                    --send body stack to stacker
                    cardTable.stacker:forceStackFromBodies(self.touchMap[touch.id].stack)
                    break
                end
            end
        end
    elseif touch.state == MOVING and self.touchMap[touch.id] then
        shouldReport = true
        --  print("moving touchmap: "..self.touchMap[touch.id].body.shortName)
        self.touchMap[touch.id].tp = touchPoint
        self.touchMap[touch.id].state = touch.state
        for _,body in ipairs(self.bodies) do
            if body.owningClass == "card" then
                --print("moving, ",body.shortName, body.owningClass)
                --make sure this touch is actually inside this body and this body isn't a leading body
                if body.type == DYNAMIC and body:testPoint(touchPoint) and body ~= self.touchMap[touch.id].body then
                    --exclude any subsequent body that the previous touch was *inside*
                    if not body:testPoint(touch.prevPos) and not tableHas(self.touchMap[touch.id].stack, body) then
                        --add this body to the stack
                        table.insert(self.touchMap[touch.id].stack, body)
                        --send body stack to stacker
                        cardTable.stacker:forceStackFromBodies(self.touchMap[touch.id].stack)
                        --make a distance joint to draw it in
                        body.puller = physics.joint(DISTANCE, body, self.touchMap[touch.id].body, body:getWorldPoint(vec2(0,0)), self.touchMap[touch.id].body:getWorldPoint(vec2(0,0)))
                        body.puller.length = 0
                    end
                end
            end
        end
        shouldReport = false
        returnValue = true
        --delete any touchMap for an end touch
    elseif (touch.state == ENDED or touch.state == CANCELLED) and self.touchMap[touch.id] then
        self.touchMap[touch.id].state = touch.state
        if self.touchMap[touch.id].body:testPoint(touchPoint) then
            firstBodyTouched = self.touchMap[touch.id].body
        end
        self.touchMap[touch.id] = nil
        returnValue = true
    end   
    if(returnValue == true) then
        cardTable:touched(touch, self.bodies, firstBodyTouched)
    end
    return returnValue
end

function PhysicsDebugDraw:collide(contact)
    if contact.state == BEGAN then
        self.contacts[contact.id] = contact
        -- sound(SOUND_HIT, 2643)
    elseif contact.state == MOVING then
        self.contacts[contact.id] = contact
    elseif contact.state == ENDED then
        self.contacts[contact.id] = nil
    end
end
