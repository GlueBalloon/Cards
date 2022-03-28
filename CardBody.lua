
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
        local selfTouched = self:testPoint(touch.pos)
        if not selfTouched or touch.state == ENDED or
        touch.state == CANCELLED then
            self.lastTouch = nil
        else
            self.lastTouch = touch
        end
        self:showSideBasedOn(touch)
    end
    
    
    function newCard:showSideBasedOn(touch)
        if touch.tapCount == 2 and touch.state == ENDED then
            if self.showing == self.back then
                self.showing = self.face
            else
                self.showing = self.back
            end
        end
    end
        
    function newCard:positionToDecimalNumber()
        local xAsNotDecimal = self.position.x - (self.position.x % 1)
        local yAsDecimal = (self.position.y - (self.position.y % 1)) * 0.0001
        return xAsNotDecimal + yAsDecimal
    end
    
    function newCard:setPositionFromDecimalNumber(decimalNumber)
        local numberAfterDecimal = decimalNumber % 1
        local numberBeforeDecimal = decimalNumber - numberAfterDecimal
        self.position = vec2(numberBeforeDecimal, numberAfterDecimal * 10000)
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
        local debugDraw
        
        _:before(function()
            cardTable = CardTableForCardBodies()
            debugDrawForCardBodies = DebugDrawForCardBodies(cardTable)
            card = makeCardAsBody(7, "hearts")
            card.shortName = "testCard"
            fakedTouch = fakeTouch()
            debugDrawForCardBodies:addBody(card)
            cardTable:addCard(card)
        end)
        
        _:after(function()
            debugDrawForCardBodies.touchMap[fakedTouch.id] = nil
            remove(debugDrawForCardBodies.bodies, card)
            cardTable:removeCard(card)
            card:destroy()
            fakedTouch = nil
            cardTable:destroyContents()
            cardTable = nil
            debugDrawForCardBodies:clear()
            debugDrawForCardBodies = nil
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
            _:expect("touches aren't nil", fakedTouch ~= nil and card.lastTouch ~= nil).is(true)
            _:expect("card retains last touch", retained).is(true)
            fakedTouch.pos.x = card.x + card.cardWidth * 2
            fakedTouch.pos.y = card.y + card.cardHeight * 2
            card:touched(fakedTouch)
            retained = fakedTouch == card.lastTouch
            _:expect("card does not capture touch outside its bounds", retained).is(false)
        end)
        
        _:test("debugDraw sends BEGAN touch to card", function()
            card.x = WIDTH * 0.95
            card.y = HEIGHT * 0.95
            fakedTouch.pos.x = card.x +1
            fakedTouch.pos.y = card.y +1
            debugDrawForCardBodies:touched(fakedTouch)
            local cardStoresTouch = fakedTouch == card.lastTouch
            _:expect("touch captured when began", cardStoresTouch).is(true)
            fakedTouch.state = ENDED
            card:touched(fakedTouch)
            cardStoresTouch = fakedTouch == card.lastTouch
            _:expect("touch cleared when ENDED", cardStoresTouch == false).is(true)
            fakedTouch.state = BEGAN
            card:touched(fakedTouch)
            cardStoresTouch = fakedTouch == card.lastTouch
            _:expect("touch re-captured to set up next expectation", cardStoresTouch).is(true)
            fakedTouch.state = CANCELLED
            card:touched(fakedTouch)
            cardStoresTouch = fakedTouch == card.lastTouch
            _:expect("touch cleared when CANCELLED", cardStoresTouch == false).is(true)
        end)
        
        _:test("tap ending on card flips it over", function()
            card.showing = card.back
            fakedTouch = fakeTouch(card.x +1, card.y +1, ENDED, 2)
            fakedTouch.tapCount = 2
            card:touched(fakedTouch)
            --print(card.showing, card.face)
            _:expect(tostring(card.showing) == tostring(card.face)).is(true)
        end)   
        
        _:test("converting a position to a single number and back", function() 
            local randomX, randomY = math.random(WIDTH), math.random(HEIGHT)
            card.position = vec2(randomX, randomY)
            local positionAsNumber = card:positionToDecimalNumber() or 0
            local numberAfterDecimal = positionAsNumber % 1
            local numberBeforeDecimal = positionAsNumber - numberAfterDecimal
            _:expect("positionAsNumber() before decimal is randomX", numberBeforeDecimal).is(randomX, 0.1) 
            _:expect("positionAsNumber() after decimal is randomY", numberAfterDecimal * 10000).is(randomY, 0.1)
            local randomlySetX, randomlySetY = math.random(WIDTH), math.random(HEIGHT)
            local numberForPosition = randomlySetX + ((randomlySetY) * 0.0001)
            card:setPositionFromDecimalNumber(numberForPosition)
            _:expect("setPositionFromDecimalNumber(number) sets correct x", card.x).is(randomlySetX, 0.1) 
            _:expect("setPositionFromDecimalNumber(number) sets correct y", card.y).is(randomlySetY, 0.1)
        end)
    end)
end