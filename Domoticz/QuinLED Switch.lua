return {

	active = {
		true
	},
	
	on = {
		devices = {
            'QuinLED Switch1',
            'QuinLED Switch2',
		},
	},
	
	logging = {
        -- level = domoticz.LOG_DEBUG,
        marker = "QL_Fan ::",
    },

	execute = function(domoticz, device)
	    
		local command = domoticz.helpers.QL_COMMAND
		
		-- Start at a targetLevel of zero, set to maximum if the switch was turned on
		local targetLevel = 0
		if (device.active) then
            targetLevel = domoticz.helpers.QL_RESOLUTION
        end
        
        -- Check if fadetime is overridden
        local fadeTime = domoticz.helpers.QL_FAN_FADETIME_DEFAULT
        if (domoticz.helpers.QL_FAN_FADETIME_OVERRIDE ~= nil) then
            fadeTime = domoticz.helpers.QL_FAN_FADETIME_OVERRIDE
        end
        
        -- Build command
        command = string.format(
            command,
            fadeTime,
            domoticz.helpers.QL_FAN_CHANNEL,
            targetLevel,
            domoticz.helpers.QL_FAN_WAITTIME,
            domoticz.helpers.QL_FAN_IP,
            domoticz.helpers.QL_PORT
        )
        
        -- Execute command
        os.execute(command)
	end
}