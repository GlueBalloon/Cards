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
    self:createScreenBorders()
    self.cards={}
    self.cardsWithBodiesAsKeys = {}
    self.cards = CardTable.makeDeck()
   -- self.stacks = {CardStack()}
    for i, card in ipairs(self.cards) do
        debugDraw:addBody(card.body)
        self.cardsWithBodiesAsKeys[card.body] = card
    end
    
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
        debugDraw:addBody(allBounds[i])
    end
    return boundingBox
end

function CardTable:cleanup()
    for key, body in pairs(debugDraw.bodies) do
        remove(debugDraw.bodies, body)
        body:destroy()
        self.cards[key] = nil
    end
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
    tint(255, 136)
    sprite(asset.felt, WIDTH/2,HEIGHT/2,WIDTH,HEIGHT)
    noTint()
    for i=1, #self.cards do
        self.cards[i]:draw()
    end
    --[[
    for i,stack in ipairs(self.stacks) do
        stack:draw()
    end
      ]]
end


function CardTable:touched(touch, bodies)
    --print("table got a touch")
    if true then
        if bodies then
            local swapDeck = {}
            for i, body in ipairs(bodies) do
                if body.owningClass == "card" then
                    swapDeck[#swapDeck + 1] = self.cardsWithBodiesAsKeys[body]
                end
            end
            if #swapDeck > 0 then
                self.cards = swapDeck
            end
            --return
        end
    end
    --print("reordered deck")
    local indexOfFirstTouched
    local touchPoint = vec2(touch.pos.x, touch.pos.y)
    --count backwards through the cards so we find the frontmost card touched
    for i=#self.cards, 1, -1 do
        if self.cards[i].body:testPoint(touchPoint) then
            indexOfFirstTouched = i
            break
        end
    end
    if indexOfFirstTouched then
        local cardToForeground = self.cards[indexOfFirstTouched]
        --at the start of a touch move the card to the top of the stack
        if touch.state == BEGAN then
            table.remove(self.cards, indexOfFirstTouched)
            table.insert(self.cards, cardToForeground)
        end
        print("sending touch to card")
        cardToForeground:touched(touch)
    end
    --[[
    for i,stack in ipairs(self.stacks) do
        stack:touched(touch)
    end
      ]]
end

