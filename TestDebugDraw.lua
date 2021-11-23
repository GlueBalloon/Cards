
function testPhysicsDebug()
    
    CodeaUnit.detailed = true
    CodeaUnit.skip = false
    
    -- local shouldWipeDebugDraw = false
    local card, card2, fakeBeginTouch, fakeMovingTouch, fakeEndTouch
    
    _:describe("Testing PhysicsDebugDraw", function()
        
        _:before(function()
            card = Card(3, "hearts")
            card2 = Card(7, "clubs")
            card3 = Card(13, "hearts")
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
            --[[
            card.body.x, card.body.y = WIDTH, HEIGHT
            card2.body.x, card2.body.y = card.body.x, card.body.y
            fakeBeginTouch.pos.x, fakeBeginTouch.pos.y = card.body.x+(card.width*0.25), card.body.y+(card.height*0.25)
            debugDraw:touched(fakeBeginTouch)
            ]]
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
        
        _:test("a card DOES become a follower if the touch started outside its bounds", function()
            card.body.x, card.body.y = 1500, 1500
            card2.body.x, card2.body.y = 20, 20
            fakeBeginTouch.pos.x, fakeBeginTouch.pos.y = card.body.x+(card.width*0.25), card.body.y+(card.height*0.25)
            fakeMovingTouch.pos.x, fakeMovingTouch.pos.y = card2.body.x, card2.body.y
            debugDraw:touched(fakeBeginTouch)
            debugDraw:touched(fakeMovingTouch)
            _:expect("--a: one follower if touch started outside card2 then went in", #debugDraw.touchMap[fakeBeginTouch.id].followers).is(1)
            _:expect("--b: card2 is the follower", debugDraw.touchMap[fakeBeginTouch.id].followers).has(card2.body)
        end)
        
        _:test("touch table is cleared from touchMap when touch ends", function()
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
            
        end)
        
        _:test("touchMap is cleared when touch is cancelled", function()
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
        end)
        
        _:test("badge creation", function()
            local cardDistanceMin = card.height * 1.1
            card.body.x, card.body.y = 1500, 1500
            card2.body.x, card2.body.y = card.body.x - cardDistanceMin, card.body.y - cardDistanceMin
            card3.body.x, card3.body.y = card2.body.x - cardDistanceMin, card2.body.y - cardDistanceMin
            fakeBeginTouch.pos.x, fakeBeginTouch.pos.y = card.body.x+(card.width*0.25), card.body.y+(card.height*0.25)
            fakeMovingTouch.pos.x, fakeMovingTouch.pos.y = card2.body.x, card2.body.y
            fakeTouchRightNextToFirstMovingTouch = fakeTouch(card2.body.x + 1, card2.body.y, MOVING, 1, 4373, fakeMovingTouch.pos)
            --redefine further touch to include tiny movement above
            fakeFurtherMovingTouch = fakeTouch(card3.body.x, card3.body.y, MOVING, 1, 4373, fakeTouchRightNextToFirstMovingTouch.pos)
            local rightNumStacks = #debugDraw.stacks
            debugDraw:touched(fakeBeginTouch)
            _:expect("--a: after touch moves through one body, no stack is made", #debugDraw.stacks).is(rightNumStacks)
            debugDraw:touched(fakeMovingTouch)
            rightNumStacks = rightNumStacks + 1
            _:expect("--b: after touch moves through two bodies, stack is made", #debugDraw.stacks).is(rightNumStacks)
            local stackWithRightBody
            for i, stack in ipairs(debugDraw.stacks) do
                if stack[1] == card.body then
                    stackWithRightBody = stack
                    break
                end
            end
            _:expect("--c: stack exists with right first body", stackWithRightBody ~= nil).is(true)
            _:expect("--d: same stack contains second body", stackWithRightBody).has(card2.body)
            debugDraw:touched(fakeTouchRightNextToFirstMovingTouch)
            _:expect("--e: card touched twice is not added twice", 2).is(#stackWithRightBody)
            debugDraw:touched(fakeFurtherMovingTouch)
            _:expect("--f: multiple cards touched don't create multiple stacks", #debugDraw.stacks).is(rightNumStacks)
            _:expect("--g: third card touched is also added", stackWithRightBody).has(card3.body)
            local badgeExists = stackWithRightBody.badge ~= nil
            _:expect("--h: stack has badge", badgeExists).is(true)
            _:expect("--i: badge has right collision category", stackWithRightBody.badge.categories).has(2)
            _:expect("--j: badge has right collision mask", stackWithRightBody.badge.mask).has(1)
            _:expect("--k: reference to badge object created in card table", cardTable.badges).has(stackWithRightBody.badge)
            --   _:expect("--b: after CANCELLED touchMap touch is gone", touchMapIsNil).is(true)
            --change touchMap's body to a table of bodies that holds all bodies in a stack...? or not because theres a quicker way that's less elegant but will work...followers to a single table stored in a touchMap's body, so that can directly become a stack...
            --  a touch map counts stacked cards and creates a badge
            -- badge vanishes if too many cards misaligned? badge counts down as cards are moved off it...
        end)
    end)
end
