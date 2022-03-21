Globals = class()

function Globals:init(x)
    self.physics = PhysicsLab()
    self.gcHandler = CodeaGCHandler()
    self.debugDraw = PhysicsDebugDraw()
    table.insert(self.debugDraw.touchMapFunctions, bestTouch)
    table.insert(self.debugDraw.touchMapFunctions, checkForPickupMode)
    self.cardTable = CardTable()
end

function Globals:draw()
    -- Codea does not automatically call this method
end

function Globals:touched(touch)
    -- Codea does not automatically call this method
end
