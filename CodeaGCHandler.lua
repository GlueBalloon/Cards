
--a wrapper for the GameCenter access functions and client state
CodeaGCHandler = class()

function CodeaGCHandler:init()
    self:defaultAllFlags()
    self.nickname = ""
    self.hostName = ""
end

function CodeaGCHandler:defaultAllFlags()
    self.attemptingAuthentication = false
    self.authenticationStatus = false
    self.isMatching = false
    self.inMatch = false
    self.isHosting = false
end

function CodeaGCHandler:gcAuthenticate()
    if not self.authenticationStatus then
        self.attemptingAuthentication = true
        gcAuthenticate()
    end
end

function CodeaGCHandler:gcAuthenticationFinished(successFlag)
    if successFlag == 1 then
        self.authenticationStatus = true 
    else 
        self.authenticationStatus = false 
    end
    self.attemptingAuthentication = false
end

function CodeaGCHandler:startMatching()
    if not self.authenticationStatus then return end
    startMatching()
    self.isMatching = true
end

function CodeaGCHandler:matchingFinished(int)
    self.isMatching = false 
    if int == 0 then
        self.inMatch = false
    elseif int == 1 then
        self.inMatch = true
    end
end

function CodeaGCHandler:checkHosting()
    checkHosting()
end

function CodeaGCHandler:sendTouchMap()
    sendTouchMap()
end

function CodeaGCHandler:checkReceivedTouchMaps()
    checkReceivedTouchMaps()
end

function CodeaGCHandler:sendLocationsAndAngles()
    sendLocationsAndAngles()
end

function CodeaGCHandler:checkLocationsAndAngles()
    checkLocationsAndAngles()
end

function CodeaGCHandler:sendCardsShowing()
    sendCardsShowing()
end

function CodeaGCHandler:checkCardsShowing()
    checkCardsShowing()
end

--actual functions corresponding to CodeaAddOn for GameCenter 
--functions, these have to be globals for CodeaAddOn to link
--to them

--called FROM ObjC to have effects IN CODEA:
function gcAuthenticationFinished(successFlag,  optionalGCHandler)
    local GCH = optionalGCHandler or G.gcHandler
    GCH:gcAuthenticationFinished(successFlag)
end

function gcMatchingFinished(int, optionalGCHandler)
    local GCH = optionalGCHandler or G.gcHandler
    GCH:matchingFinished(int)
end

function gcNicknameFound(nickName, optionalGCHandler)
    local GCH = optionalGCHandler or G.gcHandler
    GCH.nickname = nickName
end

function gcHostAssigned(nickName, optionalGCHandler)
    local GCH = optionalGCHandler or G.gcHandler
    GCH.hostName = nickName
end

--called BY Codea for USE in ObjC--therefore bodies are empty:
function gcAuthenticate()
end

function startMatching()    
end



function checkMatching()
    
end

function checkHosting()
    
end

function sendTouchMap()
    
end

function checkReceivedTouchMaps()

end

function sendLocationsAndAngles()
    
end

function checkLocationsAndAngles()
    
end

function sendCardsShowing()
    
end

function checkCardsShowing()
    
end
