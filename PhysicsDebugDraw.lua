
PhysicsDebugDraw = class()

function PhysicsDebugDraw:init()
    self.bodies = {}
    self.joints = {}
    self.touchMap = {}
    self.contacts = {}
    self.stacks = {}
    self.touchMapFunctions = {}
    parameter.action("List DebugDraw bodies", function()
        print("debugDraw keys/identifiers: "..self:bodiesList())
    end)
    parameter.boolean("screenReport", false)
end

function PhysicsDebugDraw:addBody(body)
    -- print("adding"..body.shortName)
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
    self.touchMap[touch.id] = {tp = touchPoint, body = body, anchor = touchAnchor, followers = {}}
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
    
    if screenReport then
        pushStyle()
        fontSize(15)
        --    local str, stacksString = self:bodiesList(), ""
        local xPos = WIDTH * 0.25
        textWrapWidth(WIDTH * 0.65)
        textMode(CORNER)
        --[[
        for k, v in pairs(self.stacks) do
        stacksString = stacksString.."self.stacks["..stringIfBody(k).."] = "
        if type(v) == "table" then
        stacksString = stacksString.."{"
        for kk, vv in pairs(v) do
        local kkStr = stringIfBody(kk)
        local vvStr = stringIfBody(vv)
        stacksString = stacksString.." ["..kkStr.."] = "..vvStr.." "
        end
        stacksString = stacksString.."}"
        else
        stacksString = stacksString..stringIfBody(v)
        end
        stacksString = stacksString.."\n"
        end
        ]]
        str = "debug.bodies: "..tableToString(self.bodies, "", true)
        local _, strH = textSize(str)
        fill(255, 14, 0)
        text(str, xPos, HEIGHT - strH - 10)
        
        fill(0, 243, 255)
        local touchStr = "touchMap: "..tableToString(self.touchMap, "\n")
        local _, touchStrH = textSize(touchStr)
        text(touchStr, xPos, HEIGHT - strH - 10 - touchStrH - 10)
        
        stacksString = "stacks: "..tableToString(cardTable.stacker.stacks[1], "\n")
        local _, stkStrH = textSize(stacksString)
        fill(92, 236, 67)
        text(stacksString, xPos, HEIGHT - strH - 10 - touchStrH - 10 - stkStrH - 20)
        
    end
    
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
            
            
            if CodeaUnit.isRunning then 
                if not body or not body.x then
                    print("----", "body at index ", i)
                    print(body.position)
                    print(body, ", x: ", body.x, ", y: ", body.y)
                    print(body.shortName)
                    print("bodies: ", #self.bodies)
                    -- assert(false, "stopping runtime")
                    CodeaUnit.isRunning = false
                end
            end
            
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
                    break
                end
            end
        end
    elseif touch.state == MOVING and self.touchMap[touch.id] then
        shouldReport = true
        --  print("moving touchmap: "..self.touchMap[touch.id].body.shortName)
        self.touchMap[touch.id].tp = touchPoint
        for _,body in ipairs(self.bodies) do
            if body.owningClass == "card" then
                --print("moving, ",body.shortName, body.owningClass)
                --make sure this touch is actually inside this body and this body isn't a leading body
                if body.type == DYNAMIC and body:testPoint(touchPoint) and body ~= self.touchMap[touch.id].body then
                    --exclude any subsequent body that the previous touch was *inside*
                    if not body:testPoint(touch.prevPos) then
                        --add this body to the followers
                        table.insert(self.touchMap[touch.id].followers, body)
                        --if there's no stack, make one--identified by top body
                        if self.stacks[self.touchMap[touch.id].body] == nil then                          
                            
                            local newStack = {self.touchMap[touch.id].body, body}
                            self.stacks[self.touchMap[touch.id].body] = newStack
                            table.insert(self.stacks, newStack)
                            --print(self.stacks[self.touchMap[touch.id].body])
                        else                       
                            --if there is, add body to it
                            table.insert(self.stacks[self.touchMap[touch.id].body], body)
                        end
                    end
                end
            end
        end
        shouldReport = false
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
        self:clearTouchMap(touch)
        --[[
        for _, body in ipairs(self.bodies) do
        body[math.floor(touch.id)] = nil --touch.id used as numeric key to indicate following
        end
        ]]
        returnValue = true
    elseif touch.state == CANCELLED then
        --clear out remaining touchMaps and followings when any touch is cancelled
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
        self:clearTouchMap(touch)
    end
    
    if(returnValue == true) then
        --  print("sent touch to card table from debugDraw")
        cardTable:touched(touch, self.bodies, firstBodyTouched)
    end

    --print("PDD about to return value")
    return returnValue
end

function PhysicsDebugDraw:clearTouchMap(touch)
    for _, body in ipairs(self.touchMap[touch.id].followers) do
        if body.keepSkew then body.keepSkew = nil end
        body.angularVelocity = self.touchMap[touch.id].body.angularVelocity
        body.linearVelocity = self.touchMap[touch.id].body.linearVelocity
    end
    self.touchMap[touch.id] = nil
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
