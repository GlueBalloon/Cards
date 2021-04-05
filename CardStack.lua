CardStack = class()


--[[
function t   estCardStack() --have to mess up name or CodeaUnit tries to run it
    
    CodeaUnit.detailed = false
    
    local stack = CardStack(CardTable.makeDeck())
    
    _:describe("Testing CardStack", function()
        
        _:before(function()
        end)
        
        _:after(function()
        end)
        
        _:test("shuffling cards changes order of at least 20 cards", function()
            local referenceDeck = CardTable.makeDeck()
            local variationCount = 0
            stack:shuffle()
            for i, card in ipairs(referenceDeck) do
                if card.rank ~= stack.cards[i].rank or
                card.suit ~= stack.cards[i].suit then
                    variationCount = variationCount + 1
                end
            end
            _:expect(variationCount >= 20).is(true)
        end)
        
        _:test("cards in stack are not in debugdraw", function()
            local bodyNotFound = true
            for i, card in ipairs(stack.cards) do
                if debugDraw:hasBody(card.body) then
                    bodyNotFound = false
                    print("test: body found: "..tostring(card.body.info.kind))
                    break
                else
                --    print("test: body not found")
                end
            end
            _:expect(bodyNotFound).is(true)
        end)
    end)
end
  ]]

function CardStack:init(startingCards)
    self.cards = {}
    self.width = WIDTH * 0.07
    self.height = WIDTH * 0.095
    self.body = createBox(WIDTH/2, 600, self.width, self.height)
    self.body.linearDamping = 4 --has something to do with momentum
    self.body.angularDamping = 5
    self.body.categories={2}
    self.body.mask={0}
    self.body.shirtName = "cardStack"
    self.image = 0
    --debugDraw:addBody(self.body)
    if startingCards then
        for i, card in ipairs(startingCards) do
            self:addCard(card)
        end
    end
  --  self:arrangeStack() --gotta change to just make stack
end

function CardStack:addCard(card)
    table.insert(self.cards, card)
end

function CardStack:shuffle()
    for i = #self.cards, 2, -1 do
        local j = math.random(i)
        self.cards[i], self.cards[j] = self.cards[j], self.cards[i]
    end
end

--[[
function CardStack:arrangeStack()
    if #self.cards <= 0 then return end
    --self.image = image(self.width, self.height)
  --  setContext(self.image)
    for i, card in ipairs(self.cards) do
        local jitterX, jitterY = math.random(8), math.random(8)
        local tilt = math.random(-8,8)
        pushMatrix()
        popStyle()
        resetMatrix()
        translate(self.width/2+jitterX,self.height/2+jitterY)
        rotate(tilt)
        if i < #self.cards then
            tint(236-((#self.cards-i)*1.5))
        end
        card.body.x, card.body.y = self.body.x+jitterX, self.body.y+jitterY
        card.angle = self.body.angle + tilt
   -- sprite(card.back,0,0,card.width,card.height)
        noTint()
        pushStyle()
        popMatrix()
    end
    setContext()
end
  ]]

function CardStack:draw()
    if self.body == nil then return end
    pushMatrix()
    pushStyle()
    resetMatrix()
    translate(self.body.x,self.body.y)
    rotate(self.body.angle)
    fill(237, 6, 159, 95)
    rectMode(CENTER)
    rect(0,0,self.width,self.height)
    popStyle()
    popMatrix()

    --[[
    pushMatrix()
    pushStyle()
    noStroke()
    translate(self.body.x,self.body.y)
    fill(237, 6, 159, 95)
    rectMode(CENTER)
    rect(0,0,self.width,self.height)
    for i, card in ipairs(self.cards) do
        card:draw()
    end
    --sprite(self.image,0,0,self.width,self.height)
    popStyle()
    popMatrix()
      ]]
end

function CardStack:touched(touch)
    --local touchPoint = vec2(touch.pos.x, touch.pos.y)
    local selfTapped = self.body:testPoint(touch.pos)
    if selfTapped and touch.tapCount == 1 and touch.state == ENDED then
        print("you tapped me, a card stack")
    end
    --[[
    if selfTapped and touch.state == MOVING then
        local previousAngle = self.body.angle
        self.body.position = touch.pos
        self.body.angle = previousAngle
    end
      ]]
end
