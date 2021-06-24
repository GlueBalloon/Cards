CardStacker = class()

function CardStacker:init()
    self.stacks = {}
    print(#self.stacks)
end

--[[
function t   estCardStack() --have to mess up name or CodeaUnit tries to run it
    
    CodeaUnit.detailed = false
    
    local stack = CardStack(CardTable.makeDeck())
    
    _:describe("Testing CardStack", function()
        
        _:before(function()
        end)
        
        _:after(function()
        end)
        
        _:test("shuffling cards changes order of at least 20 cards", function()
            local referenceDeck = CardTable.makeDeck()
            local variationCount = 0
            stack:shuffle()
            for i, card in ipairs(referenceDeck) do
                if card.rank ~= stack.cards[i].rank or
                card.suit ~= stack.cards[i].suit then
                    variationCount = variationCount + 1
                end
            end
            _:expect(variationCount >= 20).is(true)
        end)
        
        _:test("cards in stack are not in debugdraw", function()
            local bodyNotFound = true
            for i, card in ipairs(stack.cards) do
                if debugDraw:hasBody(card.body) then
                    bodyNotFound = false
                    print("test: body found: "..tostring(card.body.info.kind))
                    break
                else
                --    print("test: body not found")
                end
            end
            _:expect(bodyNotFound).is(true)
        end)
    end)
end
  ]]

--[[
function CardStacker:init(startingCards)
    self.cards = {}
    self.width = WIDTH * 0.07
    self.height = WIDTH * 0.095
    self.body = createBox(WIDTH/2, 600, self.width, self.height)
    self.body.linearDamping = 4 --has something to do with momentum
    self.body.angularDamping = 5
    self.body.categories={2}
    self.body.mask={0}
    self.body.shirtName = "cardStack"
    self.image = 0
    --debugDraw:addBody(self.body)
    if startingCards then
        for i, card in ipairs(startingCards) do
            self:addCard(card)
        end
    end
  --  self:arrangeStack() --gotta change to just make stack
end
]]

function CardStacker:stackCards(...)
    table.insert(self.cards, card)
end

function CardStacker:shuffle()
    for i = #self.cards, 2, -1 do
        local j = math.random(i)
        self.cards[i], self.cards[j] = self.cards[j], self.cards[i]
    end
end

