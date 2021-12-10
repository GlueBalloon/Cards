function testCardTable()
    
    CodeaUnit.detailed = false
    CodeaUnit.skip = false
    
    _:describe("Testing Card Table", function()
        
        _:before(function()
            --cardTable = CardTable()
        end)
        
        _:after(function()
           -- cardTable:cleanup()
           -- cardTable = nil
        end)
        
        _:test("does nothing", function()
            _:expect(true).is(true)
        end)
        
        _:test("makes 52 cards", function()
            _:expect(#cardTable.makeDeck()).is(52)
        end)

        _:test("makes right numbers of each suit", function()
            local spades, hearts, diamonds, clubs = 0,0,0,0
            for i,v in ipairs(cardTable.makeDeck()) do
                if v.suit == "spades" then
                    spades = spades + 1
                elseif v.suit == "hearts" then
                    hearts = hearts + 1
                elseif v.suit == "diamonds" then
                    diamonds = diamonds + 1
                elseif v.suit == "clubs" then
                    clubs = clubs + 1
                end
            end
            local rightTotals = spades == 13 and hearts == 13 and diamonds == 13 and clubs == 13
            _:expect(rightTotals).is(true)
        end)
        
        
        _:test("detects swipe across stacks", function()
            local randX = math.random(math.floor(WIDTH*0.1), math.floor(WIDTH*0.9))
            local randY = math.random(math.floor(HEIGHT*0.1), math.floor(HEIGHT*0.9))
            local topCard
            for _, card in ipairs(G.cardTable.cards) do
                if math.random(7) <= 2 then
                    topCard = card
                    card.body.position = vec2(randX, randY)
                end
            end
            local swipeDist = G.cardTable.cards[1].width * 2
            local fakeBeginTouch = fakeTouch(randX - swipeDist, randY, BEGAN, 1, 4373)
            local fakeMovingTouch = fakeTouch(randX + swipeDist, randY, MOVING, 1, 4373, fakeBeginTouch.pos)
            G.cardTable:touched(fakeBeginTouch)
            G.cardTable:touched(fakeBeginTouch)
            _:expect(false).is(true)
        end)
        
    end)
end

CardTable = class()

CardTable.tableContainsCard = function (targetTable, card)
    local set = {}
    for k, l in pairs(targetTable) do set[l] = true end
    if set[card] then return true
    else return false end
end

function CardTable:init()
    physics.gravity(0,0)
    self.bounds = self:createScreenBorders()
    self.cards={}
    self.cardsWithBodiesAsKeys = {}
    local deck = CardTable.makeDeck()
    for i, card in ipairs(deck) do
       -- physics:addBody(card.body)
        self:addCard(card)
        card.body.position = vec2(WIDTH/2, HEIGHT/2)
    end    
    self.stacker = CardStacker(self.cards)
    --[[
    for k,v in pairs (self.cardsWithBodiesAsKeys) do
        print(k.shortName)
    end
      ]]

    --[[
    parameter.action("List table cards", function()
        local cardsString = ""
        for _, card in pairs(self.cards) do
            cardsString = cardsString..card.body.shortName..". "
        end
        print(cardsString)
    end)
      ]]
    parameter.action("List table cards", function()
        local cardsString = ""
        for key, card in pairs(self.cards) do
            cardsString = cardsString.."["..tostring(key).."]:"..tostring(card.body.shortName).." "
        end
        print("cardTable keys, names:\n"..cardsString)
    end)
    -- self:moveFreeCardsToStack(self.cards, self.stacks[1])
end

function CardTable:addCard(card)
 --   print("adding card ", card, card.body.shortName)
    table.insert(self.cards, card)
    self.cardsWithBodiesAsKeys[card.body] = card
end

function CardTable:removeCard(card)
    remove(self.cards, card)
    self.cardsWithBodiesAsKeys[card.body] = nil
end

function CardTable:setup()
end

CardTable.makeDeck = function()
    local deck = {}
    for i,suit in ipairs(Card.allSuits) do
        for rank=2, 13 do
            table.insert(deck, Card(rank,suit))
        end
        table.insert(deck, Card(1,suit)) --put the ace at the end
    end
    return deck
end

--[[
function CardTable:moveFreeCardsToStack(cards, stack)
    for i=#cards, 1, -1 do
        local removedCard = table.remove(self.cards, i)
        debugDraw:removeBody(removedCard.body)
        table.insert(stack.cards, removedCard) --stack removes cards from debugDraw, is that good?
    end
    stack:arrangeStack()
end
  ]]

function CardTable:createScreenBorders() --size is size of 3D box
    local boundsBottom = physics.body(EDGE, vec2(0,0), vec2(WIDTH,0))
    local boundsLeft = physics.body(EDGE, vec2(0,0), vec2(0,HEIGHT))
    local boundsRight = physics.body(EDGE, vec2(WIDTH,0), vec2(WIDTH,HEIGHT))
    local boundsTop = physics.body(EDGE, vec2(0,HEIGHT), vec2(WIDTH,HEIGHT))
    boundsBottom.shortName = "boundsBottom"
    boundsLeft.shortName = "boundsLeft"
    boundsRight.shortName = "boundsRight"
    boundsTop.shortName = "boundsTop"
    local allBounds = {boundsBottom,boundsRight,boundsTop,boundsLeft}
    for i=1, #allBounds do
        allBounds[i].type = STATIC
        --physics:addBody(allBounds[i])
    end
    return allBounds
end

function CardTable:cleanup()
    for key, body in pairs(physics.bodies) do
        remove(physics.bodies, body)
        self.cards[key] = nil
    end
    physics:destroy()
    --[[
    for i, stack in ipairs(self.stacks) do
        for i, card in ipairs(self.cards) do
            card.body:destroy()
            card = nil
        end
    end
      ]]
end

function CardTable:draw()
    self.stacker:refreshStacks()
    tint(255, 136)
    sprite(asset.felt, WIDTH/2,HEIGHT/2,WIDTH,HEIGHT)
    noTint()
    for i=1, #self.cards do
        self.cards[i]:draw()
    end

    for i,stack in ipairs(self.stacker.stacks) do
        if #stack > 1 then
            local bottomCard = stack[#stack]
            local cardW, cardH = bottomCard.width, bottomCard.height
            local pos = bottomCard.body.position
            pos = pos + vec2(cardW * 0.5, cardH * 0.5)
            pushStyle()
            fill(255, 14, 0, 215)
            ellipse(pos.x, pos.y, cardW * 0.33)
            fill(255)
            font("HelveticaNeue")
            fontSize(cardW * 0.2)
            text(#stack, pos.x * 1.001, pos.y * 1.002)
            popStyle()
        end
    end
end


function CardTable:touched(touch, bodies, firstBodyTouched)
    local indexOfFirstTouched
--    print("table got a touch")
    --make sure self.cards is in same order as bodies array
    if bodies then
        local swapDeck = {}
        for i, body in ipairs(bodies) do
            if body.owningClass == "card" then
                --[[
                if firstBodyTouched == body then
                    indexOfFirstTouched = #swapDeck + 1
                    ]]
                    --[[
                    print("indexOfFirstTouched found: "..tostring(indexOfFirstTouched))
                    print("cardToForeground: "..body.shortName)
                    ]]
               -- end
                swapDeck[#swapDeck + 1] = self.cardsWithBodiesAsKeys[body]
                --[[
                if indexOfFirstTouched then
                    for k,v in pairs(self.cards) do
                        print(indexOfFirstTouched)
                        print(k,self.cards[indexOfFirstTouched].body.shortName)
                    end
                    print("swapDeck card "..tostring(indexOfFirstTouched).." is "..self.cards[indexOfFirstTouched].body.shortName)
                end
                ]]
            end
        end
        --print("swapdeck count:"..tostring(#swapDeck))
        if #swapDeck > 0 then
            self.cards = swapDeck
        end
    end
    
   -- print("made deck order match bodies")
    --[[
    if indexOfFirstTouched then
        for k,v in pairs(self.cards) do
            print(k,self.cards[k].body.shortName)
        end
        print("cardToForeground: "..self.cards[indexOfFirstTouched].body.shortName)
    end
    ]]
    --    local touchPoint = vec2(touch.pos.x, touch.pos.y)
    --count backwards through the cards so we find the frontmost card touched
    --[[
    for i=#self.cards, 1, -1 do
        -- print(self.cards[i].body.shortName)
        if self.cards[i].body:testPoint(touchPoint) then
            indexOfFirstTouched = i
            print("indexOfFirstTouched found: "..tostring(indexOfFirstTouched))
            break
        end
    end
    ]]
    --   print("searched for first touched")
    --   print("indexOfFirstTouched is nil: "..tostring(indexOfFirstTouched == nil))
    if firstBodyTouched and firstBodyTouched.owningClass then
        if firstBodyTouched.owningClass == "card" then
            --local cardToForeground = self.cards[indexOfFirstTouched]
            --      print("cardToForeground: "..cardToForeground.body.shortName)
            --at the start of a touch move the card to the top of the stack
            --[[
            if touch.state == BEGAN then
            table.remove(self.cards, indexOfFirstTouched)
            table.insert(self.cards, cardToForeground)
            end
            ]]
            local cardTouched = self.cardsWithBodiesAsKeys[firstBodyTouched]
            -- print("sending touch to card: "..firstBodyTouched.shortName)
            if cardTouched then cardTouched:touched(touch) end
        end
    end
    
    --[[
    for i,stack in ipairs(self.stacks) do
        stack:touched(touch)
    end
      ]]
end

