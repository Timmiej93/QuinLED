# QuinLED
This repository provides various bits of code, for use with the awesome [QuinLED PWM LED dimmer](http://blog.quindorian.org/2016/07/esp8266-lighting-revisit-and-history-of-quinled.html/), as created by Quindor. Please note that this is **not** the original code provided by Quindor, so if you got the code from this GitHub repository and have issues, please complain to me, not to Quindor. The original code has been altered and is provided here with permission from Quindor.

## Introduction
In short, the QuinLED module is a DIY Pulse-Width Modulation (PWM) LED dimmer. It is designed by Quindor, who has many [blog articles](http://blog.quindorian.org/2016/07/esp8266-lighting-revisit-and-history-of-quinled.html/) and [videos](https://www.youtube.com/playlist?list=PL4b74vD-Uo-NrEv0RkJdh8M4dz8zxxMBb) about the evolution of this dimmer. I highly recommend that you check these resources if you're unfamiliar with the QuinLED module.

<p align="center"><img src="misc/images/QuinLED.png" width="750"></p>

## Contents
While creating and using my own QuinLED modules, I noticed some small issues in the code provided. Since I'm familiar with Lua coding, I decided to fix these issues for myself, and improve the script while I was at it. I also added some extras, and will guide you through creating your own NodeMCU firmware.

I would suggest that you follow the links below in the order they're provided, this should make it easier to understand what's going on.

What is provided:
- [A guide on creating your own NodeMCU firmware for QuinLED](NodeMCU%20Firmware/README.md)
  - This way you can build your own firmware when you want to develop extra functionality for QuinLED, without guessing which modules you need.
  - Since a new NodeMCU build may interfere with functionality, a working build is provided [here]()
- [Completely revamped program code](Program%20code/README.md)
  - Fixes reboot when providing a brightness level outside the 0-1023 range
  - Fixes reboot when providing a non-four-digit fadetime
  - Adds flexibility for future development with more channels
  - Adds a web server, which allows updating the code Over The Air (OTA), so no need to attach wires after the first time!
- [A different way of implementing QuinLED in Domoticz](Domoticz/README.md) (using dzVents)
  - Enables all script editing to be done from the browser, through Domoticz. No command line needed
  - Eliminates the need for a script for every device, one script can handle all your devices
- [A batch file](Batch%20file/README.md), that allows you to control your QuinLED modules easily through a command line interface
  - Allows for quick and easy input, without having to remember the exact syntax of the command


## Conclusion
If you followed all the readme's as linked above, you should now have:
  - A QuinLED module running my custom firmware and program code
  - The ability to change the program code OTA
  - An easy way to add new modules through the dzVents scripts
  - A simple batch file that allows you to control the QuinLED modules through the command line quickly and easily.
