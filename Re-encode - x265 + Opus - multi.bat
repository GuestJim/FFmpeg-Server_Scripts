@echo off

set rate265=3000k
::	fallback bit rate

set folder=Re-encode
CALL :FOLDcheck "%folder%"

:start
TITLE Re-encode x265 - %~n1

CALL :VIDheight "%~1" height
REM set height=720
set rate=%rate265%

if %height% LEQ 1080 set rate=3000k

REM if %height% LEQ 720 set rate=2000k
if %height% LEQ 720 set rate=2500k

REM if %height% LEQ 480 set rate=2000k
if %height% LEQ 480 set rate=1500k

:ENC
set FILT=setpts=PTS-STARTPTS
REM set FILT=%FILT%,scale=-4:'min(ih,%height%)'
set crf=18
set preset=medium

CALL :AUDchannel "%~1" CHAN0 0
CALL :AUDchannel "%~1" CHAN1 1
CALL :AUDchannel "%~1" CHAN2 2
CALL :AUDchannel "%~1" CHAN3 3
CALL :AUDchannel "%~1" CHAN4 4
CALL :AUDchannel "%~1" CHAN5 5
CALL :AUDchannel "%~1" CHAN6 6

::	uncomment for 2-pass encoding
REM ffmpeg -hide_banner -i "%~1" -vf "%FILT%" -an ^
REM -c:v libx265 -pix_fmt yuv420p10le -crf %crf% -maxrate %rate% -bufsize %rate% -preset %preset% ^
REM -x265-params pass=1:stats="%~n1.log" -f null NUL && ^
::	move to after line 45 (beginning -map 0:v) and uncomment
REM -x265-params pass=2:stats="%~n1.log" ^
ffmpeg -hide_banner -i "%~1" -vf "%FILT%" -map 0:s -c:s copy ^
-map 0:v -c:v libx265 -pix_fmt yuv420p10le -crf %crf% -maxrate %rate% -bufsize %rate% -preset %preset% ^
-c:a libopus -vbr 1 -ac %CHAN0% ^
-map 0:a:1 -metadata:s:a:0 title="Surround 5.1" ^
"%folder%\%~n1 - AV.mkv" ^
-c:a libopus -vbr 1 -ac %CHAN3% ^
-map 0:a:3 -metadata:s:a:0 title="Commentary - Philosophers" ^
-map 0:a:4 -metadata:s:a:1 title="Commentary - Critics" ^
-map 0:a:5 -metadata:s:a:2 title="Commentary - Cast and Crew" ^
-map 0:a:6 -metadata:s:a:3 title="Commentary - Composer Music Only" ^
"%folder%\%~n1 - A.mka"

ffmpeg -hide_banner -i "%folder%\%~n1 - AV.mkv" -i "%folder%\%~n1 - A.mka" -c copy ^
-map 0 -map 1 -map_metadata 0 -map_metadata 1 ^
-disposition:a:0 default "%folder%\%~n1.mkv"
REM -map 0:v -map 0:a -map 1:a -map 0:s -c:s copy -map_metadata 0 -map_metadata 1 ^

del "%~n1.log.cutree"
del "%~n1.log"
shift

if "%~1"=="" goto end
goto start

:end

::pause
exit

CALL :VIDrate "%~1" rate
REM set /A rate=%rate% / 2

:FOLDcheck <OUTfold>
if NOT EXIST "%~1" mkdir "%~1"
exit/B 0

:FOLDname <folder name>
for %%* in (.) do set name=%%~nx*
set "%~1=%name%"
exit/B 0

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
if NOT "%stream%"=="" set %stream%=0
for /f "tokens=*" %%I in ('ffprobe -v error -of default^=noprint_wrappers^=1:nokey^=1 -show_entries stream^=channels -select_streams a:%stream% -i "%~1"') do set OUT=%%I
set /A "%~2=%OUT%"
exit /B 0
