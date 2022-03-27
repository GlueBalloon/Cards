CardTableWithCardsAsBodies = class()

CardTableWithCardsAsBodies.tableContainsCard = function (targetTable, card)
    local set = {}
    for k, l in pairs(targetTable) do set[l] = true end
    if set[card] then return true
    else return false end
end

function CardTableWithCardsAsBodies:init(startingPosition)
    physics.gravity(0,0)
    self.bounds = self:createScreenBorders()
    self.cards={}
    self.cardsWithBodiesAsKeys = {}
    local deck = CardTableWithCardsAsBodies.makeDeck(startingPosition)
    for i, card in ipairs(deck) do
        self:addCard(card)
        card.position = vec2(WIDTH/2, HEIGHT/2)
    end    
    self.stacker = CardStackerWithCardsAsBodies(self.cards)
    parameter.action("List table cards", function()
        local cardsString = ""
        for key, card in pairs(self.cards) do
            cardsString = cardsString.."["..tostring(key).."]:"..tostring(card.shortName).." "
        end
        print("cardTable keys, names:\n"..cardsString)
    end)
end

function CardTableWithCardsAsBodies:addCard(card)
    table.insert(self.cards, card)
    self.cards[card.shortName] = card
end

function CardTableWithCardsAsBodies:removeCard(card)
    remove(self.cards, card)
end

CardTableWithCardsAsBodies.makeDeck = function(startingPosition)
    local deck = {}
    for i,suit in ipairs(makeCardAsBody().allSuits) do
        for rank=2, 13 do
            table.insert(deck, makeCardAsBody(rank,suit,startingPosition))
        end
        table.insert(deck, makeCardAsBody(1,suit,startingPosition)) --put the ace at the end
    end
    return deck
end

function CardTableWithCardsAsBodies:createScreenBorders() --size is size of 3D box
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
    end
    return allBounds
end

function CardTableWithCardsAsBodies:destroyContents()
    self.stacker:clearContents()
    for key, card in pairs(self.cards) do
        self.cards[key] = nil
        card:destroy()
        card = nil
    end
    for key, bound in pairs(self.bounds) do
        bound:destroy()
    end
end

function CardTableWithCardsAsBodies:data()
    local positions, angles = {}, {}
    for _, card in ipairs(self.cards) do
    end
    return positions, angles
end

function CardTableWithCardsAsBodies:draw()
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
            local cardW, cardH = bottomCard.cardWidth, bottomCard.cardHeight
            local pos = bottomCard.position
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


function CardTableWithCardsAsBodies:touched(touch, bodies, firstBodyTouched)
    local indexOfFirstTouched
    if bodies then
        local swapDeck = {}
        for i, body in ipairs(bodies) do
            if body.class == "card" then
                swapDeck[#swapDeck + 1] = body
            end
        end
        if #swapDeck > 0 then
            self.cards = swapDeck
        end
    end
    
    if firstBodyTouched and firstBodyTouched.class then
        if firstBodyTouched.class == "card" then
            firstBodyTouched:touched(touch) 
        end
    end
end

function testCardTableWithCardsAsBodies()
    
    CodeaUnit.detailed = true
    CodeaUnit.skip = true
    
    _:describe("Testing CardTableWithCardsAsBodies", function()
        
        local cardTable
        
        _:before(function()
            cardTable = CardTable()
        end)
        
        _:after(function()
            cardTable:destroyContents()
            cardTable = nil
        end)
        
        _:test("does nothing", function()
            _:expect(true).is(true)
        end)
        
        _:test("makes 52 cards", function()
            _:expect(#cardTable.cards).is(52)
        end)
        
        _:test("makes right numbers of each suit", function()
            local spades, hearts, diamonds, clubs = 0,0,0,0
            for i,v in ipairs(cardTable.cards) do
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
        
        _:test("destroyContents() destroys cards", function()
            debugDraw:clear()
            --arrange
            local deckIsEmpty, contentsStrings = true, {}
            local startingPhysicsBodiesCount = #physics.bodies
            local noContentsStringInPhysicsBodies = true
            for _, v in pairs(cardTable.cards) do
                if v.body then
                    table.insert(contentsStrings, tostring(v.body))
                end
            end
            --act
            print(#physics.bodies, " ", #contentsStrings, " ", #debugDraw.bodies)
            cardTable:destroyContents()
            for _, value in pairs(cardTable.cards) do
                if value then 
                    deckIsEmpty = false 
                    break
                end
            end
            for _, value in pairs(contentsStrings) do
                for k, v in pairs(debugDraw.bodies) do
                    if value == tostring(v) then
                        debugDraw.bodies[k] = nil
                        v:destroy()
                    end
                end
                for i, v in pairs(physics.bodies) do
                    if value == tostring(v) then
                        noContentsStringInPhysicsBodies = false
                        v:destroy()
                    end
                end
            end
            _:expect("deckIsEmpty is true", deckIsEmpty).is(true)
            _:expect("number of physicsBodies is reduced by cards destroyed", #physics.bodies).is(startingPhysicsBodiesCount - #contentsStrings)
            _:expect("noContentsStringInPhysicsBodies", noContentsStringInPhysicsBodies).is(true)
        end)
        
        --[[
        _:test("destroyContents() destroys cards", function()
            print("#physics.bodies ", #physics.bodies)
            --arrange
            local deckIsEmpty, cardsWithBodiesAsKeysIsEmpty = true, true
            local contentsStringFoundInPhysicsBodies = false
            local contentsStrings = {}
            for _, v in pairs(cardTable.cards) do
               -- print(tostring(v))
                table.insert(contentsStrings, tostring(v))
            end
            print("contentsStringFoundInPhysicsBodies: ", contentsStringFoundInPhysicsBodies)
            --act
            cardTable:destroyContents()
            for _, value in pairs(cardTable.cards) do
                if value then deckIsEmpty = false end
            end
            for _, value in pairs(cardTable.cardsWithBodiesAsKeys) do
                if value then cardsWithBodiesAsKeysIsEmpty = false end
            end
            print("contentsStringFoundInPhysicsBodies: ", contentsStringFoundInPhysicsBodies)
            print("#physics.bodies ", #physics.bodies)
            local bodiesMatched = 0
            for _, value in pairs(contentsStrings) do
                for _, v in pairs(physics.bodies) do
                    if value == tostring(v) then
                        bodiesMatched = bodiesMatched + 1
                        contentsStringFoundInPhysicsBodies = true
                        print("CardTable tests: contentsStringFoundInPhysicsBodies: ", value)
                    end
                end
            end
            print("contentsStringFoundInPhysicsBodies: ", contentsStringFoundInPhysicsBodies)
            print("bodiesMatched: ", bodiesMatched)
            _:expect("deckIsEmpty is true", deckIsEmpty).is(true)
            _:expect("cardsWithBodiesAsKeysIsEmpty is true", cardsWithBodiesAsKeysIsEmpty).is(true)
            _:expect("contentsStringFoundInPhysicsBodies is false", contentsStringFoundInPhysicsBodies).is(false)
        end)
        ]]
        
        --[[
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
        ]]
    end)
end