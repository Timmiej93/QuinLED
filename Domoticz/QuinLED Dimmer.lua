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
		local command = helpers.QL_COMMAND
		
		-- Find the correct name
	    local deviceName = helpers.QL_NAME[device.name]
	    if (deviceName == nil or deviceName == "") then
	        domoticz.log("Devicename \""..device.name.."\" unknown.", domoticz.LOG_ERROR)
	        return
        end
	    
	    -- Handle brightness
		local targetLevel = 0
		if (device.active and device.level > 0) then
		    
		    -- Check if the resolution is overridden
		    local resolution = helpers.QL_RESOLUTION_OVERRIDE[deviceName]
		    if (resolution == nil) then
		        resolution = helpers.QL_RESOLUTION
	        end
	        
		    -- Get the normalized level [0-1]
		    --  Divide by 96 because the dummy dimmer always goes back to 96% for some reason
            local normTargetLevel = (device.level / 96)
		    
		    -- Apply the ramp setting, if available
		    local exponent = helpers.QL_RESOLUTION_RAMP[deviceName]
		    local rampedTargetLevel
		    if (exponent ~= nil and type(exponent) == "number") then
		        rampedTargetLevel = normTargetLevel^exponent
		        domoticz.log("Ramped target level: "..normTargetLevel.." ^ "..exponent.." = "..rampedTargetLevel)
	        end
	        
	        -- Set targetLevel to either the ramped or the normal level
	        if (rampedTargetLevel ~= nil) then
	            targetLevel = rampedTargetLevel * resolution
            else
                targetLevel = normTargetLevel * resolution
            end
            
            -- Add 4 (minimum value for the LED strip to light up) to make sure the
            --  light always lights up at the lowest setting above zero.
            targetLevel = targetLevel + 4
        end
        
        -- Handle fadetime
        local fadeTime = helpers.QL_FADETIME[deviceName]
        if (fadeTime == nil) then
            fadeTime = 0
        end
        
        -- Check if fadetime is overridden
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

