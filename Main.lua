
--saveImage("Project:Icon", readImage(asset.preview))
 
function testRootFunctions()
    CodeaUnit.detailed = true
    CodeaUnit.skip = true
    -- local shouldWipeDebugDraw = false
    
    _:describe("Testing root functions", function()
        _:before(function()
        end)     
        _:after(function()
        end)
        parameter.watch()
        _:test("isArray(...) works", function()
            local result = true     
            local resultString = ""     
            _:expect("--a: empty table", isarray{}).is(false)
            _:expect("--b: array of numbers", isarray{1, 2, 3}).is(true)
            _:expect("--c: array with repeating numbers", isarray{1, 2, 3, 2, 3, 1, 3}).is(true)
            _:expect("--d: letter keys with number values", isarray{a = 1, b = 2, c = 3}).is(false)
            _:expect("--e: mixed array/non-array", isarray{1, 2, 3, a = 1, b = 2, c = 3}).is(false)
            _:expect("--f: 'sparse array' with nil", isarray{1, 2, 3, nil, 5}).is(false)
            _:expect("--g: table of doubles", isarray{1.22, 2.22, 3.22, 4.22, 5.22}).is(true)
            _:expect("--h: table with doubles as keys", isarray{[1.22] = 33, [2.22] = 9, [3.22] = 202, [4.22] = 6, [5.22] = 11}).is(false)
        end)
        
        _:test("remove(...) extracts right string element from array", function()
            local testTable = {"this ", "sentence", "is ", "not ",  "right"}
            local correctResult = {"this ", "sentence", "is ",  "right"}
            testTable = remove(testTable, "not ")
            local result = true
            for i=1, #testTable do
                if testTable[i] ~= correctResult[i] then
                    result = false
                end
            end
            --print(table.unpack(testTable))
            if #testTable ~= #correctResult then result = false end
            _:expect(result).is(true)
        end)
        
        _:test("remove(...) extracts right number from array", function()
            local testTable = {8, 12, 8, 12, 14,  0}
            local correctResult = {8, 8, 12, 14, 0}
            testTable = remove(testTable, 12)
            local result = true
            for i,v in ipairs(testTable) do
                if testTable[i] ~= correctResult[i] then
                    result = false
                end
            end
            --[[
            print(isarray(testTable))
            print(table.unpack(testTable))
              ]]
            if #testTable ~= #correctResult then result = false end
            _:expect(result == true and #testTable ~= 0).is(true)
        end)
        
        _:test("remove(...) deletes last string value in hash when it matches target value", function()
            local testTable = {a = "this ", g = "sentence", b = "is ", l = "right ", v = "not"}
            local correctResult = {a = "this ", g = "sentence", b = "is ", l = "right "}
            testTable = remove(testTable, "not")
            local result = true
            for k,v in pairs(testTable) do
                if testTable[k] == valueToZap then
                    result = false
                    break
                end
            end          
            _:expect(result).is(true)
        end)
        
        _:test("remove(...) deletes right value element from table", function()
            local testTable = {1, 2, a = "this", m = " sentence", ["the word is"] = " is", " not",  " right"}
            local correctResult = {1, 2, a = "this", m = " sentence", ["the word is"] = " is",  " right"}
            local valueToZap = " not"
            testTable = remove(testTable, " not")
            local result = true
            local testString = "testTable string:\n"
            for k,v in pairs(testTable) do
                testString = testString.."["..tostring(k).."]:"..tostring(v).." "
                if testTable[k] == valueToZap then
                    result = false
                    break
                end
            end
            --print(testString)
            testString = "correctResult string:\n"
            for k,v in pairs(correctResult) do
                testString = testString.."["..tostring(k).."]:"..tostring(v).." "
            end
            --print(testString)
            _:expect(result).is(true)
        end)
        
        _:test("separateArrayAndHashTablesIn(...) returns correct tables", function()
            --create result flags
            local totalResult, arrayCountRight, arrayResult, hashCountRight, hashResult
            --make test table 
            local tableForKey = {}
            local testTable = {[1] = "one", [2] = "two", [4] = "four", [10] = "ten", 
                ["red"] = "foo1", ["five"] = "foo2", [tableForKey] = "foo3", [3.3] = "three point three"}
            --make verification tables to check results against
            local correctArray = {}
            table.insert(correctArray, "one"); table.insert(correctArray, "two"); correctArray[4] = "four"; correctArray[10] = "ten"
            local correctHash = {[3.3] = "three point three", ["red"] = "foo1", ["five"] = "foo2", [tableForKey] = "foo3"}
            --run the function
            local returnedArray, returnedHash = separateArrayAndHashTablesIn(testTable)
            --inspect counts
            local arrayCounter = 0
            for i, v in pairs(returnedArray) do
                arrayCounter = arrayCounter + 1
            end
            arrayCountRight = arrayCounter == 4
            local hashCounter = 0
            for i, v in pairs(returnedHash) do
                hashCounter = hashCounter + 1
            end
            hashCountRight = hashCounter == 4
            --inspect contents
            if arrayCountRight and hashCountRight then
                arrayResult = true 
                hashResult = true 
                for k, v in pairs(correctArray) do
                    if v ~= returnedArray[k] then arrayResult = false end
                end
                for k, v in pairs(correctHash) do
                    if v ~= returnedHash[k] then hashResult = false end
                end
            end
            function stringFrom(thisTable)
                local returnString = ""
                for k, v in pairs(thisTable) do
                    returnString = returnString.."("..tostring(k).." : "
                    returnString = returnString..tostring(v)..") "
                end
                return returnString
            end
            --debugging statements: change to "if false" to turn off
            if true then
                print("correctArray: "..stringFrom(correctArray))
                print("returnedArray: "..stringFrom(returnedArray))
                print("correctHash: "..stringFrom(correctHash))
                print("returnedHash: "..stringFrom(returnedHash))
                print("arrayCountRight: ", arrayCountRight)
                print("arrayResult: ", arrayResult)
                print("hashCountRight: ", hashCountRight)
                print("hashResult: ", hashResult)
            end
            --overall result is AND combination of all results
            totalResult = arrayCountRight and arrayResult and hashCountRight and hashResult
            _:expect(totalResult).is(true)
        end)
    end)
end

function setup()
    debugDraw = PhysicsDebugDraw()
    table.insert(debugDraw.touchMapFunctions, jankyTouch)
    cardTable = CardTable()
    tests = {cardTable}
    setTest(1)
    defaultGravity = physics.gravity()
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
      --  cardTable:touched(touch)
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