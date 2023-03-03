@echo off

set rate265=3000k
::	fallback bit rate

set folder=Re-encode
CALL :FOLDcheck "%folder%"

:start
TITLE Re-encode x265 - %~n1

set rate=%rate265%
CALL :VIDheight "%~1" height
REM set height=720
::	can be used with X265scale

if %height% LEQ 1080 set rate=3000k

REM if %height% LEQ 720 set rate=2000k
if %height% LEQ 720 set rate=2500k

REM if %height% LEQ 480 set rate=2000k
if %height% LEQ 480 set rate=1500k

:ENC
CALL :AUDchannel "%~1" CHAN
CALL :RATEopus rateA 0 0
::	with either the stereo or mono bitrate set to 0, rateA will be blank and the defaults are used

CALL :X265process "%~1" %rate%
REM CALL :X265pass "%~1" %rate%

REM CALL :X265scale "%~1" %height% %rate%
REM CALL :X265passscale "%~1" %height% %rate%

REM CALL :X265crop "%~1" 72 %rate% 72
REM CALL :X265passcrop "%~1" 72 %rate% 72

shift

if "%~1"=="" goto end
goto start

:end

::pause
exit

CALL :VIDrate "%~1" rate
REM set /A rate=%rate% / 2
::	can be used to simply divide the original bitrate by some value

:FOLDcheck <OUTfold>
if NOT EXIST "%~1" mkdir "%~1"
exit/B 0

:FOLDname <folder name>
for %%* in (.) do set name=%%~nx*
set "%~1=%name%"
exit/B 0

:conSET <rate> <crf> <preset>
set rate=%~1
set crf=%~2
set preset=%~3
exit /B 0

:RATEopus <variable> <pair> <mono>
::	96 per stereo pair, 64 per mono channel (center, subwoofer)
set pair=%~2
if "%pair%"=="" set /A pair=96
set mono=%~3
if "%mono%"=="" set /A mono=64

if %CHAN% LEQ 8 set /A OUT=%pair%*3 + %mono%*2
if %CHAN% LEQ 6 set /A OUT=%pair%*2 + %mono%*2
if %CHAN% LEQ 2 set /A OUT=%pair%

if %OUT% GEQ 512 set OUT=512
::	libopus has a maximum bitrate
set "%~1=-b:a %OUT%k"
if %pair%==0 set "%~1=" & if %mono%==0 set "%~1="
::	can be used to let libopus use its defaults
exit /B 0

:X265process <input> <rate> <crf> <preset>
set rate=%~2
if "%rate%"=="" set rate=%rate265%
set crf=%~3
if "%crf%"=="" set crf=18
set speed=%~4
if "%preset%"=="" set preset=medium
::	sets values to better names, checks if values have been given and sets default if necessary
::	quotes around the variable are necessary

ffmpeg -hide_banner -i "%~1" -vf "setpts=PTS-STARTPTS" -c:s copy ^
-c:v libx265 -pix_fmt yuv420p10le -crf %crf% -maxrate %rate% -bufsize %rate% -preset %preset% ^
-ac %CHAN% -c:a libopus %rateA% -vbr 1 "%folder%\%~n1.mkv"
::	necessary to indicate audio channels or libopus fails with multi-channel
exit /B 0

:X265scale <input> <scale> <rate> <crf> <preset>
set FILT=setpts=PTS-STARTPTS
set scale=%~2
if NOT "%scale%"=="" set FILT=%FILT%,scale=-4:'min(ih,%scale%)'
set rate=%~3
if "%rate%"=="" set rate=%rate265%
set crf=%~4
if "%crf%"=="" set crf=18
set speed=%~5
if "%preset%"=="" set preset=medium

ffmpeg -hide_banner -i "%~1" -vf "%FILT%" -c:s copy ^
-c:v libx265 -pix_fmt yuv420p10le -crf %crf% -maxrate %rate% -bufsize %rate% -preset %preset% ^
-ac %CHAN% -c:a libopus %rateA% -vbr 1 "%folder%\%~n1 - %scale%p.mkv"
exit /B 0

:X265crop <input> <crop> <rate> <crf> <preset>
set FILT=setpts=PTS-STARTPTS
set crop=%~2
if NOT "%crop%"=="" set FILT=%FILT%,crop=in_w:in_h-2*%crop%:0:%crop%
set rate=%~3
if "%rate%"=="" set rate=%rate265%
set crf=%~4
if "%crf%"=="" set crf=18
set speed=%~5
if "%preset%"=="" set preset=medium

ffmpeg -hide_banner -i "%~1" -vf "%FILT%" -c:s copy ^
-c:v libx265 -pix_fmt yuv420p10le -crf %crf% -maxrate %rate% -bufsize %rate% -preset %preset% ^
-ac %CHAN% -c:a libopus %rateA% -vbr 1 "%folder%\%~n1 - crop.mkv"
exit /B 0


