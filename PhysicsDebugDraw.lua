
function testPhysicsDebug()
    
    CodeaUnit.detailed = true
    CodeaUnit.skip = false
    -- local shouldWipeDebugDraw = false
    local card, card2, fakeBeginTouch, fakeMovingTouch, fakeEndTouch
    local cardsHolder, cardsIndexedByBodiesHolder, stacksHolder
    
    _:describe("Testing PhysicsDebugDraw", function()
        
        _:before(function()
            shouldReport = true
        --    if not CodeaUnit.doBeforeAndAfter then return end
            shouldReport = false
            card = Card(3, "hearts")
            card2 = Card(7, "clubs")
            card3 = Card(13, "hearts")
            cardsHolder = cardTable.cards
            cardTable.cards = {}
            cardsIndexedByBodiesHolder = cardTable.cardsWithBodiesAsKeys
            cardTable.cardsWithBodiesAsKeys = {}
            stacksHolder = cardTable.stacks
            debugDraw.stacks = cardTable.stacks
            debugDraw:addBody(card.body)
            debugDraw:addBody(card2.body)
            debugDraw:addBody(card3.body)
            cardTable:addCard(card)
            cardTable:addCard(card2)
            cardTable:addCard(card3)
            fakeBeginTouch = fakeTouch(100, 800, BEGAN, 1, 4373)
            fakeMovingTouch = fakeTouch(200, 700, MOVING, 1, 4373, fakeBeginTouch.pos)
            fakeFurtherMovingTouch = fakeTouch(300, 500, MOVING, 1, 4373, fakeMovingTouch.pos)
            fakeEndTouch = fakeTouch(500, 100, ENDED, 1, 4373, fakeFurtherMovingTouch.pos)
        end)
        
        _:after(function()
            shouldReport = true
         --   if not CodeaUnit.doBeforeAndAfter then return end
            shouldReport = false
            actualString = "not that"
            desiredString = ""
            remove(debugDraw.bodies, card.body)
            remove(debugDraw.bodies, card2.body)
            remove(debugDraw.bodies, card3.body)
            cardTable:removeCard(card)
            cardTable:removeCard(card2)
            cardTable:removeCard(card3)
            card.body:destroy()
            card2.body:destroy()
            card3.body:destroy()
            card, card2, card3 = nil, nil, nil
            debugDraw.touchMap[fakeBeginTouch.id] = nil
            cardTable.cards = cardsHolder
            cardTable.cardsWithBodiesAsKeys = cardsIndexedByBodiesHolder
            cardTable.stacks = stacksHolder
            debugDraw.stacks = cardTable.stacks
        end)
        
        function setupTwoCardsAndBeginTouch()
            --cards are stacked by default, so card2 is touched first
            card.body.x, card.body.y = WIDTH, HEIGHT
            card2.body.x, card2.body.y = card.body.x, card.body.y
            --touch starts right on 'em
            fakeBeginTouch.pos.x, fakeBeginTouch.pos.y = card.body.x+(card.width*0.05), card.body.y+(card.height*0.05)
            debugDraw:touched(fakeBeginTouch)
        end
        
        _:test("hasBody works with random body and new body", function()
            local randomBody = debugDraw.bodies[math.random(#debugDraw.bodies)]
            local newBody = physics.body(POLYGON, vec2(0,0), vec2(1,1), vec2(2,2))
            local randomIsIn = debugDraw:hasBody(randomBody)
            local newIsNot = debugDraw:hasBody(newBody) == false
            _:expect(randomIsIn and newIsNot).is(true)
        end)
        
        _:test("removeBody removes body", function()
            local randomBody = debugDraw.bodies[math.random(#debugDraw.bodies)]
            local originalTotal = #debugDraw.bodies
            debugDraw:removeBody(randomBody)
            local isGone = debugDraw:hasBody(randomBody) == false
            debugDraw:addBody(randomBody) --put back what you play with folks!
            _:expect(isGone).is(true)
        end)
        
        _:test("removeBody leaves bodies with one less body", function()
            local randomBody = debugDraw.bodies[math.random(#debugDraw.bodies)]
            local originalTotal = #debugDraw.bodies
            debugDraw:removeBody(randomBody)
            local rightTotal = #debugDraw.bodies == originalTotal - 1
            debugDraw:addBody(randomBody) --put back what you play with folks!
            _:expect(rightTotal).is(true)
        end)
        
        _:test("card that tap started on moves to end of bodies table", function()
            --give 'card' a new position
            card.body.x, card.body.y = WIDTH, HEIGHT
            --position fake touch
            fakeBeginTouch.pos.x, fakeBeginTouch.pos.y = card.body.x +1, card.body.y +2
            debugDraw:touched(fakeBeginTouch)
            local lastBody = debugDraw.bodies[#debugDraw.bodies]
            _:expect(lastBody == card.body).is(true)
        end)
        
        _:test("only top card in a stack responds to a BEGIN touch", function()
            setupTwoCardsAndBeginTouch()
            _:expect("touchMap has the right body", debugDraw.touchMap[fakeBeginTouch.id].body).is(card2.body)
            _:expect("right number of followers", #debugDraw.touchMap[fakeBeginTouch.id].followers).is(0)
        end)
        
        
        _:test("a card doesn't become a follower if the touch started inside its bounds", function()
            setupTwoCardsAndBeginTouch()
            fakeMovingTouch.pos.x, fakeMovingTouch.pos.y = card2.body.x, card2.body.y
            debugDraw:touched(fakeMovingTouch)
            _:expect(#debugDraw.touchMap[fakeBeginTouch.id].followers).is(0)
        end)
        
        
        _:test("a card doesn't become a follower if the previous touch was inside its bounds", function()
            setupTwoCardsAndBeginTouch()
            fakeMovingTouch.pos.x, fakeMovingTouch.pos.y = card2.body.x + 5, card2.body.y + 5
            fakeMovingTouch.prevPos = fakeBeginTouch.pos
            debugDraw:touched(fakeMovingTouch)
            _:expect(#debugDraw.touchMap[fakeBeginTouch.id].followers).is(0)
        end)
        
        function trace (event, line)
            local s = debug.getinfo(2).short_src
            print(s .. ":" .. line)
        end
        
        function traceCard2body(event, line)
           -- local firstCardBody = cardTable.cards[1].body
            if 
                shouldReport 
             and
           --      card2 and
          --      card3 and
         --        bugTest and
                 cardTable.stacks[1] and
                 cardTable.stacks[1][1] 
                then
                print(cardTable.stacks[1][1].shortName.." "..tostring(cardTable.stacks[1][1].position))
                --local pos = stack[1].position
            --[[
                for i, v in ipairs( cardTable.stacks[1]) do
                    print(tostring(cardTable.cardPosUtility))
                    print(tostring(v.shortName).." "..tostring(v.position)..tostring(v.owningClass))
                end
            ]]
                local s = debug.getinfo(2).short_src
                print(s .. ":" .. line)
                print("------")
                breakpoint()
            end
        end
              
        _:test("a card DOES become a follower if the touch started outside its bounds", function()
        --    CodeaUnit.doBeforeAndAfter = false
            card.body.x, card.body.y = 1500, 1500
            card2.body.x, card2.body.y = 20, 20
            fakeBeginTouch.pos.x, fakeBeginTouch.pos.y = card.body.x+(card.width*0.25), card.body.y+(card.height*0.25)
            fakeMovingTouch.pos.x, fakeMovingTouch.pos.y = card2.body.x, card2.body.y
            debugDraw:touched(fakeBeginTouch)
            bugTest = true

           -- debug.sethook(traceCard2body, "l")
            --phony comment
            shouldReport = false
            function fake()               
            end
            shouldReport = true
            fake()
            shouldReport = false
            debugDraw:touched(fakeMovingTouch)
            _:expect("--a: one follower if touch started outside card2 then went in", #debugDraw.touchMap[fakeBeginTouch.id].followers).is(1)
            _:expect("--b: card2 is the follower", debugDraw.touchMap[fakeBeginTouch.id].followers).has(card2.body)
            CodeaUnit.doBeforeAndAfter = true
        end)
        
        _:test("touch table is cleared from touchMap when touch ends", function()
  --  if true then return end
            CodeaUnit.doBeforeAndAfter = false
            card.body.x, card.body.y = WIDTH, HEIGHT
            card2.body.x, card2.body.y = 0, 0
            fakeBeginTouch.pos.x, fakeBeginTouch.pos.y = card.body.x+(card.width*0.25), card.body.y+(card.height*0.25)
            fakeMovingTouch.pos.x, fakeMovingTouch.pos.y = card2.body.x, card2.body.y
            fakeEndTouch.pos.x, fakeEndTouch.pos.y = card.body.x/2, card.body.y/2
            debugDraw:touched(fakeBeginTouch)

            debugDraw:touched(fakeMovingTouch)
            debugDraw:touched(fakeEndTouch)
            local touchMapIsNil = debugDraw.touchMap[fakeBeginTouch.id] == nil
            _:expect(touchMapIsNil).is(true)
            CodeaUnit.doBeforeAndAfter = true
        end)
        
        _:test("touchMap is cleared when touch is cancelled", function()
   --         if true then return end
            CodeaUnit.doBeforeAndAfter = false
            card.body.x, card.body.y = WIDTH, HEIGHT
            card2.body.x, card2.body.y = 0, 0
            fakeBeginTouch.pos.x, fakeBeginTouch.pos.y = card.body.x+(card.width*0.25), card.body.y+(card.height*0.25)
            fakeMovingTouch.pos.x, fakeMovingTouch.pos.y = card2.body.x, card2.body.y
            fakeEndTouch.pos.x, fakeEndTouch.pos.y = card.body.x/2, card.body.y/2
            fakeEndTouch.state = CANCELLED
            debugDraw:touched(fakeBeginTouch)
            _:expect("--a: touchMap after BEGAN has the right body", debugDraw.touchMap[fakeBeginTouch.id].body).is(card.body)
            _:expect("--b: touchMap after BEGAN has no followers", #debugDraw.touchMap[fakeBeginTouch.id].followers).is(0)
            debugDraw:touched(fakeMovingTouch)
            _:expect("--c: touchMap still right body after MOVING", debugDraw.touchMap[fakeBeginTouch.id].body).is(card.body)
            _:expect("--d: after MOVING has one follower", #debugDraw.touchMap[fakeBeginTouch.id].followers).is(1)
            debugDraw:touched(fakeEndTouch)
            local touchMapIsNil = debugDraw.touchMap[fakeBeginTouch.id] == nil
            _:expect("--e: after CANCELLED touchMap touch is gone", touchMapIsNil).is(true)
            CodeaUnit.doBeforeAndAfter = false
        end)
        
        _:test("stack creation", function()
   --         if true then return end
            CodeaUnit.doBeforeAndAfter = false
            local cardDistanceMin = card.height * 1.1
            card.body.x, card.body.y = 1500, 1500
            print(card.body.x, card.body.y)
            card2.body.x, card2.body.y = card.body.x - cardDistanceMin, card.body.y - cardDistanceMin
            card3.body.x, card3.body.y = card2.body.x - cardDistanceMin, card2.body.y - cardDistanceMin
            fakeBeginTouch.pos.x, fakeBeginTouch.pos.y = card.body.x+(card.width*0.25), card.body.y+(card.height*0.25)
            fakeMovingTouch.pos.x, fakeMovingTouch.pos.y = card2.body.x, card2.body.y
            fakeTouchRightNextToFirstMovingTouch = fakeTouch(card2.body.x + 1, card2.body.y, MOVING, 1, 4373, fakeMovingTouch.pos)
            --redefine further touch to include tiny movement above
            fakeFurtherMovingTouch = fakeTouch(card3.body.x, card3.body.y, MOVING, 1, 4373, fakeTouchRightNextToFirstMovingTouch.pos)
            local rightNumStacks = #cardTable.stacks
            debugDraw:touched(fakeBeginTouch)
            _:expect("--a: after touch moves through one body, no stack is made", #cardTable.stacks).is(rightNumStacks)
            debugDraw:touched(fakeMovingTouch)
            rightNumStacks = rightNumStacks + 1
            _:expect("--b: after touch moves through two bodies, stack is made", #cardTable.stacks).is(rightNumStacks)
            local stackWithRightBody
            for i, stack in ipairs(debugDraw.stacks) do
                if stack[1] == card.body then
                    stackWithRightBody = stack
                    break
                end
            end
            _:expect("--c: stack exists with right first body", stackWithRightBody ~= nil).is(true)
            _:expect("--d: stack is keyed to by first body", debugDraw.stacks[card.body]).is(stackWithRightBody)
            _:expect("--e: same stack contains second body", stackWithRightBody).has(card2.body)
            local cardTableHasTable = cardTable.stacks == debugDraw.stacks
            _:expect("--f: cardTable has same stack table", cardTableHasTable).is(true)
            debugDraw:touched(fakeTouchRightNextToFirstMovingTouch)
            _:expect("--g: card touched twice is not added twice", 2).is(#stackWithRightBody)
            debugDraw:touched(fakeFurtherMovingTouch)
            _:expect("--h: multiple cards touched don't create multiple stacks", #debugDraw.stacks).is(rightNumStacks)
            _:expect("--i: third card touched is also added", stackWithRightBody).has(card3.body)
            
            local notInStack = true
            for _, stack in ipairs(debugDraw.stacks) do
                if stack[1] == card.body then
                    notInStack = false
                end
            end
            
            --have to end touch to test moving the top card off a stack. So that should go in a separate test function.
            
            _:expect("--j: card moved away from others is removed from stack", (stackIdGone and notInStack)).is(true)
            --   _:expect("--b: after CANCELLED touchMap touch is gone", touchMapIsNil).is(true)
            --change touchMap's body to a table of bodies that holds all bodies in a stack...? or not because theres a quicker way that's less elegant but will work...followers to a single table stored in a touchMap's body, so that can directly become a stack...
            --  a touch map counts stacked cards and creates a badge
            -- badge vanishes if too many cards misaligned? badge counts down as cards are moved off it...
            CodeaUnit.doBeforeAndAfter = false
end)

        _:test("stack separation", function()
            --gotta make a stack artificslly here
            _:expect("--j: card moved away from others is removed from stack", (stackIdGone and notInStack)).is(true)
        end)
end)
end

PhysicsDebugDraw = class()

function PhysicsDebugDraw:init()
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
    -- print("adding"..body.shortName)
    for i, thisBody in ipairs(self.bodies) do
        if thisBody == body then
            return
        end
    end
    self.bodies[#self.bodies+1] = body
    --table.insert(self.bodies, body)
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
        str = "debug.bodies: "..dump(self.bodies, "", true)
        local _, strH = textSize(str)
        fill(255, 14, 0)
        text(str, xPos, HEIGHT - strH - 10)
        
        fill(0, 243, 255)
        local touchStr = "touchMap: "..dump(self.touchMap, "\n")
        local _, touchStrH = textSize(touchStr)
        text(touchStr, xPos, HEIGHT - strH - 10 - touchStrH - 10)
        
        stacksString = "stacks: "..dump(cardTable.stacks, "\n")
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
            --print(body.shortName, body.owningClass)
            if body.owningClass == "card" then 
                if body.type == DYNAMIC and body:testPoint(touchPoint) then
                    --  print(body.shortName, body.owningClass)
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
        self.touchMap[touch.id] = nil
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
