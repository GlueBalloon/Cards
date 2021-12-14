--[[
function testGameCenter()
    CodeaUnit.detailed = true
    CodeaUnit.skip = true
    -- local shouldWipeDebugDraw = false
    
    _:describe("Testing CodeaGCHandler et al", function()
        _:before(function()
        end)     
        _:after(function()
        end)

        _:test("authentication functions", function()
            _:expect("can confirm authentication", G.gcHandler.isAuthenticated).is(true)
        end)
    end)
end
]] 