-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --
-- User changeable values
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --

-- Enter the SSID (name) of the WiFi network for 'ssid', and enter the matching 
--	 password for 'pwd'
wifi.setmode(wifi.STATION)
wifi.sta.config(
	{
		ssid = "WIFI_SSID",
		pwd = "WIFI_PASSWORD",
	}
)

-- If you want a static IP for this QuinLED module, set the IP address, subnet
--	 mask and gateway here.
wifi.sta.setip({
      ip = "STATIC_IP",
      netmask = "SUBNET_MASK",
      gateway = "GATEWAY_IP",
  }
)

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --
-- End of user changeable values, start of program
--   Don't change anything below this line
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --


-- Initiate QuinLED script
local QuinLED = require("QuinLED")
-- Initiate WebIDE script
local IDE = require("OnlineIDE")

function handleStuff()
	srv=net.createServer(net.TCP) 
	srv:listen(43333, function(conn)

		conn:on("receive", function(sck, payload)
        print("Init.lua :: RECEIVE")
			if (string.find(payload, "^Fadetimer")) then
                print("Init.lua :: QUINLED")
				QuinLED.receive(sck, payload)
			else
                print("Init.lua :: IDE")
				IDE.receive(sck, payload)
			end
		end)

		conn:on("sent", function(sck)
        print("Init.lua :: SENT")
		    IDE.sent(sck)
	  	end)
	end)
end

function connected()
    print("Connected to WiFi")
    local ip, nm, gw = wifi.sta.getip()
    print("\tIP: "..tostring(ip))
    print("\tSubnet Mask: "..tostring(nm))
    print("\tGateway: "..tostring(gw))
end

-- If an IP is assigned, print the çontents of the 'connected' function, and create the server.
--	 Otherwise, register a callback for when an IP is assigned, and then execute those actions.
if (wifi.sta.status() == wifi.STA_GOTIP) then
    connected()
    handleStuff()
else
    print("Connecting to WiFi...")
    wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function()
        wifi.eventmon.unregister(wifi.eventmon.STA_GOT_IP)
        connected()
        handleStuff()
    end)
end
