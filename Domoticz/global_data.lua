return {
	helpers = {
		
		QL_PORT = "43333",
		QL_RESOLUTION = 1023,
		QL_TIMEOUT = 1,
		
		-- Linking switch name to global_data identifier
		QL_NAME = {
		    ["QuinLED Dimmer1"] = "DIMMER1",
		    ["QuinLED Dimmer2"] = "DIMMER2",
	    },
		
		-- IP address (String)
		QL_IP = {
	        DIMMER1 = "192.168.1.1",
	        DIMMER2 = "192.168.1.1",
        },
        -- Output channel (Integer)
        QL_CHANNEL = {
            DIMMER1 = 1,
            DIMMER2 = 2,
        },
        -- Fadetime (Integer) [ms]
        QL_FADETIME = {
            DIMMER1 = 0,
	        DIMMER2 = 0,
        },
        -- Fadetime override (Integer) [ms]
        QL_FADETIME_OVERRIDE = {
            DIMMER1 = nil,
	        DIMMER2 = nil,
        },
	}
}
