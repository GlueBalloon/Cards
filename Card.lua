

Card = class()
Card.allSuits = {"spades","hearts","diamonds","clubs"}

function Card:init(rank, suit, startingPosition)
    --print("making card")
    --card dimensions are 64mm/89mm
    self.rank = rank or 1
    self.suit = suit or "spades"
    local hypoSquared = (WIDTH*WIDTH)+(HEIGHT*HEIGHT)
    local hypotenoooooose = math.sqrt(hypoSquared)
    self.width = hypotenoooooose * 0.0853333
    self.height = hypotenoooooose * 0.1196666
    self.body = createBox(WIDTH/2, self.height * 0.6, self.width, self.height)
    self.body.position = startingPosition or vec2(0, 0)
    self.body.angle = 0
    self.body.linearDamping = 4 --has something to do with momentum
    self.body.angularDamping = 5
    self.body.categories={2}
    self.body.mask={1} --setting to zero becomes 1 for some reason
   -- self.body.info = {["kind"] = self:shortName(), ["ownerClass"] = self.class} <--don't need this, can store anything directly on body table, refactor code to remove references to this
    --debugDraw:addBody(self.body)
    self.body.owningClass = "card"
    self.body.owner = self
    self.body.shortName = self:shortName()
    self.back = asset.cardBackMonkey
    self.face = asset[self:shortName()..".png"]
    self.showing = self.back,mk
    self.lastTouch = {}
    local borderSize = self.width / 10
    self.borderScale = vec2(self.width + borderSize, self.height + borderSize)
end

function Card:destroy()
    self.body:destroy()
    self = nil
end

function Card:draw()
    pushStyle()
    pushMatrix()
    resetMatrix()
    translate(self.body.x,self.body.y)
    rotate(self.body.angle)
    if self.body.isPickerUpper then
        self:drawPickerUpperBorder()
    end
    sprite(self.showing,0,0,self.width,self.height)
    popMatrix()
    popStyle()
end

function Card:drawPickerUpperBorder()
    pushStyle()
    pushMatrix()
    tint(204, 0, 255, 203)
   -- scale(self.borderScale.x, self.borderScale.y)
    sprite(self.showing,0,0,self.borderScale.x, self.borderScale.y)
    popMatrix()
    popStyle()
end

function Card:shortName()
    local suitInitial
    if self.suit == "spades" then
        suitInitial="S"
    elseif self.suit == "hearts" then
        suitInitial="H"
    elseif self.suit == "diamonds" then
        suitInitial="D"
    elseif self.suit == "clubs" then
        suitInitial="C"
    end
    return suitInitial..self.rank
end

function Card:touched(touch)
    --print("touch received by me, "..self.body.shortName)
    self.lastTouch = touch
    local touchPoint = vec2(touch.pos.x, touch.pos.y)
    local selfTapped = self.body:testPoint(touchPoint)
    if selfTapped and touch.tapCount == 2 and touch.state == ENDED then
        --print("you ended a tap on me, "..self.body.shortName)
      --  print("touchPoint: "..touchPoint.x.." "..touchPoint.y)
        if self.showing == self.back then
            self.showing = self.face
        else
            self.showing = self.back
        end
    end
    --[[
    if selfTapped and touch.state == MOVING then
        local previousAngle = self.body.angle
        self.body.position = touch.pos
        self.body.angle = previousAngle
    end
      ]]
end
--
function testCard()
    
    CodeaUnit.detailed = false
    CodeaUnit.skip = true
    
    _:describe("Testing Card", function()
        
        local card
        local fakedTouch
        local cardTable
        
        _:before(function()
            cardTable = CardTable()
            card = Card(7, "hearts")
            fakedTouch = fakeTouch()
            debugDraw:addBody(card.body)
            cardTable:addCard(card)
        end)
        
        _:after(function()
            debugDraw.touchMap[fakedTouch.id] = nil
            remove(debugDraw.bodies, card.body)
            cardTable:removeCard(card)
            card.body:destroy()
            card = nil
            fakedTouch = nil
            cardTable:destroyContents()
            cardTable = nil
        end)
        
        _:test("init with (1, allSuits[1]) is ace of spades", function()
            --remove(cardTable.cards, card) --without this the card from _:before() hangs around in cardTable
            local newCard = Card(1, Card.allSuits[1])
            local rightCard = newCard.suit == "spades" and newCard.rank == 1
            _:expect(rightCard).is(true)
        end)
        
        _:test("init with () is ace of spades", function()
            local cardo = Card()
            local rightCard = cardo.suit == "spades" and cardo.rank == 1
            _:expect(rightCard).is(true)
            cardo.body:destroy()
            cardo = nil
        end)
        
        _:test("'Card:shortName' of C10 is right", function()
            -- remove(cardTable.cards, card) --without this the card from _:before() hangs around in cardTable
            local cardy = Card(10, Card.allSuits[4])
            local shortName = cardy:shortName()
            _:expect(shortName == "C10").is(true)
        end)
        
        
        _:test("card detects touch set to x+1, y+1", function()
            fakedTouch.pos.x = card.body.x +1
            fakedTouch.pos.y = card.body.y +1
            _:expect(card.body:testPoint(fakedTouch.pos)).is(true)
        end)
        
        
        _:test("card retains last touch", function()
            card:touched(fakedTouch)
            local retained = fakedTouch == card.lastTouch
            _:expect("--a: touches aren't nil", fakedTouch ~= nil and card.lastTouch ~= nil).is(true)
            _:expect("--b: card retains last touch", retained).is(true)
        end)
        
        _:test("debugDraw sends BEGAN touch to card", function()
            card.body.x = WIDTH * 0.95
            card.body.y = HEIGHT * 0.95
            fakedTouch.pos.x = card.body.x +1
            fakedTouch.pos.y = card.body.y +1
            debugDraw:touched(fakedTouch)
            local gotFromDebug = fakedTouch == card.lastTouch
            _:expect(gotFromDebug).is(true)
        end)
        
        _:test("debugDraw sends ENDED touch to card", function()
            card.body.x = WIDTH * 0.95
            card.body.y = HEIGHT * 0.95
            fakedTouch = fakeTouch(card.body.x +1, card.body.y +1, ENDED, 1)
            debugDraw:addTouchToTouchMap(fakedTouch, card.body) --needed because this touchId won't be in touchmap because there was no beginning of it
            debugDraw:touched(fakedTouch)
            local gotFromDebug = fakedTouch == card.lastTouch
            _:expect(gotFromDebug).is(true)
        end)
        
        _:test("tap ending on card flips it over", function()
            card.showing = card.back
            -- print(card.showing)
            fakedTouch = fakeTouch(card.body.x +1, card.body.y +1, ENDED, 1)
            debugDraw:addTouchToTouchMap(fakedTouch, card.body)
            debugDraw:touched(fakedTouch)
            --print(card.showing, card.face)
            _:expect(tostring(card.showing) == tostring(card.face)).is(true)
        end)   
        
        _:test("converting a position to a single number and back", function() 
            local randomX, randomY = math.random(WIDTH), math.random(HEIGHT)
            card.body.position = vec2(randomX, randomY)
            local positionAsNumber = card:positionAsNumber()
            local numberAfterDecimal = positionAsNumber % 1
            local numberBeforeDecimal = positionAsNumber - numberAfterDecimal
            _:expect("positionAsNumber() before decimal is randomX", numberBeforeDecimal).is(randomX) 
            _:expect("positionAsNumber() after decimal is randomY", numberAfterDecimal).is(randomY)
        end)
    end)
end