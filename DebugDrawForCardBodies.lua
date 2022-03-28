
DebugDrawForCardBodies = class()

function DebugDrawForCardBodies:init(cardTable)
    self.bodies = {}
    self.joints = {}
    self.touchMap = {}
    self.contacts = {}
    self.stacks = {}
    self.touchMapFunctions = {}
    self.cardTable = cardTable or {}
    parameter.action("List DebugDraw bodies", function()
        print("debugDraw keys/identifiers: "..self:bodiesList())
    end)
    parameter.boolean("screenReport", false)
end

function DebugDrawForCardBodies:addBody(body)
    -- print("adding"..body.shortName)
    for i, thisBody in ipairs(self.bodies) do
        if thisBody == body then
            return
        end
    end
    self.bodies[#self.bodies+1] = body
end

function DebugDrawForCardBodies:bodiesList()
    local cardsString = ""
    for key, body in pairs(self.bodies) do
        local identifier = body.shortName or body
        cardsString = cardsString.."["..tostring(key).."]:"..tostring(identifier).."   "
    end
    return cardsString
end

function DebugDrawForCardBodies:removeBody(removeMe)
        remove(self.bodies, removeMe)
end

function DebugDrawForCardBodies:removeAndDestroyThoughYouStillGottaNilManually(obliterateMe)
    self:removeBody(obliterateMe)
    obliterateMe:destroy()
end

function DebugDrawForCardBodies:hasBody(verifyMe)
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

function DebugDrawForCardBodies:addTouchToTouchMap(touch, body)
    local touchAnchor = body:getLocalPoint(touch.pos)
    self.touchMap[touch.id] = {
        tp = touch.pos,
        body = body,
        anchor = touchAnchor, 
        startPoint = touch.pos,
        startTime = ElapsedTime,
        followers = {}
    }
end

function DebugDrawForCardBodies:addJoint(joint)
    table.insert(self.joints,joint)
end

function DebugDrawForCardBodies:clear()
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

function DebugDrawForCardBodies:draw()
    
    if screenReport then
        pushStyle()
        fontSize(15)
 
        local xPos = WIDTH * 0.25
        textWrapWidth(WIDTH * 0.65)
        textMode(CORNER)

        str = "debug.bodies: "..tableToString(self.bodies, "", true)
        local _, strH = textSize(str)
        fill(255, 14, 0)
        text(str, xPos, HEIGHT - strH - 10)
        
        fill(0, 243, 255)
        local touchStr = "touchMap: "..tableToString(self.touchMap, "\n")
        local _, touchStrH = textSize(touchStr)
        text(touchStr, xPos, HEIGHT - strH - 10 - touchStrH - 10)
        
        stacksString = "stacks: "..tableToString(self.cardTable.stacker.stacks[1], "\n")
        local _, stkStrH = textSize(stacksString)
        fill(92, 236, 67)
        text(stacksString, xPos, HEIGHT - strH - 10 - touchStrH - 10 - stkStrH - 20)
        
    end
    
    local shouldDraw = false
    if shouldDraw then
        pushStyle()
        smooth()
        strokeWidth(5)
        stroke(128,0,128) -- purple
    end
   
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

function DebugDrawForCardBodies:touched(touch)
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
            if body.class == "card" then 
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
        if not self.touchMap[touch.id].body.isPickerUpper then goto endOfStacking end
        for _,body in ipairs(self.bodies) do
            if body.class == "card" then
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
        ::endOfStacking::
        shouldReport = false
        returnValue = true
        --delete any touchMap for an end touch
    elseif touch.state == ENDED and self.touchMap[touch.id] then
        self.touchMap[touch.id].body.lastTouch = nil
        if self.touchMap[touch.id].body:testPoint(touchPoint) then
            firstBodyTouched = self.touchMap[touch.id].body
        end
        self:clearTouchMap(touch)
        returnValue = true
    elseif touch.state == CANCELLED then
        self:clearTouchMap(touch)
    end
    
    if(returnValue == true) then
        --  print("sent touch to card table from debugDraw")
        self.cardTable:touched(touch, self.bodies, firstBodyTouched)
    end

    --print("PDD about to return value")
    return returnValue
end

function DebugDrawForCardBodies:clearTouchMap(touch)
    for _, body in ipairs(self.touchMap[touch.id].followers) do
        if body.keepSkew then body.keepSkew = nil end
        body.angularVelocity = self.touchMap[touch.id].body.angularVelocity
        body.linearVelocity = self.touchMap[touch.id].body.linearVelocity
    end
    self.touchMap[touch.id].body.isPickerUpper = nil
    self.touchMap[touch.id] = nil
end

function DebugDrawForCardBodies:collide(contact)
    if contact.state == BEGAN then
        self.contacts[contact.id] = contact
        -- sound(SOUND_HIT, 2643)
    elseif contact.state == MOVING then
        self.contacts[contact.id] = contact
    elseif contact.state == ENDED then
        self.contacts[contact.id] = nil
    end
end
