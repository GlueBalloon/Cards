

PhysicsDebugDraw = class()

function PhysicsDebugDraw:init()
    self.bodies = {}
    self.joints = {}
    self.touchMap = {}
    self.contacts = {}
    self.stacks = {}
    self.touchMapFunctions = {jankyTouch}
    parameter.action("List DebugDraw bodies", function()
        local cardsString = ""
        for key, body in pairs(self.bodies) do
            local identifier = body.shortName or body
            cardsString = cardsString.."["..tostring(key).."]:"..tostring(identifier).."   "
        end
        print("debugDraw keys/identifiers: "..cardsString)
    end)
end

function PhysicsDebugDraw:addBody(body)
    -- print("adding"..body.shortName)
    self.bodies[#self.bodies+1] = body
    --table.insert(self.bodies, body)
end

function PhysicsDebugDraw:listCards()
    local namesString = ""
    for i=1, #self.bodies do
        if self.bodies[i].shortName then
            namesString = namesString..self.bodies[i].shortName..". "
        end
    end
    print(namesString)
end

function PhysicsDebugDraw:removeBody(removeMe)
    -- print("PhysicsDebugDraw:removeBody: iterating")
    for i, iBody in ipairs(self.bodies) do
        --    print("\tbody: "..tostring(iBody))
        if iBody == removeMe then
            local isNamed = false
            if removeMe.shortName then
                isNamed = true
            end
            --print("PhysicsDebugDraw:removeBody: body found: "..tostring(iBody.info.kind))
            if isNamed then
                -- print("PhysicsDebugDraw:removeBody: found card: "..removeMe.info.kind)
                -- print("\tremoved: "..table.remove(self.bodies, i).shortName..", object at index "..tostring(i)..": "..self.bodies[i].shortName)
            end
            -- print("PhysicsDebugDraw:removeBody: found body")
            remove(self.bodies, iBody)
            return
        end
    end
end

function PhysicsDebugDraw:hasBody(verifyMe)
    -- print("PhysicsDebugDraw:hasBody: iterating")
    local validKeys = {}
    for key, value in pairs(self.bodies) do
        validKeys[value] = true
    end
    if validKeys[verifyMe] then
        --[[
        if verifyMe.info and verifyMe.info.ownerClass and verifyMe.info.ownerClass == "card" then
        print("PhysicsDebugDraw:hasBody: found card: "..verifyMe.info.kind)
        end
        ]]
        return true, verifyMe
    else
        return false
    end
end

function PhysicsDebugDraw:addTouchToTouchMap(touch, body)
    local touchPoint = vec2(touch.pos.x, touch.pos.y)
    local touchAnchor = body:getLocalPoint(touchPoint)
    local centerAnchor = vec2(0,0)
    self.touchMap[touch.id] = {tp = touchPoint, body = body, anchor = centerAnchor, followers = {}}
end

function PhysicsDebugDraw:addJoint(joint)
    table.insert(self.joints,joint)
end

function PhysicsDebugDraw:clear()
    -- deactivate all bodies
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
        pushStyle()
        smooth()
        strokeWidth(5)
        stroke(128,0,128) -- purple
    end
    
    --[[
    --why is the physics part of this in draw()?
    --solve this by killing the touchMap if a touch reverses direction?
    for touchId, mappedTouch in pairs(self.touchMap) do
        --print("tracking "..touchId)
        local gain = 100 --affects how far blocks go when flung
        local damp = 8 --affects how quickly they slow down
        local worldAnchor = mappedTouch.body:getWorldPoint(mappedTouch.anchor) --where the point the body was first touched is now in world coordinates
        local touchPoint = mappedTouch.tp --where the actual touch is now
        local diff = touchPoint - worldAnchor --distance as vec2
        local vel = mappedTouch.body:getLinearVelocityFromWorldPoint(worldAnchor) --??
        --v.body:applyForce( (1/1) * diff * gain - vel * damp, worldAnchor)
        mappedTouch.body:applyForce( (1/1) * diff * gain - vel * damp, worldAnchor) --shove the body
        line(touchPoint.x, touchPoint.y, worldAnchor.x, worldAnchor.y)
        --apply a slightly different force to any cards following this touch
        gain =  90
        damp =  7
        for _, body in ipairs(mappedTouch.followers) do
            local angleDiff = body.angle - mappedTouch.body.angle
            if angleDiff > 10 then
                body:applyTorque(math.random(-840,-800))
            elseif angleDiff < -10 then
                body:applyTorque(math.random(800, 840))
            end
            worldAnchor = body:getWorldPoint(vec2(0,0)) --the center of the body in world coordinates
            vel = body:getLinearVelocityFromWorldPoint(worldAnchor)
            diff = touchPoint - worldAnchor
            --print("follower is: "..body.shortName)
            -- body.x, body.y, body.angle = mappedTouch.body.x, mappedTouch.body.y, mappedTouch.body.angle
            body:applyForce( (1/1) * diff * gain - vel * damp, body:getWorldPoint(vec2(0,0))) --shove the body
        end
        
    end
    ]]
    
    for _, func in pairs(self.touchMapFunctions) do
        func(self.touchMap)
    end
    
    if shouldDraw then
        
        stroke(0,255,0,255)
        strokeWidth(5)
        for k,joint in pairs(self.joints) do
            local a = joint.anchorA
            local b = joint.anchorB
            line(a.x,a.y,b.x,b.y)
        end
        
        stroke(255,255,255,255)
        noFill()
        
        
        
        
        for i,body in ipairs(self.bodies) do
            pushMatrix()
            
            
            --[[
            print("----")
            print(body.position)
            print(body)
            print(body.shortName)
            ]]
            
            --local transAndRot = function()
            translate(body.x, body.y)
            rotate(body.angle)
            --    end
            
            if body.type == STATIC then
                stroke(255,255,255,255)
            elseif body.type == DYNAMIC then
                stroke(150,255,150,255)
            elseif body.type == KINEMATIC then
                stroke(150,150,255,255)
            end
            
            if body.shapeType == POLYGON then
                strokeWidth(3.0)
                local points = body.points
                for j = 1,#points do
                    a = points[j]
                    b = points[(j % #points)+1]
                    line(a.x, a.y, b.x, b.y)
                end
            elseif body.shapeType == CHAIN or body.shapeType == EDGE then
                strokeWidth(3.0)
                local points = body.points
                for j = 1,#points-1 do
                    a = points[j]
                    b = points[j+1]
                    line(a.x, a.y, b.x, b.y)
                end
            elseif body.shapeType == CIRCLE then
                strokeWidth(3.0)
                line(0,0,body.radius-3,0)
                ellipse(0,0,body.radius*2)
            end
            
            popMatrix()
        end
    end
    
    
    
    stroke(255, 0, 0, 255)
    fill(255, 0, 0, 255)
    
    for k,v in pairs(self.contacts) do
        for m,n in ipairs(v.points) do
            ellipse(n.x, n.y, 10, 10)
        end
    end
    
    popStyle()
end

function PhysicsDebugDraw:touched(touch)
    --print("PDD touched")
    --grab the touch as a vec2
    local touchPoint = vec2(touch.pos.x, touch.pos.y)
    local firstBodyTouched
    local returnValue = false
    --print("PDD set touchPoint")
    --when a touch starts on a dynamic body, log it in touchMap
    if touch.state == BEGAN then
        --    print("PDD detected beginning touch")
        --[[
        for i,body in ipairs(self.bodies) do
        if body.type == DYNAMIC and body:testPoint(touchPoint) then
        self.touchMap[touch.id] = {tp = touchPoint, body = body, anchor = body:getLocalPoint(touchPoint)}
        returnValue = true
        end
        end
        ]]
        --  for _,body in ipairs(self.bodies) do
        for i=#self.bodies, 1, -1 do
            local body = self.bodies[i]
            if body.type == DYNAMIC and body:testPoint(touchPoint) then
                -- self.touchMap[touch.id] = {tp = touchPoint, body = body, anchor = body:getLocalPoint(touchPoint)}
                --i think this is adding the same table forvthe same id key 52 times...
                self:addTouchToTouchMap(touch, body)
                table.remove(self.bodies, i)
                table.insert(self.bodies, body)
                --maybe not now?
                returnValue = true
                firstBodyTouched = body
                break
            end
        end
    elseif touch.state == MOVING and self.touchMap[touch.id] then
        self.touchMap[touch.id].tp = touchPoint
        if CodeaUnit.isRunning then
            print("touchPoint: "..tostring(touchPoint))
        end
        for _,body in ipairs(self.bodies) do
            --make sure this touch is actually inside this body and this body isn't a leading body
            if body.type == DYNAMIC and body:testPoint(touchPoint) and body ~= self.touchMap[touch.id].body then
                --exclude any subsequent body that the previous touch was *inside*
                if not body:testPoint(touch.prevPos) then
                    if CodeaUnit.isRunning then
                        print ("body: "..tostring(body))
                        print ("touchPoint: "..tostring(touchPoint))
                        print ("result: "..tostring(body:testPoint(touchPoint)))
                    end
                    --add this body to the followers
                    table.insert(self.touchMap[touch.id].followers, body)
                    --figure out the stack situation
                    local stackExists = false
                    --look for a stack whose first body is the main body of this touchMap
                    for i, stack in ipairs(self.stacks) do
                        --if it's found, add this body to it
                        if stack[1] == self.touchMap[touch.id].body then
                            table.insert(stack, body)
                            stackExists = true
                            break
                        end
                    end
                    --if not, make a new stack and populate it
                    if not stackExists then
                        local newStack = {self.touchMap[touch.id].body, body}
                        local badgeSize = cardTable.cardsWithBodiesAsKeys[body].width * 0.09
                        newStack.badge = createCircle(500,500,badgeSize)
                        newStack.badge.categories = {2}
                        newStack.badge.mask = {1}
                        newStack.badge.count = 2
                        self.stacks[#self.stacks + 1] = newStack
                        table.insert(cardTable.badges, newStack.badge)
                    end
                end
            end
        end
        returnValue = true
        --delete any touchMap for an end touch
    elseif touch.state == ENDED and self.touchMap[touch.id] then
        --move card from this touchMap to end of bodies table
        --     local touchedBody = self.touchMap[touch.id].body
        --not sure why this works
        --   remove(self.bodies, touchedBody)
        --    table.insert(self.bodies, 1, touchedBody)
        if self.touchMap[touch.id].body:testPoint(touchPoint) then
            firstBodyTouched = self.touchMap[touch.id].body
        end
        self.touchMap[touch.id] = nil
        --[[
        for _, body in ipairs(self.bodies) do
        body[math.floor(touch.id)] = nil --touch.id used as numeric key to indicate following
        end
        ]]
        returnValue = true
    elseif touch.state == CANCELLED then
        --clear out remaining touchMaps and followings when any touch is cancelled
        if CodeaUnit.isRunning then
            print("# of touchMaps: "..#self.touchMap)
        end
        --[[
        for key, map in pairs(self.touchMap) do
        --   local flooredId = math.floor(map.id)
        for _, body in pairs(self.bodies) do
        --       if body[flooredId] then
        --          body[flooredId] = nil
        --     end
        end
        end
        ]]
        self.touchMap = {}
    end
    
    if(returnValue == true) then
        --  print("sent touch to card table from debugDraw")
        cardTable:touched(touch, self.bodies, firstBodyTouched)
    end
    --print("PDD about to return value")
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
