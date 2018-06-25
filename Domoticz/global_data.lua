return {
	helpers = {
		
		QL_COMMAND = "echo Fadetimer=%d, LED%d_target=%d | nc -w %d %s %s &",
		
		QL_PORT = "43333",
		QL_RESOLUTION = 1023,
		QL_TIMEOUT = 1,
		
		-- Linking switch name to global_data identifier
		--	REQUIRED
		QL_NAME = {
		    ["QuinLED Dimmer1"] = "DIMMER1",
		    ["QuinLED Dimmer2"] = "DIMMER2",
	    },
		
		-- IP address (String)
		--	REQUIRED
		QL_IP = {
	        DIMMER1 = "192.168.1.1",
	        DIMMER2 = "192.168.1.1",
        },

        -- Output channel (Integer)
        --	REQUIRED
        QL_CHANNEL = {
            DIMMER1 = 1,
            DIMMER2 = 2,
        },

        -- Fadetime (Integer) [ms]
        -- 	Enables you to set a custom fadetime per device.
        --  When an entry is missing, or is set to nil, the script will use the default value of zero.
        QL_FADETIME = {
            DIMMER1 = 0,
	        DIMMER2 = 0,
        },

        -- Fadetime override (Integer) [ms]
        -- 	Enables you to (temporarilly) override the fadetime per device.
        --  When an entry is missing, or is set to nil, nothing will be overridden.
        QL_FADETIME_OVERRIDE = {
            DIMMER1 = nil,
	        DIMMER2 = nil,
        },

        -- Resolution override (Integer) [ms]
        --	Enables you to set a maximum dimming level per device.
        --  When an entry is missing, or is set to nil, the script will use the default resolution value.
        QL_RESOLUTION_OVERRIDE = {
            DIMMER1 = nil,
            DIMMER2 = nil,
        },

        -- Resolution ramping (Float) (x^y, where y is defined in the QL_RESOLUTION_RAMP table below)
        -- Accepted values: Anything greater than zero.
        -- Recommended values: Anything between zero and five.
        
        -- For a visualisation of the dimming curve, go to https://www.desmos.com/calculator (or any other graphical calculator),
        -- and enter 'x^y' as the formula, where y is the number you enter in this table.
        -- When there is no entry for a device, x^1 is used, which results in a straight line.
        
        -- (0 < y < 1) results in a more 'agressive' dimming (gets brighter earlier, fine-tuning in the end)
        -- (1) results in a linear dimming.
        -- (1 < y < inf.) results in a more 'relaxed' dimming (fine-tuning in the beginning, gets brighter quickly at the end)
        QL_RESOLUTION_RAMP = {
            DIMMER1 = 1.2,
            DIMMER2 = 2,
        },
	}
}
