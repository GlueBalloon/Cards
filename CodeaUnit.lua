--from an original by jakesankey

CodeaUnit = class()
CodeaUnit.isRunning = false
CodeaUnit.doBeforeAndAfter = true
CodeaUnit.overallSummary = {passed = 0, failed = 0, ignored = 0}

function CodeaUnit:describe(feature, allTests)
    if self.skip then
        print(string.format(" -------------\n|\n| %s\n| (Skipped)\n|\n -------------", feature))
    else
        print(string.format(" -------------\n|\n| %s\n|\n -------------", feature))
        self.testNum = 0
        self.subtests = 0
        self.totalTests = 0
        self.ignored = 0
        self.failures = 0
        self.message = "message not set"
        self.debugReporting = false
        self._before = function()
        end
        self._after = function()
        end
        
        allTests()
        
        local passed = self.totalTests - self.failures
        self.overallSummary.passed = self.overallSummary.passed + passed
        self.overallSummary.failed = self.overallSummary.failed + self.failures
        self.overallSummary.ignored = self.overallSummary.ignored + self.ignored
        local summary = string.format("\t----------\n\tPass: %d\n\tIgnore: %d\n\tFail: %d", passed, self.ignored, self.failures)
        
        print(summary)
    end
end

function CodeaUnit:debugPrint(...)
    if self.debugReporting then
        print(...)
    end
end

function CodeaUnit:before(setup)
    self._before = setup
end

function CodeaUnit:after(teardown)
    self._after = teardown
end

function CodeaUnit:ignore(description, scenario)
    self.description = tostring(description or "")
    self.testNum = self.testNum + 1
    self.ignored = self.ignored + 1
    if CodeaUnit.detailed then
        print(string.format("%d: %s -- Ignored", self.testNum, self.description))
    end
end

function CodeaUnit:test(description, scenario)
    self.testNum = self.testNum + 1
    self.totalTests = self.totalTests + 1
    self._before()
    self.description = tostring(description or "")
    local status, err = pcall(scenario)
    if err then
        self.failures = self.failures + 1
        print(string.format("%d: %s -- %s", self.testNum, self.description, err))
    end
    self._after()
    if self.subtests ~= 0 then
        self.totalTests = self.totalTests + self.subtests
    end
    self.subtests = 0
    self.description = nil
    self.message = nil
end

