function testRootFunctions()
    CodeaUnit.detailed = false
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
                    print("test found unmatched item:")
                    print(testTable[i], correctResult[i])
                    result = false
                end
            end
            print(table.unpack(testTable))
            print(#testTable, #correctResult)
            if #testTable ~= #correctResult then 
                print("wrong count")
                result = false 
            end
            _:expect(true).is(result)
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
            if false then
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