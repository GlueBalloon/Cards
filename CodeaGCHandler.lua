
--a wrapper for the GameCenter access functions and client state
CodeaGCHandler = class()

function CodeaGCHandler:init()
    self:defaultAllFlags()
    self.nickname = ""
    self.hostName = ""
end

function CodeaGCHandler:defaultAllFlags()
    self.attemptingAuthentication = false
    self.authenticationStatus = false
    self.isMatching = false
    self.inMatch = false
    self.isHosting = false
end

function CodeaGCHandler:gcAuthenticate()
    if not self.authenticationStatus then
        self.attemptingAuthentication = true
        gcAuthenticate()
    end
end

function CodeaGCHandler:gcAuthenticationFinished(successFlag)
    if successFlag == 1 then
        self.authenticationStatus = true 
    else 
        self.authenticationStatus = false 
    end
    self.attemptingAuthentication = false
end

function CodeaGCHandler:startMatching()
    if not self.authenticationStatus then return end
    startMatching()
    self.isMatching = true
end

function CodeaGCHandler:matchingFinished(int)
    self.isMatching = false 
    if int == 0 then
        self.inMatch = false
    elseif int == 1 then
        self.inMatch = true
    end
end

function CodeaGCHandler:checkHosting()
    checkHosting()
end

function CodeaGCHandler:sendTouchMap()
    sendTouchMap()
end

function CodeaGCHandler:checkReceivedTouchMaps()
    checkReceivedTouchMaps()
end

function CodeaGCHandler:sendLocationsAndAngles()
    sendLocationsAndAngles()
end

function CodeaGCHandler:checkLocationsAndAngles()
    checkLocationsAndAngles()
end

function CodeaGCHandler:sendCardsShowing()
    sendCardsShowing()
end

function CodeaGCHandler:checkCardsShowing()
    checkCardsShowing()
end

--actual functions corresponding to CodeaAddOn for GameCenter 
--functions, these have to be globals for CodeaAddOn to link
--to them

--called FROM ObjC to have effects IN CODEA:
function gcAuthenticationFinished(successFlag,  optionalGCHandler)
    local GCH = optionalGCHandler or G.gcHandler
    GCH:gcAuthenticationFinished(successFlag)
end

function gcMatchingFinished(int, optionalGCHandler)
    local GCH = optionalGCHandler or G.gcHandler
    GCH:matchingFinished(int)
end

function gcNicknameFound(nickName, optionalGCHandler)
    local GCH = optionalGCHandler or G.gcHandler
    GCH.nickname = nickName
end

function gcHostAssigned(nickName, optionalGCHandler)
    local GCH = optionalGCHandler or G.gcHandler
    GCH.hostName = nickName
end

--called BY Codea for USE in ObjC--therefore bodies are empty:
function gcAuthenticate()
end

function startMatching()    
end



function checkMatching()
    
end

function checkHosting()
    
end

function sendTouchMap()
    
end

function checkReceivedTouchMaps()

end

function sendLocationsAndAngles()
    
end

function checkLocationsAndAngles()
    
end

function sendCardsShowing()
    
end

function checkCardsShowing()
    
end


function testGameCenter()
    CodeaUnit.detailed = true
    CodeaUnit.skip = true
    -- local shouldWipeDebugDraw = false
    
    _:describe("Testing CodeaGCHandler", function()
        _:before(function()
        end)     
        _:after(function()
        end)
        
        local G1, G2 = Globals(), Globals()
        local GCH = G1.gcHandler
        
        local function randomize(cards) 
            for i, card in ipairs(cards) do
                card.body.position = vec2(math.random(WIDTH), math.random(HEIGHT))
                card.body.angle = math.random(360)
            end
            return cards
        end
        
        _:test("authentication states tracked", function()
            GCH:gcAuthenticate()
            _:expect("can tell when authenticating", GCH.attemptingAuthentication).is(true)
            _:expect("during authentication causes authenticationStatus == false ", GCH.authenticationStatus).is(false)
            gcAuthenticationFinished(1, GCH)
            _:expect("successful authentication causes authenticationStatus == true ", GCH.authenticationStatus).is(true)
            _:expect("successful authentication causes attemptingAuthentication == false ", GCH.attemptingAuthentication).is(false)
            GCH:defaultAllFlags()
            GCH:gcAuthenticate()
            gcAuthenticationFinished(0, GCH)
            _:expect("failed authentication keeps authenticationStatus == false ", GCH.authenticationStatus).is(false)
            _:expect("failed authentication causes attemptingAuthentication == false ", GCH.attemptingAuthentication).is(false)
        end)
        
        _:test("can capture game center nickname", function()
            GCH:gcAuthenticate()
            gcAuthenticationFinished(1, GCH)
            gcNicknameFound("fakeNameForSelf", GCH)
            _:expect("name stored correctly ", GCH.nickname).is("fakeNameForSelf")
        end)
        
        _:test("isMatching correctly tracked", function()
            GCH:startMatching()
            _:expect("isMatching == false when matching starts before authentication", GCH.isMatching).is(false)
            gcAuthenticationFinished(1, GCH)
            GCH:startMatching()
            _:expect("isMatching == true when matching starts after authenticated", GCH.isMatching).is(true)
            gcMatchingFinished(0, GCH)
            _:expect("isMatching == false when matching ends with failure", GCH.isMatching).is(false)
            _:expect("inMatch == false when matching ends with failure", GCH.inMatch).is(false)
            GCH:defaultAllFlags()
            GCH:gcAuthenticate()
            gcAuthenticationFinished(1, GCH)
            GCH:startMatching()
            gcMatchingFinished(1, GCH)
            _:expect("isMatching == false when matching ends with success", GCH.isMatching).is(false)
            _:expect("inMatch == true when matching ends with success", GCH.inMatch).is(true)
        end)     
        
        _:test("hosting assignment works", function()
            gcNicknameFound("fakeNameForSelf", GCH)
            gcHostAssigned("fakeOtherPlayer", GCH)
            _:expect("hostname can be assigned to other nickname", GCH.hostName).is("fakeOtherPlayer")
            gcHostAssigned("fakeNameForSelf", GCH)
            _:expect("hostname can be assigned to self", GCH.hostName).is(GCH.nickname)
        end)
        
        _:test("card position sending", function()
            local function confirmSyncedCardPositions(globals1, globals2) 
                local cardsAndBodiesExist, synced = true, true
                local card2
                for _, card in ipairs(globals1.cardTable.cards) do
                    card2 = globals2.cardTable.cards[card.body.shortName]
                    if card == nil or card2 == nil or card.body == nil or card2.body == nil then
                        cardsAndBodiesExist = false
                    end
                    if (card.body.position ~= card2.body.position) or
                    (card.body.angle ~= card2.body.angle) then
                        synced = false
                        --print("shortNames: ", card.body.shortName, card2.body.shortName)
                        --print("positions: ", card.body.position, card2.body.position)
                        --print("angles: ", card.body.angle, card2.body.angle)    
                    end
                end
                return cardsAndBodiesExist, synced
            end
            randomize(G1.cardTable.cards)
            local g1Positions, g1Angles = G1.cardTable:data()
            local existGood, syncGood = confirmSyncedCardPositions(G1, G2)
            _:expect("cards and bodies exist", existGood).is(true)
            _:expect("positions and angles synced", syncGood).is(true)
            --scatter cards
        end)      
    end)
end
