

Card = class()
Card.allSuits = {"spades","hearts","diamonds","clubs"}

function Card:init(rank, suit)
    --print("making card")
    --card dimensions are 64mm/89mm
    self.rank = rank or 1
    self.suit = suit or "spades"
    local hypoSquared = (WIDTH*WIDTH)+(HEIGHT*HEIGHT)
    local hypotenoooooose = math.sqrt(hypoSquared)
    self.width = hypotenoooooose * 0.0853333
    self.height = hypotenoooooose * 0.1196666
    self.body = createBox(WIDTH/2, self.height * 0.6, self.width, self.height)
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