:X265pass <input> <rate> <crf> <preset>
set rate=%~2
if "%rate%"=="" set rate=%rate265%
set crf=%~3
if "%crf%"=="" set crf=18
set speed=%~4
if "%preset%"=="" set preset=medium

ffmpeg -hide_banner -i "%~1" -vf "setpts=PTS-STARTPTS" -an ^
-c:v libx265 -pix_fmt yuv420p10le -crf %crf% -maxrate %rate% -bufsize %rate% -preset %preset% ^
-x265-params pass=1:stats="%~n1.log" -f null NUL

REM -x265-params pass=1:stats="%~n1.log" -f null NUL && ^
ffmpeg -hide_banner -i "%~n1" -vf "setpts=PTS-STARTPTS" -c:s copy ^
-c:v libx265 -pix_fmt yuv420p10le -crf %crf% -maxrate %rate% -bufsize %rate% -preset %preset% ^
-x265-params pass=2:stats="%~n1.log" ^
-ac %CHAN% -c:a libopus %rateA% -vbr 1 "%folder%\%~n1.mkv"

del "%~n1.log.cutree"
del "%~n1.log"
exit /B 0

:X265passscale <input> <scale> <rate> <crf> <preset>
set FILT=setpts=PTS-STARTPTS
set scale=%~2
if NOT "%scale%"=="" set FILT=%FILT%,scale=-4:'min(ih,%scale%)'
set rate=%~3
if "%rate%"=="" set rate=%rate265%
set crf=%~4
if "%crf%"=="" set crf=18
set speed=%~5
if "%preset%"=="" set preset=medium

ffmpeg -hide_banner -i "%~1" -vf "%FILT%" -an ^
-c:v libx265 -pix_fmt yuv420p10le -crf %crf% -maxrate %rate% -bufsize %rate% -preset %preset% ^
-x265-params pass=1:stats="%~n1.log" -f null NUL

ffmpeg -hide_banner -i "%~n1" -vf "%FILT%" -c:s copy ^
-c:v libx265 -pix_fmt yuv420p10le -crf %crf% -maxrate %rate% -bufsize %rate% -preset %preset% ^
-x265-params pass=2:stats="%~1.log" ^
-ac %CHAN% -c:a libopus %rateA% -vbr 1 "%folder%\%~n1.mkv"

del "%~n1.log.cutree"
del "%~n1.log"
exit /B 0

:X265passcrop <input> <crop> <rate> <crf> <preset>
set FILT=setpts=PTS-STARTPTS
set crop=%~2
if NOT "%crop%"=="" set FILT=%FILT%,crop=in_w:in_h-2*%crop%:0:%crop%
set rate=%~3
if "%rate%"=="" set rate=%rate265%
set crf=%~4
if "%crf%"=="" set crf=18
set speed=%~5
if "%preset%"=="" set preset=medium

ffmpeg -hide_banner -i "%~1" -vf "%FILT%" -an ^
-c:v libx265 -pix_fmt yuv420p10le -crf %crf% -maxrate %rate% -bufsize %rate% -preset %preset% ^
-x265-params pass=1:stats="%~n1.log" -f null NUL

ffmpeg -hide_banner -i "%~1" -vf "%FILT%" -c:s copy ^
-c:v libx265 -pix_fmt yuv420p10le -crf %crf% -maxrate %rate% -bufsize %rate% -preset %preset% ^
-x265-params pass=2:stats="%~n1.log" ^
-ac %CHAN% -c:a libopus %rateA% -vbr 1 "%folder%\%~n1.mkv"

del "%~n1.log.cutree"
del "%~n1.log"
exit /B 0


:VIDheight <input> <heigh>
for /f "tokens=*" %%I in ('ffprobe -v error -of default^=noprint_wrappers^=1:nokey^=1 -show_entries stream^=height -select_streams v -i "%~1"') do set OUT=%%I
set /A "%~2=%OUT%"
exit /B 0

:VIDrate <input> <heigh>
for /f "tokens=*" %%I in ('ffprobe -v error -of default^=noprint_wrappers^=1:nokey^=1 -show_entries stream^=bit_rate -select_streams v -i "%~1"') do set OUT=%%I
set /A "%~2=%OUT%"
exit /B 0

:AUDchannel <input> <variable> <stream>
set stream=%~3
if "%stream%"=="" set stream=0
for /f "tokens=*" %%I in ('ffprobe -v error -of default^=noprint_wrappers^=1:nokey^=1 -show_entries stream^=channels -select_streams a:%stream% -i "%~1"') do set OUT=%%I
set /A "%~2=%OUT%"
exit /B 0
