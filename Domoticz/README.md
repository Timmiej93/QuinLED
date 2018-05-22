# Domoticz
This completely replaces [this article](http://blog.quindorian.org/2017/02/esp8266-led-lighting-using-quinled-with-domoticz.html/), from the red line onwards. Please follow the linked article until the red line (so create the dummy hardware and the dimmer switch), then follow this guide.

<p align="center"><img src="../misc/images/Quindor_Blog.png" width="500"></p>

This section is optional. You can also just follow Quindor's approach, but I personally think using my method is a lot easier.

Since I personally have been using dzVents for all my custom scripts in Domoticz, I'll explain to you how you can use these. I personally think dzVents is much easier and more flexible to use, and it can all be done from the browser, no need for the commandline.
An important thing to note: I'm not 100% sure that dzVents is already implemented in Domoticz by default. If it isn't, you may need to switch over to the beta version of Domoticz.
  
You can enter the browser's text editor by clicking `Setup > More Options > Events`. On the right side of the screen, enter an Event name, click the box that says `Blockly`, select `dzVents`, and click `New`. You can leave the third box alone, it doesn't matter for our use. I'd suggest also enabling the `Event active` checkbox, and clicking `Save`. Please be aware that this editor does not automatically save. If you close the tab or move between scripts, your changes are lost. It won't even show you a notification warning you that you are about to lose our changes, so be sure to save often.

Now you've got the editor open, select all text and delete it. Now go to either the [QuinLED Dimmer](QuinLED%20Dimmer.lua) or the [QuinLED Switch](QuinLED%20Switch.lua) script, copy the entire contents, and paste it in the web editor. Don't forget to save!
Just to clarify, the QuinLED Switch is a version of the QuinLED Dimmer, that can only toggle between 0 and 1023 (maximum). This pretty much converts the QuinLED dimmer into a QuinLED relay. Not very optimal, but it may have its uses.

<p align="center"><img src="../misc/images/Domoticz.png" width="300"></p>

Now you need to make one small change to the file. You only need to understand one thing about these dzVents scripts. They run based on the names that you enter in the `devices` table. For example, the section below would automatically run when `QuinLED Dimmer1` or `QuinLED Dimmer2` have their values changed, but it wouldn't work for `QuinLED Dimmer3`, or even for `QuinLED dimmer1`. These names need to be exactly the same as the dimmer switch in Domoticz.
```lua
	on = {
		devices = {
			'QuinLED Dimmer1',
			'QuinLED Dimmer2',
		},
	},
```

Therefor, it's imperative that you change these names to match your dimmer devices. It doesn't matter what they're called, as long as the dimmer name matches the text in the dzVents script. If you followed Quindor's tutorial exactly, you'll want to change the section above to this:

```lua
	on = {
		devices = {
			'TestDimmer',
		},
	},
```

Make sure that if you add new lines, that they always end with a comma. If you are encountering issues you can't explain, try uncommenting line 15 (`level = domoticz.LOG_DEBUG`) and commenting out line 16 (`level = domoticz.LOG_ERROR`), and then check the Domoticz log. It may contain some errors.

## Global Data
You might be wondering: "How does Domoticz know the IP addresses of my QuinLED modules? Can it do magic?". Unfortunately, it can't, but it's not far off. Instead of coding the IP addresses and all other variables into the script, I decided to use something called "global data". This basically is a database that contains variables that can be accessed from any dzVents script, instead of being limited to one.

If you don't have this global data database yet, simply create another new dzVents script, and name it `global_data`. Again, this name is case-sensitive, so it's very important that you enter exactly the right name.

For the contents of the `global_data` script, please refer to the [`global_data.lua`](global_data.lua). You can paste this into the empty `global_data` script in Domoticz. You do need to edit this file though, so I'll explain it here:

```lua
QL_PORT = "43333",
QL_RESOLUTION = 1023,
QL_TIMEOUT = 1,
```

These three variables should probably be the same for all your QuinLED modules. 
- `QL_PORT` should always be 43333, unless you changed this yourself. If you don't know if you changed it, you didn't.
- `QL_RESOLUTION` refers to the number of dimming steps. Unless you changed this yourself, it should always be 1023.
- `QL_TIMEOUT` refers to the maximum number of seconds a QuinLED module may take to respond to domoticz before it times out. If your devices are in an area with bad WiFi coverage, and they only respond sometimes, it may be wise to increase this number. For normal use, 1 should be fine.

```lua
-- Linking switch name to global_data identifier
QL_NAME = {
    ["QuinLED Dimmer1"] = "DIMMER1",
    ["QuinLED Dimmer2"] = "DIMMER2",
},
```

This section may be a bit confusing, but it basically links the name of the dimmer switch in Domoticz (TestDimmer if you followed along with Quindor) to an internal name, so that if you change your dimmer switch's name, you only have to change it once here (plus you can give it a name that's easier to work with). Basically, the name you gave the switch in Domoticz (TestDimmer) should be on the left, and the internal name, which can be anything, should be on the right.

```lua
-- IP address (String)
QL_IP = {
    DIMMER1 = "192.168.0.200",
    DIMMER2 = "192.168.0.200",
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
```

These values should be pretty self explanatory, but basically they contain the IP address, channel, and fadetime for each dimmer switch you made. In this example, you can see thta `QuinLED Dimmer1` and `QuinLED Dimmer2` are both on the same QuinLED module, just on different channels, and they both change instantly (so a fadetime of zero).
