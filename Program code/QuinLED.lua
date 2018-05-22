-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --
-- User changeable values
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --

-- Add new channels in PWM_id. The key relates to the number in 'LED1_target' in the command, the 
--	 value relates to the pin number on the hardware
local PWM_id = {
    [1]=3, 
    [2]=4,
}

-- Levels at which the PWM dimming starts when QuinLED boots. [0-1023]
local startupLevels = {
    [1]=0, 
    [2]=0,
}

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --
-- End of user changeable values, start of program
--   Don't change anything below this line
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --

-- For external access and global storage
local QuinLED = {}
local LED_current = {}
local LED_target = {}
local LED_timer = {}

-- For every entry in the PWM_id table, setup and start the PWM signal, and set the current and 
--	 and target level to zero.
for key,id in pairs(PWM_id) do
    local startupLevel = startupLevels[key]
    if (startupLevel == nil) then
        startupLevel = 0
    end
	pwm.setup(id, 1000, startupLevel)
	pwm.start(id)

	LED_current[key] = startupLevel
	-- 	LED_target[key] = 500
end

function QuinLED_Receive(conn, payload)
	-- This needs to be expanded when more channels are added, and should probably be improved
	--	but at the moment, I can't think of a better way to do this.
	local function startTimer(idx, dimInterval)

		-- Force stop the previous timer if it's active and unregister the callback (frees up resources)
		local timer = LED_timer[idx]
		timer:unregister()

		local function createCallback(idx)

			return (function()
					if (LED_current[idx] < LED_target[idx]) then 
						LED_current[idx] = (LED_current[idx] + 1) 
						pwm.setduty(PWM_id[idx], LED_current[idx])
					elseif (LED_current[idx] > LED_target[idx]) then 
						LED_current[idx] = (LED_current[idx] - 1) 
						pwm.setduty(PWM_id[idx], LED_current[idx])
					elseif (LED_current[idx] == LED_target[idx]) then 
						local timer = LED_timer[idx]
						timer:unregister()
					end 
				end)
		end

		local callback = createCallback(idx)
		
		local timer = tmr.create()
		timer:alarm(dimInterval, 1, callback)
		LED_timer[idx] = timer
	end
	print("\n > Payload: "..payload)

	-- Futureproofing
	--	Search for the index of the used LED in the payload, set to first match (max idx is 12)
	local LEDidx
	for i=1,12 do
		if (string.find(payload, string.format("LED%d", i)) ~= nil) then
			LEDidx = i
			break
		end
	end
 
	local LED = string.format("LED%d", LEDidx)
	local fadeTimeStartIdx,fadeTimeEndIdx = string.find(payload, "Fadetimer=%d+")
	local targetStartIdx,targetEndIdx = string.find(payload, LED.."_target=%d+")

	if (fadeTimeStartIdx ~= nil and fadeTimeEndIdx ~= nil and targetStartIdx ~= nil and targetEndIdx ~= nil) then

		-- Add the length of the strings 'Fadetimer=' and 'LED#_target=' to the start idx to get the number idx
		fadeTimeStartIdx = fadeTimeStartIdx + 10
		targetStartIdx = targetStartIdx + 12

		local target = string.sub(payload, targetStartIdx, targetEndIdx)
		print("RAW: LED_target: "..tostring(target))
		target = tonumber(target)
		if (target == nil) then
			print("Target is nil, possibly trying to convert text to number. Using default (5)")
			target = 5
		end
		-- Clamp values between 0 and 1023
		LED_target[LEDidx] = math.max(0, math.min(1023, target))

		local fadeTime = string.sub(payload, fadeTimeStartIdx, fadeTimeEndIdx)
		print("RAW: Fadetime: "..tostring(fadeTime))
		fadeTime = tonumber(fadeTime)
		if (fadeTime == nil) then
			print("Fadetime is nil, possibly trying to convert text to number. Using default (5000ms)")
			fadeTime = 5000
		end

		-- Number of steps between target and current
		local numSteps = math.abs(LED_target[LEDidx] - LED_current[LEDidx])

		-- If 0 steps, set to 1 to make sure division below doesn't crap out
		if (numSteps == 0) then
			numSteps = 1
		end

		local dimInterval = (fadeTime / numSteps)

		print ("Fadetime: "..fadeTime)
		print ("NumSteps: "..numSteps)
		print ("DimInterval: "..dimInterval)
		print ("Current LED value: "..LED_current[LEDidx])
		print ("Target LED value: "..LED_target[LEDidx])

		-- If Dimtime is less then 1ms, do instantly, otherwise set timer
		if (dimInterval < 1) then
			LED_current[LEDidx] = LED_target[LEDidx]
			pwm.setduty(PWM_id[LEDidx], LED_current[LEDidx])
		else
			startTimer(LEDidx, dimInterval)
		end
	end
end
QuinLED.receive = QuinLED_Receive

print ("QuinLED script loaded")

return QuinLED
