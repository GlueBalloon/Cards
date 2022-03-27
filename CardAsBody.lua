
function makeCardAsBody(rank, suit, startingPosition, angle)
    
    function shortNameFrom(card)
        local suitInitial
        if card.suit == "spades" then
            suitInitial="S"
        elseif card.suit == "hearts" then
            suitInitial="H"
        elseif card.suit == "diamonds" then
            suitInitial="D"
        elseif card.suit == "clubs" then
            suitInitial="C"
        end
        return suitInitial..card.rank
    end
    
    local hypoSquared = (WIDTH*WIDTH)+(HEIGHT*HEIGHT)
    local hypotenoooooose = math.sqrt(hypoSquared)
    local cardWidth = hypotenoooooose * 0.0853333
    local cardHeight = hypotenoooooose * 0.1196666
    local newCard = createBox(WIDTH/2, cardHeight * 0.6, cardWidth, cardHeight)
    newCard.cardWidth = cardWidth
    newCard.cardHeight = cardHeight
    newCard.allSuits = {"spades", "hearts", "diamonds", "clubs"}
    newCard.rank = rank or 1
    newCard.suit = suit or "spades"
    newCard.position = startingPosition or vec2(0, 0)
    newCard.angle = angle or 0
    newCard.linearDamping = 4 --has something to do with momentum
    newCard.angularDamping = 5
    newCard.categories={2}
    newCard.mask={1} --setting to zero becomes 1 for some reason
    newCard.class = "card"
    newCard.shortName = shortNameFrom(newCard)
    newCard.back = asset.cardBackMonkey
    newCard.face = asset[newCard.shortName..".png"]
    newCard.showing = newCard.back
    newCard.lastTouch = {}
    local borderSize = cardWidth / 10
    newCard.borderScale = vec2(cardWidth + borderSize, cardHeight + borderSize)
    newCard.isPickerUpper = false
    
    function newCard:draw()
        pushStyle()
        pushMatrix()
        resetMatrix()
        translate(self.x,self.y)
        rotate(self.angle)
        if self.isPickerUpper then
            self:drawPickerUpperBorder()
        end
        sprite(self.showing,0,0,self.cardWidth, self.cardHeight)
        popMatrix()
        popStyle()
    end
    
    function newCard:drawPickerUpperBorder()
        pushStyle()
        pushMatrix()
        tint(204, 0, 255, 203)
        sprite(self.showing,0,0,self.borderScale.x, self.borderScale.y)
        popMatrix()
        popStyle()
    end
    
    function newCard:touched(touch)
        self.lastTouch = touch
        local touchPoint = vec2(touch.pos.x, touch.pos.y)
        local selfTapped = self:testPoint(touchPoint)
        if selfTapped and touch.tapCount == 2 and touch.state == ENDED then
            if self.showing == self.back then
                self.showing = self.face
            else
                self.showing = self.back
            end
        end
    end
    
    function newCard:positionAsNumber()
        
    end
    
    return newCard
end

function testCardAsBody()
    
    CodeaUnit.detailed = true
    CodeaUnit.skip = false
    
    _:describe("Testing CardAsBody", function()
        
        local card
        local fakedTouch
        local cardTable
        
        _:before(function()
            cardTable = CardTableWithCardsAsBodies()
            card = makeCardAsBody(7, "hearts")
            fakedTouch = fakeTouch()
            debugDraw:addBody(card)
            cardTable:addCard(card)
        end)
        
        _:after(function()
            debugDraw.touchMap[fakedTouch.id] = nil
            remove(debugDraw.bodies, card)
            cardTable:removeCard(card)
            card:destroy()
            fakedTouch = nil
            cardTable:destroyContents()
            cardTable = nil
        end)
        
        _:test("init with (1, allSuits[1]) is ace of spades", function()
            local newCard = makeCardAsBody(1, Card.allSuits[1])
            local rightCard = newCard.suit == "spades" and newCard.rank == 1
            _:expect(rightCard).is(true)
        end)
        
        _:test("init with () is ace of spades", function()
            local cardo = makeCardAsBody()
            local rightCard = cardo.suit == "spades" and cardo.rank == 1
            _:expect(rightCard).is(true)
            cardo:destroy()
            cardo = nil
        end)
        
        _:test("'Card:shortName' of C10 is right", function()
            -- remove(cardTable.cards, card) --without this the card from _:before() hangs around in cardTable
            local cardy = makeCardAsBody(10, Card.allSuits[4])
            _:expect(cardy.shortName == "C10").is(true)
        end)
        
        
        _:test("card detects touch set to x+1, y+1", function()
            fakedTouch.pos.x = card.x +1
            fakedTouch.pos.y = card.y +1
            _:expect(card:testPoint(fakedTouch.pos)).is(true)
        end)
        
        
        _:test("card retains last touch", function()
            card:touched(fakedTouch)
            local retained = fakedTouch == card.lastTouch
            _:expect("--a: touches aren't nil", fakedTouch ~= nil and card.lastTouch ~= nil).is(true)
            _:expect("--b: card retains last touch", retained).is(true)
        end)
        
        _:test("debugDraw sends BEGAN touch to card", function()
            card.x = WIDTH * 0.95
            card.y = HEIGHT * 0.95
            fakedTouch.pos.x = card.x +1
            fakedTouch.pos.y = card.y +1
            debugDraw:touched(fakedTouch)
            local gotFromDebug = fakedTouch == card.lastTouch
            _:expect(gotFromDebug).is(true)
        end)
        
        _:test("debugDraw sends ENDED touch to card", function()
            card.x = WIDTH * 0.95
            card.y = HEIGHT * 0.95
            fakedTouch = fakeTouch(card.x +1, card.y +1, ENDED, 1)
            debugDraw:addTouchToTouchMap(fakedTouch, card) --needed because this touchId won't be in touchmap because there was no beginning of it
            debugDraw:touched(fakedTouch)
            local gotFromDebug = fakedTouch == card.lastTouch
            _:expect(gotFromDebug).is(true)
        end)
        
        _:test("tap ending on card flips it over", function()
            card.showing = card.back
            -- print(card.showing)
            fakedTouch = fakeTouch(card.x +1, card.y +1, ENDED, 1)
            debugDraw:addTouchToTouchMap(fakedTouch, card)
            debugDraw:touched(fakedTouch)
            --print(card.showing, card.face)
            _:expect(tostring(card.showing) == tostring(card.face)).is(true)
        end)   
        
        _:test("converting a position to a single number and back", function() 
            local randomX, randomY = math.random(WIDTH), math.random(HEIGHT)
            card.position = vec2(randomX, randomY)
            local positionAsNumber = card:positionAsNumber()
            local numberAfterDecimal = positionAsNumber % 1
            local numberBeforeDecimal = positionAsNumber - numberAfterDecimal
            _:expect("positionAsNumber() before decimal is randomX", numberBeforeDecimal).is(randomX) 
            _:expect("positionAsNumber() after decimal is randomY", numberAfterDecimal).is(randomY)
        end)
    end)
end