--function CodeaUnit:expect(conditional)
--takes one or two arguments
--can take just the expected value, or a name for this individual 'expect' call plus the expected value
--this allows multiple 'expect' calls in a single test to all show different titles
function CodeaUnit:expect(...)
    --set local variables
    local args = {...}
    local expectationString = "Expected"
    local multiTest = false
    local thisExpectTitle = nil
    local conditional = nil
    --function to turn all args into strings (including nil)
    local argsToStrings = function(...)
        local given = {...}
        local argsAsStrings = {}
        local numArgs = select("#", ...)
        for i = 1, numArgs do
            self:debugPrint("arg "..i..": ", tostring(given[i]))
            table.insert(argsAsStrings, tostring(given[i]))
        end
        return argsAsStrings
    end
    --function for turning a number into a letter
    local function letterFromNum(i)
        local encoding = "abcdefghijklmnopqrstuvwxyz"
        return encoding:sub(i,i)
    end
    --get all args as strings
    local argStrings = argsToStrings(...)
    --set multitest and thisExpectTitle
    if #argStrings == 2 then 
        multiTest = true 
        thisExpectTitle = argStrings[1]
    end 
    
    self.message = string.format("%d. %s:", (self.testNum or 1), self.description)
    if not multiTest then
        conditional = args[1]
        self:debugPrint("not multitest, conditional: ", conditional)
    elseif #args == 2 then
        local premessage = ""
        self.subtests = self.subtests + 1
        if self.subtests == 1 then
            premessage = string.format("%s\n\n", self.message)
        end
        conditional = args[2]
        self.message = string.format("%s %d%s. %s", premessage, (self.testNum or 1), letterFromNum(self.subtests), args[1])
    end
    
    local passed = function()
        if CodeaUnit.detailed then
            print(string.format("%s\n  %s: %s\n  -- OK", self.message, expectationString, self.expected))
        end
    end
    
    local failed = function()
        self.failures = self.failures + 1
        local actual = tostring(conditional)
        local expected = tostring(self.expected)
        print(string.format("%s\n  %s: %s\n  -- FAIL: found %s", self.message, expectationString, expected, actual))
    end
    
    local notify = function(result)
        if result then
            passed()
        else
            failed()
        end
    end
    
    local is = function(expected, epsilon)

        self.expected = expected
        if epsilon then
            expectationString = "Expected (epsilon "..tostring(epsilon)..")"
            notify(expected - epsilon <= conditional and conditional <= expected + epsilon)
        else
            expectationString = "Expected"
            notify(conditional == expected)
        end
    end
    
    local isnt = function(expected)
        expectationString = "Expected not"
        self.expected = expected
        notify(conditional ~= expected)
    end
    
    local has = function(expected)
        expectationString = "Expected to include"
        self.expected = expected
        local found = false
        for i,v in pairs(conditional) do
            if v == expected then
                found = true
            end
        end
        if not found then
            conditional = "no such value"
        end
        notify(found)
    end
    
    local throws = function(expected)
        expectationString = "Expected throws"
        self.expected = expected
        local status, error = pcall(conditional)
        if not error then
            conditional = "nothing thrown"
            notify(false)
        else
            notify(string.find(error, expected, 1, true))
        end
    end
    
    return {
        is = is,
        isnt = isnt,
        has = has,
        throws = throws
    }
end

function CodeaUnit:draw()
    if self.overallSummary.passed ~= 0 
    or self.overallSummary.failed ~= 0
    or self.overallSummary.ignored ~= 0 then
        pushStyle()
        fill(181)
        if self.overallSummary.failed > 0 then 
            fill(255, 14, 0)
        elseif self.overallSummary.passed > 0 then
            fill(59, 255, 0)
        end
        font("AmericanTypewriter-Bold")
        fontSize(WIDTH * 0.02)
        textAlign(CENTER)
        local drawString = "Test Summary\npassed: "..
        tostring(self.overallSummary.passed)..
        "\nfailed: "..tostring(self.overallSummary.failed)..
        "\nignored: "..tostring(self.overallSummary.ignored)
        local w, h = textSize(drawString)
        text("Test Summary\npassed: "..tostring(self.overallSummary.passed)..
        "\nfailed: "..tostring(self.overallSummary.failed)..
        "\nignored: "..tostring(self.overallSummary.ignored), WIDTH / 2, HEIGHT - (h) )
        popStyle()
    end
end

CodeaUnit.execute = function()
    CodeaUnit.isRunning = true
    for i,v in pairs(listProjectTabs()) do
        local source = readProjectTab(v)
        for match in string.gmatch(source, "function%s-(test.-%(%))") do
            load(match)()
        end
    end
end

CodeaUnit.detailed = true



_ = CodeaUnit()

parameter.action("CodeaUnit Runner", function()
    CodeaUnit.overallSummary = {passed = 0, failed = 0, ignored = 0}
    CodeaUnit.execute()
end)

--[[
function t estCodeaUnitFunctionality()
    _.detailed = false
    _.skip = false
    
    _:describe("CodeaUnit tests", function()
        
        _:before(function()
        end)
        
        _:after(function()
        end)
        
        _:test("HOOKUP", function()
            _:expect("testing fooness", "Bar").is("Bar")
        end)
        
        _:test("Floating point epsilon", function()
            _:expect(1.45).is(1.5, 0.1)
        end)
        
        _:test("can set testInt", function()
            local testInt = 4
            _:expect(testInt).is(4)
        end)
        
    end)
end
]]