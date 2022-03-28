CardStackerForCardBodies = class()

function CardStackerForCardBodies:init(cards)
    self.stacks = {}
    self.cards = cards
    self.radiusForStacking = self.cards[1].cardWidth * 0.3
    self:refreshStacks()
end

function CardStackerForCardBodies:clearContents()
    self.stacks = {}
    self.cards = {}
end

function CardStackerForCardBodies:cardsAreWithinDistance(card1, card2, maxDistance)
    local distance = card1.position:dist(card2.position)
    return distance <= maxDistance
end

function CardStackerForCardBodies:tablesOfCardsCloserThan(maxDistance, cards)
    local cardsAtLocations = {}
    for i, card in ipairs(cards) do
        --a flag for needing to create a new location
        local cardWasAddedToGroup = false
        --go over indexed locations
        for i, thisTable in ipairs(cardsAtLocations) do
            local firstCardLocation = thisTable[1].position
            --if card is close enough, add it to the table
            if not card or not card.position then
                goto skip
            end
            if card.position:dist(firstCardLocation) <= maxDistance then
                table.insert(thisTable, card)
                --and hash the card to that table
                cardsAtLocations[card] = thisTable
                --and flip the flag
                cardWasAddedToGroup = true
            end
            ::skip::
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

function CardStackerForCardBodies:refreshStacks()
    self.stacks = self:tablesOfCardsCloserThan(self.radiusForStacking, self.cards)
end

function CardStackerForCardBodies:shuffle()
    for i = #self.cards, 2, -1 do
        local j = math.random(i)
        self.cards[i], self.cards[j] = self.cards[j], self.cards[i]
    end
end