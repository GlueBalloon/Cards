function jankyTouch(touchMap)   
    --why is the physics part of this in draw()?
    --solve this by killing the touchMap if a touch reverses direction?
    for touchId, mappedTouch in pairs(touchMap) do
        --print("tracking "..touchId)
        local gain = 100 --affects how far blocks go when flung
        local damp = 8 --affects how quickly they slow down
        local worldAnchor = mappedTouch.body:getWorldPoint(mappedTouch.anchor) --where the point the body was first touched is now in world coordinates
        local touchPoint = mappedTouch.tp --where the actual touch is now
        local diff = touchPoint - worldAnchor --distance as vec2
        local vel = mappedTouch.body:getLinearVelocityFromWorldPoint(worldAnchor) --??
        --v.body:applyForce( (1/1) * diff * gain - vel * damp, worldAnchor)
        mappedTouch.body:applyForce( (1/1) * diff * gain - vel * damp, worldAnchor) --shove the body
        line(touchPoint.x, touchPoint.y, worldAnchor.x, worldAnchor.y)
        --apply a slightly different force to any cards following this touch
        gain =  90
        damp =  7
        for _, body in ipairs(mappedTouch.followers) do
            local angleDiff = body.angle - mappedTouch.body.angle
            if angleDiff > 10 then
                body:applyTorque(math.random(-840,-800))
            elseif angleDiff < -10 then
                body:applyTorque(math.random(800, 840))
            end
            worldAnchor = body:getWorldPoint(vec2(0,0)) --the center of the body in world coordinates
            vel = body:getLinearVelocityFromWorldPoint(worldAnchor)
            diff = touchPoint - worldAnchor
            --print("follower is: "..body.shortName)
            -- body.x, body.y, body.angle = mappedTouch.body.x, mappedTouch.body.y, mappedTouch.body.angle
            body:applyForce( (1/1) * diff * gain - vel * damp, body:getWorldPoint(vec2(0,0))) --shove the body
        end   
    end
end

function bestTouch(touchMap)
    --why is the physics part of this in draw()?
    --solve this by killing the touchMap if a touch reverses direction?
    for touchId, mappedTouch in pairs(touchMap) do
        --print("tracking "..touchId)
        local gain = 100 --affects how far blocks go when flung
        local damp = 8 --affects how quickly they slow down
        local worldAnchor = mappedTouch.body:getWorldPoint(mappedTouch.anchor) --where the point the body was first touched is now in world coordinates
        local touchPoint = mappedTouch.tp --where the actual touch is now
        local diff = touchPoint - worldAnchor --distance as vec2
        local vel = mappedTouch.body:getLinearVelocityFromWorldPoint(worldAnchor) --??
        --v.body:applyForce( (1/1) * diff * gain - vel * damp, worldAnchor)
        mappedTouch.body:applyForce( (1/1) * diff * gain - vel * damp, worldAnchor) --shove the body
        line(touchPoint.x, touchPoint.y, worldAnchor.x, worldAnchor.y)
        --apply a slightly different force to any cards following this touch
        gain =  90
        damp =  7
        for _, body in ipairs(mappedTouch.followers) do
            local angleDiff = body.angle - mappedTouch.body.angle
            if angleDiff > 10 then
                body:applyTorque(math.random(-840,-800))
            elseif angleDiff < -10 then
                body:applyTorque(math.random(800, 840))
            end
            worldAnchor = body:getWorldPoint(vec2(0,0)) --the center of the body in world coordinates
            vel = body:getLinearVelocityFromWorldPoint(worldAnchor)
            diff = touchPoint - worldAnchor
            --print("follower is: "..body.shortName)
            -- body.x, body.y, body.angle = mappedTouch.body.x, mappedTouch.body.y, mappedTouch.body.angle
            body:applyForce( (1/1) * diff * gain - vel * damp, body:getWorldPoint(vec2(0,0))) --shove the body
        end       
    end
end
