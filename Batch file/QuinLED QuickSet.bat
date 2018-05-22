@ECHO OFF

:START

ECHO.
ECHO Set brightness for a QuinLED module
ECHO.

SET ip=192.168.
SET /P ip2=IP Address: 192.168.
IF "%ip2%"=="" ECHO ERROR
SET ip=%ip%%ip2%

SET /P channel=Channel: 
IF "%channel%"=="" ECHO ERROR

SET /P level=Brightness level: 
IF "%level%"=="" ECHO ERROR

ECHO.
IF %channel% == 0 GOTO DUAL
ECHO Setting brignthess for %ip%, channel %channel% to %level%...
ECHO Fadetimer=0, LED%channel%_target=%level% | nc -w 1 %ip% 43333
GOTO END

:DUAL
ECHO Setting brignthess for both channels of %ip% to %level%...
ECHO Fadetimer=0, LED1_target=%level% | nc -w 1 %ip% 43333
ECHO Fadetimer=0, LED2_target=%level% | nc -w 1 %ip% 43333

:END
ECHO.
ECHO -----------------------------------------------------------------
GOTO START