function testGameCenter()
    CodeaUnit.detailed = true
    CodeaUnit.skip = false
    -- local shouldWipeDebugDraw = false
    
    _:describe("Testing CodeaGCHandler", function()
        _:before(function()
        end)     
        _:after(function()
        end)

        _:test("authentication syncing", function()
            checkAuthentication = function() return 1 end
            G.gcHandler:syncAuthenticationStatus()
            _:expect("can tell when authenticated", G.gcHandler.isAuthenticated).is(true)
            checkAuthentication = function() return 0 end
            G.gcHandler:syncAuthenticationStatus()
            _:expect("can tell when not authenticated", G.gcHandler.isAuthenticated).is(false)
        end)
        
        _:test("matching", function()
            G.gcHandler:startMatching()
            _:expect("can start matching", G.gcHandler.isMatching).is(true)
            checkMatching = function() return 1 end
            G.gcHandler:syncMatchingStatus()
            _:expect("can tell when in match", G.gcHandler.inMatch).is(true)
            checkMatching = function() return 0 end
            G.gcHandler:syncMatchingStatus()
            _:expect("can tell when not matching", G.gcHandler.inMatch).is(false)
        end)
        
        _:test("gc touch sharing functions", function()
            
        end)
    end)
end
