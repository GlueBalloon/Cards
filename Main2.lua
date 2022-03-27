


function setup()
    
    bodiesDetectingMetatable = {}
    bodiesDetectingMetatable.trackedTables = {}
    bodiesDetectingMetatable.__newindex = function(owningTable, index, newValue)
        local isRigidbody = string.sub(tostring(newValue), 1, 9) == "rigidbody"
        if isRigidbody then
            print("physics body detected: ", newValue)
            rawset(bodiesDetectingMetatable.trackedTables, #bodiesDetectingMetatable.trackedTables + 1, newValue)
        end
        rawset(owningTable, index, newValue)
    end
    bodiesDetectingMetatable.__index = function(owningTable, index)
        return rawget(owningTable, index)
    end
    
    globalsMetatable = {}
    globalsMetatable.trackedTables = {}
    globalsMetatable.__newindex = function(owningTable, index, newValue)
        rawset(owningTable, index, newValue) 
        if type(newValue) == "table" then
            if rawget(globalsMetatable.trackedTables, index) == nil then
                rawset(globalsMetatable.trackedTables, index, newValue)
                if getmetatable(newValue) == nil then
                    setmetatable(newValue, bodiesDetectingMetatable)
                end
            end          
        end
    end
    globalsMetatable.__index = function(owningTable, index)
        return rawget(owningTable, index)
    end
    setmetatable(_G, globalsMetatable)
    flopp = {}
    print("#_G: ", #_G)

    --holy shit, could convert card to body entirely:
    bbb = physics.body(CIRCLE, 10)
    print(bbb)
    flopp[1] = bbb
    
    ggg = physics.body(CIRCLE, 10)
    plomp = {}
    plomp[1] = ggg
    
    
    if false then
    function bbb:func()
        print(self.position)
        print("fooooooooo")
    end
    bbb:func()
        
--[[
    local C = {
        const1 = 12,
        const2 = "asdf",
    }
    setmetatable(_G, {
        __metatable = false,
        __index = C,
        __newindex = function(t, k, v)
            if C[k] ~= nil then
                error("Attempted to write to global constant "..k)
            else
                rawset(t, k, v)
            end
            if type(v) == "table" then print("table") end
        end
    })

print(const1) -- 12
print(const2) -- asdf
    
    loof = 5
    bobo = {}
    ]]
    --[[
    emptyMeta = {}
    anyLittleOlTable = {}
    setmetatable(anyLittleOlTable, emptyMeta)
    
    anyLittleOlTable[1] = "gooba"
    print("anyLittleOlTable[1]: ", anyLittleOlTable[1]) --prints 'gooba'
    
    emptyMeta.__index = function(tableBeingAccessed, key)
    end
    emptyMeta.__newindex = function(tableBeingAccessed, key, newValue)
    end
    
    anyLittleOlTable[2] = "fooba" --now uses metatable __newindex, which does nothing
    print("anyLittleOlTable[1] again: ", anyLittleOlTable[1]) --still print 'gooba'
    print("anyLittleOlTable[2]: ", anyLittleOlTable[2]) --prints nil
    
    emptyMeta.__newindex = function(tableBeingAccessed, key, newValue)
        rawset(tableBeingAccessed, key, newValue)
    end
    anyLittleOlTable[2] = "fooba" --now __newindex passes value to main table
    print("anyLittleOlTable[2] again: ", anyLittleOlTable[2]) --prints 'fooba'
    
    emptyMeta.__newindex = function(tableBeingAccessed, key, newValue)
        rawset(tableBeingAccessed, key, tostring(newValue).." better than ever")
    end
    anyLittleOlTable[3] = "balooba" --now __newindex passes adjusted value to main table
    print("anyLittleOlTable[3]: ", anyLittleOlTable[3]) --prints 'balooba  better than ever'
    anyLittleOlTable[2] = "joojoojooba" --value NOT adjusted; index 2  already exists so __newindex NOT called
    print("anyLittleOlTable[2] again again: ", anyLittleOlTable[2]) --prints only 'joojoojooba'
    ]]
    
    bodiesDetecter = {}
    bodiesDetecter.tablesWithBodies = {}
    bodiesDetecter.__newindex = function(tableUsed, index, newValue)
        rawset(tableUsed, index, newValue)
        if newValue.shortName ~= nil then
            if rawget(bodiesDetecter.tablesWithBodies, tableUsed) == nil then
                print("Added to bodiesDetecter.tablesWithBodies: ", tableUsed)
                rawset(bodiesDetecter.tablesWithBodies, tableUsed, debug.traceback())
                rawset(bodiesDetecter.tablesWithBodies, #bodiesDetecter.tablesWithBodies + 1, tableUsed)
            end
        end
    end
    bodiesDetecter.__index = function(tableUsed, index)
        return rawget(tableUsed, index)
    end
    
    bodiesDetecterAssigner = {}
    bodiesDetecterAssigner.assigned = {}
    bodiesDetecterAssigner.__newindex = function(tableUsed, index, newValue)
        rawset(tableUsed, index, newValue)
        if type(newValue) == "table" then
            if rawget(bodiesDetecterAssigner.assigned, newValue) == nil then
                print("_G added to bodiesDetecterAssigner.assigned: ", newValue)
                rawset(bodiesDetecterAssigner.assigned, newValue, debug.traceback())
                setmetatable(newValue, bodiesDetecter)
                
            end
        end
    end
    bodiesDetecterAssigner.__index = function(tableUsed, index)
        return rawget(tableUsed, index)
    end
    
    setmetatable(_G, bodiesDetecterAssigner)
    
    dummyTable = {}
    print("metatable is: ", getmetatable(dummyTable))
    body1 = physics.body(CIRCLE, 20)
    body1.shortName = "body1"
    dummyTable[1] = body1
    
    if false then
    tableHas, tableHas2 = {}, {}
    print(getmetatable(tableHas))
    body1 = physics.body(CIRCLE, 20)
    body1.shortName = "body1"
    body2 = physics.body(CIRCLE, 20)
    body2.shortName = "body2"
    tableHas[1] = body1
    table.insert(tableHas2, body2)
    print("should be stored: ", tableHas, ", ", tableHas2)
    local found = "found stored tables: "
    for k, v in pairs(bodiesDetecter.tablesWithBodies) do
        found = found.." - "..tostring(v)
        end
        end
    end
    
    --one globals global to rule them all
    G = {}
    --G.physics = PhysicsLab()
    G.gcHandler = CodeaGCHandler()
    debugDraw = PhysicsDebugDraw()
    table.insert(debugDraw.touchMapFunctions, bestTouch)
    table.insert(debugDraw.touchMapFunctions, checkForPickupMode)
    cardTable = CardTable()
    G.cardTable = cardTable
    for i=1, #cardTable.bounds do
        debugDraw:addBody(cardTable.bounds[i])
    end
    tests = {cardTable}
    setTest(1)
    defaultGravity = physics.gravity()
    print("globals metatable: ", getmetatable(_G))
    --[[
    print("#debugDraw.bodies before testCircle: ", #debugDraw.bodies)
    local testCircle = createCircle(300, 150, 10)
    print("#debugDraw.bodies after testCircle created: ", #debugDraw.bodies)
    local i, removeAtI = 1, nil
    while removeAtI == nil do
        if debugDraw.bodies[i] == testCircle then
            removeAtI = i
        end
        i = i + 1 
    end
    print("removeAtI: ", removeAtI)
    table.remove(debugDraw.bodies, removeAtI)
    print("#debugDraw.bodies after testCircle removed: ", #debugDraw.bodies)
    testCircle:destroy()
    print("#debugDraw.bodies after testCircle destroyed: ", #debugDraw.bodies)
    local dummy
    local i = 1
    while dummy == nil do
        if debugDraw.bodies[i] == testCircle then
            dummy = debugDraw.bodies[i]
            break
        end
        i = i + 1
        if i == 53 then break end
    end
    if dummy == testCircle then
        print("Body still in table after destruction")
    else
        print("Body not in table after destruction")
    end
    
    testCircle = nil
    print("52: ", debugDraw.bodies[52])
    print("53: ", debugDraw.bodies[53])
    ]]
end

function setTest(t)
    if currentTest then
        if currentTest.cleanup then
            currentTest:cleanup()
        end
        cleanup()
    end
    currentTest = tests[t]
    currentTest:setup()
end

function separateArrayAndHashTablesIn(thisTable)
    local arrayTable, hashTable = {}, {}
    for k, v in pairs(thisTable) do
        if type(k) == "number" and k == math.ceil(k) then
            arrayTable[k] = v
        else
            hashTable[k] = v
        end
    end
    return arrayTable, hashTable
end
    
function isarray(tableT)   
    --has to be a table in the first place of course
    if type(tableT) ~= "table" then return false end  
    --not sure exactly what this does but piFace wrote it and it catches most cases all by itself
    local piFaceTest = #tableT > 0 and next(tableT, #tableT) == nil
    if piFaceTest == false then return false end  
    --must have a value for 1 to be an array
    --if tableT[1] == nil then return false end
    --all keys must be integers from 1 to #tableT for this to be an array
    --for k, v in pairs(tableT) do
    --    if type(k) ~= "number" or (k > #tableT) or(k < 1) or math.floor(k) ~= k  then return false end
    --end  
    --every numerical key except the last must have a key one greater
    for k,v in ipairs(tableT) do
        if tonumber(k) ~= nil and k ~= #tableT then
          if tableT[k+1] == nil then
                return false
            end
        end
    end   
    --otherwise we probably got ourselves an array
    return true
end

--from https://stackoverflow.com/questions/12394841/safely-remove-items-from-an-array-table-while-iterating
function remove(targetTable, removeMe)
    --check if this is an array
    if isarray(targetTable) then
        --flag for when a table needs to squish in to fill cleared space
        local shouldMoveDown = false
        --iterate over table in order
        for i = 1, #targetTable do
            --check if the value is found
            if targetTable[i] == removeMe then
                --if so, set flag to start collapsing the table to write over it
                shouldMoveDown = true
            end
            --if collapsing needs to happen...
            if shouldMoveDown then
                --copy the next value over this one
                targetTable[i] = targetTable[i+1]
            end
        end
    else
        --if not an array, loop over elements
        for k, v in pairs(targetTable) do
            --check for thing to remove
            if (v == removeMe) then
                --if found, nil it
                targetTable[k] = nil
                break
            end
        end
    end
    return targetTable, removeMe;
end

function tableHas(targetTable, lookForMe)
    local validKeys = {}
    for _, element in pairs(targetTable) do
        validKeys[element] = true
    end
    if validKeys[lookForMe] then
        return true, lookForMe
    else
        return false
    end
end

function createCircle(x,y,r)
    local circle = physics.body(CIRCLE, r)
    -- enable smooth motion
    circle.interpolate = true
    circle.x = x
    circle.y = y
    circle.restitution = 0.25
    circle.sleepingAllowed = false
    debugDraw:addBody(circle)
    return circle
end

function createBox(x,y,w,h)
    -- polygons are defined by a series of points in counter-clockwise order
    local box = physics.body(POLYGON, vec2(-w/2,h/2), vec2(-w/2,-h/2), vec2(w/2,-h/2), vec2(w/2,h/2))
    box.interpolate = true
    box.x = x
    box.y = y
    box.restitutions = 0.25
    box.sleepingAllowed = false
    debugDraw:addBody(box)
    return box
end

function createGround()
    local groundLevel = 50 + layout.safeArea.bottom
    local ground = physics.body(POLYGON, vec2(0,groundLevel), vec2(0,0), vec2(WIDTH,0), vec2(WIDTH,groundLevel))
    ground.type = STATIC
    debugDraw:addBody(ground)
    return ground
end

function createRandPoly(x,y)
    local count = math.random(3,10)
    local r = math.random(25,75)
    local a = 0
    local d = 2 * math.pi / count
    local points = {}

    for i = 1,count do
        local v = vec2(r,0):rotate(a) + vec2(math.random(-10,10), math.random(-10,10))
        a = a + d
        table.insert(points, v)
    end


    local poly = physics.body(POLYGON, table.unpack(points))
    poly.x = x
    poly.y = y
    poly.sleepingAllowed = false
    poly.restitution = 0.25
    debugDraw:addBody(poly)
    return poly
end

function cleanup()
    output.clear()
    debugDraw:clear()
end

-- This function gets called once every frame
function draw()

    -- This sets the background color to black
    background(0, 0, 0)

    --[[
    if TestNumber ~= currentTestIndex then
        setTest(TestNumber)
    end
      ]]
    cardTable:draw()
    debugDraw:draw()
    _:draw()
    
    --[[
    local str = string.format("Test %d - %s", 1, currentTest.title)

    font("Vegur-Bold")
    fontSize(22)
    fill(255, 255, 255, 255)


    text(str, WIDTH/2, HEIGHT - layout.safeArea.top - 18)
    textWrapWidth(WIDTH-20)
      ]]
    
    if UseAccelerometer == true then
        physics.gravity(Gravity)
    else
        physics.gravity(defaultGravity)
    end
end

function touched(touch)
    debugDraw:touched(touch)
   -- if debugDraw:touched(touch) == false then
        --print("sending touch to card table from main")
        --cardTable:touched(touch)
   -- end
end

function fakeTouch(x, y, state, tapCount, id, prevPos)
    local fakeTouch = {}
    fakeTouch.id = id or 1000
    fakeTouch.type = DIRECT
    fakeTouch.state = state or BEGAN
    fakeTouch.pos = vec2(x or 50, y or 50)
    fakeTouch.tapCount = tapCount or nil
    fakeTouch.prevPos = prevPos or nil
    return fakeTouch
end

function collide(contact)
    if debugDraw then
        debugDraw:collide(contact)
    end
    if currentTest and currentTest.collide then
        currentTest:collide(contact)
    end
end

function stringIfBody(possible)
    local str = ""
    if string.sub(tostring(possible), 1, 9) == "rigidbody" then
        str = str.."body("
        if possible.shortName then
            str = str..possible.shortName
        else
            str = str.."unknown"
        end
        str = str..")"
        return str
    else
        return possible
    end
end

function tableToString(tTable, separator, preserveOrder)
    if not separator then separator = "" end
    local returnString = separator.."{   "..separator
    local tableWithDescriptiveBodies, thisKey = {}, ""
    --go through given table
    for k, v in pairs(tTable) do
        --make concatenatable string for value because it could be a table
        local valueString = ""
        --keep key in its original type if number or string
        if type(k) ~= "string" and type(k) ~= "number" then
            thisKey = stringIfBody(k)
        else
            thisKey = k
        end
        --if value is a table, recursively make a string from it
        if type(v) == "table" then   
            --remove the colon from tostring(v) because it's visually confusing with the colons used between tables and keys
            valueString = valueString.."table#"..string.sub(tostring(v), 8)
            --prevent endless loop if table contains reference to itself  
            if(v==tTable) then           
                valueString = valueString..": <-(self reference)"         
            else            
                valueString = valueString.." "..tableToString(v)       
            end       
        else --if not a table:
            --format value string specially for functions
            if type(v) == "function" then           
                valueString = valueString..tostring(v).."()"        
            else         
                --create descrptive string from value   
                valueString = valueString..tostring(stringIfBody(v))
            end    
        end
        --store descriptive values either under number indexes or descriptive strings
        tableWithDescriptiveBodies[thisKey] = valueString
    end
    --separate tables to store i,v pairs and k, v pairs as strings
    local ivStrings, kvStrings = {}, {}
    --first turn i,v pairs into strings, keeping them in order
    for i = #tableWithDescriptiveBodies, 1, -1 do
        table.insert(ivStrings, 1, "["..i.."]: "..tableWithDescriptiveBodies[i])
        --remove used value
        tableWithDescriptiveBodies[i] = nil
    end
    --now iterate through all keys left and make k,v strings
    for k, v in pairs(tableWithDescriptiveBodies) do
        table.insert(kvStrings, "["..tostring(k).."]: "..v)
    end
    if #ivStrings == 0 and #kvStrings == 0 then
        return "{}"
    end
    if #ivStrings ~= 0 then
        returnString = returnString.."///indexed/// "
        for i, v in ipairs(ivStrings) do
            returnString = returnString..v
            if i ~= #ivStrings then
                returnString = returnString..", "
            else
                returnString = returnString.."  "
            end
        end
    end
    if #kvStrings ~= 0 then
        if #ivStrings ~= 0 then
            returnString = returnString..separator
        end
        returnString = returnString.."///keys/// "
        for i, v in ipairs(kvStrings) do
            returnString = returnString..v        
            if i ~= #ivStrings then
                returnString = returnString..", "
            else
                returnString = returnString.."  "
            end
        end
    end  
    return returnString.."\t"..separator.."}"
end

parameter.boolean("breakpointsEnabled", false)

breakpoint = function()
    if not breakpointsEnabled then return end
    print("tap tab to advance a line, type 'qq' to exit breakpoints")
    local buffer = ""
    showKeyboard()
    while buffer ~= "\t" do
        buffer = keyboardBuffer()
        bufferLength = string.len(buffer)
        buffer = string.sub(buffer, string.len(buffer)-1)
        if buffer == "qq" then
            buffer = "\t"
            breakpointsEnabled = false
        end
    end
    hideKeyboard()
end
