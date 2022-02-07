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
        gain =  100
        damp =  8
        for _, body in ipairs(mappedTouch.followers) do
            local distanceFromTopCard = body.position:dist(mappedTouch.body.position)
            if distanceFromTopCard > 100 then
                local topCardCenter = mappedTouch.body:getWorldPoint(vec2(0,0))
                worldAnchor = body:getWorldPoint(vec2(0,0)) --the center of the body in world coordinates
                vel = body:getLinearVelocityFromWorldPoint(worldAnchor)
                --  diff = touchPoint - worldAnchor
                diff = topCardCenter - worldAnchor
                --print("follower is: "..body.shortName)
                -- body.x, body.y, body.angle = mappedTouch.body.x, mappedTouch.body.y, mappedTouch.body.angle
                body:applyForce( (1/1) * diff * gain - vel * damp, body:getWorldPoint(vec2(0,0))) --shove the body
            else
                local keepAngle = body.angle
                body.position = mappedTouch.body.position 
                body.angle = keepAngle
            end   
            
            
            
            local angleDiff = body.angle - mappedTouch.body.angle
            
            if math.abs(angleDiff % 180) > 3 and (not body.keepSkew) then
                --print(angleDiff % 180)
                local vel=angleDiff % 180
                if math.abs(vel)>=180 then
                    vel=vel*-1
                end
                vel=math.min(50,math.max(-50,vel))
                body.angularVelocity=vel*6
            elseif not body.keepSkew then
                body.keepSkew = angleDiff % 180
                body.angularVelocity=0
            else
                body.angle = mappedTouch.body.angle + body.keepSkew
            end
            
            --[[
            
            if math.abs(angleDiff) > 3 and (not body.angleSkew)then
                body.cachedDamping = body.angularDamping
                body.angularDamping = 0
                local anglePredicted = body.angle + (body.angularVelocity / 3)
                local predictedDiff = mappedTouch.body.angle % 360 - anglePredicted % 360
                if math.abs(predictedDiff) >= 180 then predictedDiff = predictedDiff * -1 end
                predictedDiff=math.min(50,math.max(-50,predictedDiff))        
                local torque = 1000
                if predictedDiff < 0 then torque = torque * -1 end
                local speed = 2.9
                body:applyTorque(torque*speed) 
            elseif body.cachedDamping then
                body.angularDamping = body.cachedDamping
                body.cachedDamping = nil
                body.angleSkew = angleDiff 
                body.angle = mappedTouch.body.angle - body.angleSkew
            elseif body.angleSkew then
                body.angle = mappedTouch.body.angle + body.angleSkew
            end
            
]]
            --[[
            if angleDiff > 10 then
                body:applyTorque(math.random(-840,-800))
            elseif angleDiff < -10 then
                body:applyTorque(math.random(800, 840))
            end
            ]]
        end
    end
end
    
function checkForPickupMode(touchMap)
    for touchId, mappedTouch in pairs(touchMap) do
        if (mappedTouch.tp == mappedTouch.startPoint) and 
            (ElapsedTime - mappedTouch.startTime > 0.5) then
            mappedTouch.body.isPickerUpper = true
        end
    end
end

function pastBestTouch(touchMap)
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
