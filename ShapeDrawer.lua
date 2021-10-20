ShapeDrawer = class()

function ShapeDrawer:init()
end

function ShapeDrawer:drawDebugging(physDD, screenReport, shouldDraw)  
    pushStyle()
    smooth()
    strokeWidth(5)
    stroke(128,0,128) -- purple
    if screenReport then
        pushStyle()
        fontSize(15)
        local xPos = WIDTH * 0.25
        textWrapWidth(WIDTH * 0.65)
        textMode(CORNER)        
        str = "debug.bodies: "..tableToString(physDD.bodies, "", true)
        local _, strH = textSize(str)
        fill(255, 14, 0)
        text(str, xPos, HEIGHT - strH - 10)        
        fill(0, 243, 255)
        local touchStr = "touchMap: "..tableToString(physDD.touchMap, "\n")
        local _, touchStrH = textSize(touchStr)
        text(touchStr, xPos, HEIGHT - strH - 10 - touchStrH - 10)        
        stacksString = "stacks: "..tableToString(cardTable.stacker.stacks[1], "\n")
        local _, stkStrH = textSize(stacksString)
        fill(92, 236, 67)
        text(stacksString, xPos, HEIGHT - strH - 10 - touchStrH - 10 - stkStrH - 20)    
    end    
    if shouldDraw then       
        stroke(0,255,0,255)
        strokeWidth(5)
        for k,joint in pairs(physDD.joints) do
            local a = joint.anchorA
            local b = joint.anchorB
            line(a.x,a.y,b.x,b.y)
        end     
        stroke(255,255,255,255)
        noFill()
        for i,body in ipairs(physDD.bodies) do
            pushMatrix()          
            if CodeaUnit.isRunning then 
                if not body or not body.x then
                    print("----", "body at index ", i)
                    print(body.position)
                    print(body, ", x: ", body.x, ", y: ", body.y)
                    print(body.shortName)
                    print("bodies: ", #physDD.bodies)
                    CodeaUnit.isRunning = false
                end
            end
            translate(body.x, body.y)
            rotate(body.angle)           
            if body.type == STATIC then
                stroke(255,255,255,255)
            elseif body.type == DYNAMIC then
                stroke(150,255,150,255)
            elseif body.type == KINEMATIC then
                stroke(150,150,255,255)
            end            
            if body.shapeType == POLYGON then
                strokeWidth(3.0)
                local points = body.points
                for j = 1,#points do
                    a = points[j]
                    b = points[(j % #points)+1]
                    line(a.x, a.y, b.x, b.y)
                end
            elseif body.shapeType == CHAIN or body.shapeType == EDGE then
                strokeWidth(3.0)
                local points = body.points
                for j = 1,#points-1 do
                    a = points[j]
                    b = points[j+1]
                    line(a.x, a.y, b.x, b.y)
                end
            elseif body.shapeType == CIRCLE then
                strokeWidth(3.0)
                line(0,0,body.radius-3,0)
                ellipse(0,0,body.radius*2)
            end           
            popMatrix()
        end
    end    
    stroke(255, 0, 0, 255)
    fill(255, 0, 0, 255)
    for k,v in pairs(physDD.contacts) do
        for m,n in ipairs(v.points) do
            ellipse(n.x, n.y, 10, 10)
        end
    end
    popStyle()
end

