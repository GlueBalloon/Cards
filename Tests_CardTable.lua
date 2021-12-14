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
        
    end)
end