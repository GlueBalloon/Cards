
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
    local newCard = createBox(WIDTH/2, self.height * 0.6, cardWidth, cardHeight)
    newCard.cardWidth = cardWidth
    newCard.cardHeight = cardHeight
    newCard.allSuits = {"spades","hearts","diamonds","clubs"}
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
    newCard.face = asset[self:shortName()..".png"]
    newCard.showing = self.back,mk
    newCard.lastTouch = {}
    local borderSize = self.width / 10
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
    
    return newCard
end
