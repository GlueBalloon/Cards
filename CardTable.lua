

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
    self.cards[card.body.shortName] = card
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
            fill(255, 14, 0, 245)
            ellipse(pos.x, pos.y, cardW * 0.35)
            fill(255)
            font("HelveticaNeue-Bold")
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

