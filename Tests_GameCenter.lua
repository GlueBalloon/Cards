function testGameCenter()
    CodeaUnit.detailed = true
    CodeaUnit.skip = false
    -- local shouldWipeDebugDraw = false
    
    _:describe("Testing CodeaGCHandler", function()
        _:before(function()
        end)     
        _:after(function()
        end)

        _:test("authentication states tracked", function()
            local GCH = Globals().gcHandler
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
            local GCH = Globals().gcHandler
            GCH:gcAuthenticate()
            gcAuthenticationFinished(1, GCH)
            gcNicknameFound("fakeNameForSelf", GCH)
            _:expect("name stored correctly ", GCH.nickname).is("fakeNameForSelf")
        end)
        
        _:test("isMatching correctly tracked", function()
            local GCH = Globals().gcHandler
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
            local GCH = Globals().gcHandler
            gcNicknameFound("fakeNameForSelf", GCH)
            gcHostAssigned("fakeOtherPlayer", GCH)
            _:expect("hostname can be assigned to other nickname", GCH.hostName).is("fakeOtherPlayer")
            gcHostAssigned("fakeNameForSelf", GCH)
            _:expect("hostname can be assigned to self", GCH.hostName).is(GCH.nickname)
        end)
        
        _:test("card position sending", function()
            local G1 = Globals()
            local G2 = Globals()
            --G2.cardTable.cards[1].x = 300000
            local function randomize(G1) end
            local function confirmSyncedCardPositions(globals1, globals2) 
                local synced = true
                for _, card in ipairs(globals1.cardTable.cards) do
                    local card2 = globals2.cardTable.cards[card.body.shortName]
                    if (card.body.position ~= card2.body.position) or
                        (card.body.angle ~= card2.body.angle) then
                        synced = false
                        print(card.body.shortName, card2.body.shortName)
                        print(card.body.position, card2.body.position)
                        print(card.body.angle, card2.body.angle)
                        break
                    end
                end
                return synced
            end
            _:expect("can detect identical card positions", confirmSyncedCardPositions(G1, G2)).is(true)
            --scatter cards
        end)      
    end)
end
