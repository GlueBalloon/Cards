function testCard()
    
    CodeaUnit.detailed = false
    CodeaUnit.skip = true
    
    _:describe("Testing Card", function()
        
        local card
        local fakedTouch
        
        _:before(function()
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
    end)
end