function testCardStacker()
    
    CodeaUnit.detailed = false
    CodeaUnit.skip = false
    
    _:describe("Testing Stacker", function()
        
        local stacker
        local deck
        local card
        
        _:before(function()
            deck = CardTable.makeDeck()
            stacker = CardStacker(deck)
            card = Card(12, "clubs")
        end)
        
        _:after(function()
            debugDraw:removeAndDestroyThoughYouStillGottaNilManually(card.body)
            card.body = nil
            card = nil
            for i = #deck, 1, -1 do
                local card = deck[i]
                debugDraw:removeAndDestroyThoughYouStillGottaNilManually(card.body)
                card.body = nil
                card = nil
            end
            deck = nil
            stacker = nil
        end)
        
        _:test("if all cards in one place, stacker stacks all in one stack", function()
            _:expect(#stacker.stacks[1]).is(52)
        end)
        
        _:test("correctly reports cards within minimum distance of each other", function()
            local card1, card2 = deck[1], deck[2]
            local testDistance = card1.width * 0.25
            local insideMaximum = testDistance * 0.4
            card2.body.position = card2.body.position + vec2(insideMaximum, insideMaximum)
            local reportsTrueWhenTrue = stacker:cardsAreWithinDistance(card1, card2, testDistance)
            card2.body.position = card2.body.position + vec2(testDistance, testDistance)
            local reportsFalseWhenFalse = not stacker:cardsAreWithinDistance(card1, card2, testDistance)
            _:expect(reportsTrueWhenTrue and reportsFalseWhenFalse).is(true)
        end)
        
        _:test("refreshStacks() does not duplicate stacks", function()
            stacker:refreshStacks() --will already have been called once during init
            _:expect(#stacker.stacks).is(1)
        end)
        
        _:test("if all cards in one place, hashtable links each card to same stack", function()
            local allSameStack, hashTableHasCardsInIt = true, true
            stacker:refreshStacks()
            local theOneTrueStack = stacker.stacks[1]
            local unused, cardsOnly = separateArrayAndHashTablesIn(stacker.stacks)
            local cardsCount = 0
            for k, linkedTable in pairs(cardsOnly) do
                cardsCount = cardsCount + 1
                if linkedTable ~= theOneTrueStack then allSameStack = false end
            end
            if cardsCount ~= 52 then hashTableHasCardsInIt = false end
            --print("allSameStack, hashTableHasCardsInIt: ", allSameStack, ",", hashTableHasCardsInIt)
            _:expect(allSameStack and hashTableHasCardsInIt).is(true)
        end)
        
        _:test("testsOfCardsAtMultipleLocations", function() 
            
            local distanceOffset = deck[1].width * 0.5
            local position1 = vec2(10, 10)
            local position2 = vec2(distanceOffset * 1.25, distanceOffset * 1.25)
            local position3 = vec2(distanceOffset * -2, distanceOffset * -2)
            local testStack1, testStack2, testStack3 = {}, {}, {}
            
            --separate cards into three positions
            for i, card in ipairs(deck) do
                if i % 3 ~= 0 then
                    card.body.position = position3
                    table.insert(testStack3, card)
                elseif i % 2 ~= 0 then
                    card.body.position = position2
                    table.insert(testStack2, card)
                else
                    card.body.position = position1
                    table.insert(testStack1, card)
                end
            end
            
            local stacks = stacker:tablesOfCardsCloserThan(distanceOffset, deck)
            _:expect("--a: three piles returns three tables", #stacks).is(3)
                      
            local hashesAreRight = true
            for i, card in ipairs(deck) do
                --check if card is hashed to a table
                local hashedTable = stacks[card]
                if not hashedTable then 
                    hashesAreRight = false
                --check if card is actually in that table
                elseif not tableHas(hashedTable, card) then 
                    hashesAreRight = false 
                end
                --check if the card is also in other tables
                for i, stack in ipairs(stacks) do
                    if stack ~= hashedTable then
                        if tableHas(stack, card) then hashesAreRight = false end
                    end
                end
            end
            _:expect("--b: all cards hash to correct stack", hashesAreRight).is(true)
        end)
    end)
end

CardStacker = class()

function CardStacker:init(cards)
    self.stacks = {}
    self.cards = cards
    self.radiusForStacking = self.cards[1].width * 0.3
    self:refreshStacks()
end

function CardStacker:cardsAreWithinDistance(card1, card2, maxDistance)
    local distance = card1.body.position:dist(card2.body.position)
    return distance <= maxDistance
end

function CardStacker:tablesOfCardsCloserThan(maxDistance, cards)
    local cardsAtLocations = {}
    for i, card in ipairs(cards) do
        --a flag for needing to create a new location
        local cardWasAddedToGroup = false
        --go over indexed locations
        for i, thisTable in ipairs(cardsAtLocations) do
            local firstCardLocation = thisTable[1].body.position
            --if card is close enough, add it to the table
            if card.body.position:dist(firstCardLocation) <= maxDistance then
                table.insert(thisTable, card)
                --and hash the card to that table
                cardsAtLocations[card] = thisTable
                --and flip the flag
                cardWasAddedToGroup = true
            end
        end
        --if card hasn't been put in a table, it's at its own location
        if not cardWasAddedToGroup then
            --so add a new table in cardsAtLocations
            table.insert(cardsAtLocations, {card})
            --and hash this card to it
            cardsAtLocations[card] = cardsAtLocations[#cardsAtLocations]
        end
    end
    return cardsAtLocations
end

function CardStacker:refreshStacks()
    self.stacks = self:tablesOfCardsCloserThan(self.radiusForStacking, self.cards)
end

function CardStacker:shuffle()
    for i = #self.cards, 2, -1 do
        local j = math.random(i)
        self.cards[i], self.cards[j] = self.cards[j], self.cards[i]
    end
end