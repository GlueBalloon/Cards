
--a wrapper for the GameCenter access functions and client state
CodeaGCHandler = class()

function CodeaGCHandler:init()
    self.isAuthenticated = false
    self.isInMatch = false
    self.isHosting = false
end

function CodeaGCHandler:checkAuthentication()
    checkAuthentication()
end

function CodeaGCHandler:startMatching()
    startMatching()
end

function CodeaGCHandler:checkMatching()
    checkMatching()
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

function checkAuthentication()
    
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
