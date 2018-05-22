return {

	active = {
		true
	},
	
	on = {
		devices = {
			'QuinLED Dimmer1',
			'QuinLED Dimmer2',
		},
	},
	
	logging = {
        -- level = domoticz.LOG_DEBUG,
        level = domoticz.LOG_ERROR,
        marker = "QL_Dimmer :",
    },

	execute = function(domoticz, device)
	    
	    -- "Global" stuff
	    local helpers = domoticz.helpers
		local command = "echo Fadetimer=%d, LED%d_target=%d | nc -w %d %s %s"
		
		-- Find the correct name
	    local deviceName = domoticz.helpers.QL_NAME[device.name]
	    if (deviceName == nil or deviceName == "") then
	        domoticz.log("Devicename \""..device.name.."\" unknown.", domoticz.LOG_ERROR)
	        return
        end
	    
	    -- Handle brightness
		local targetLevel = 0
		if (device.active) then
		    if (device.level < 4) then
		        -- Override the lowest value on the slider to return the absolute lowest value QuinLED can handle
		        targetLevel = 4
	        else
    		    -- Divide by 96 because the dummy dimmer always goes back to 96% for some reason
                targetLevel = (device.level / 96) * domoticz.helpers.QL_RESOLUTION
            end
        end
        
        -- Check if fadetime is overridden
        local fadeTime = helpers.QL_FADETIME[deviceName]
        if (helpers.QL_FADETIME_OVERRIDE[deviceName] ~= nil) then
            fadeTime = helpers.QL_FADETIME_OVERRIDE[deviceName]
        end
        
        -- Build command
        command = string.format(
            command,
            fadeTime,
            helpers.QL_CHANNEL[deviceName],
            targetLevel,
            helpers.QL_TIMEOUT,
            helpers.QL_IP[deviceName],
            helpers.QL_PORT
        )
        
        -- Execute command
        os.execute(command)
        domoticz.log("Command: "..tostring(command))
	end
}