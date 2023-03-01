@echo off
set PATH=C:\Program Files\ffmpeg\opus-tools;%PATH%
::	necessary to point to opusenc.exe location

CALL :FOLDname foldUP
set folder=%foldUP% opus
CALL :FOLDcheck "%folder%"

:start
TITLE Opus - %~n1

CALL :OPUStools "%~1"
REM CALL :OPUSlibVBR "%~1"
REM CALL :OPUSlibCVBR "%~1" 320k
REM CALL :OPUSlibCBR "%~1" 256k

shift

if "%~1"=="" goto end
goto start

:end

::pause
exit

:FOLDcheck <OUTfold>
if NOT EXIST "%~1" mkdir "%~1"
exit/B 0

:FOLDname <folder name>
for %%* in (.) do set name=%%~nx*
set "%~1=%name%"
exit/B 0

:OPUStools <input> <bitrate>
set rate=%~2
if NOT "%rate%"=="" set rate=--bitrate %rate%
CALL :AUDchannel "%~1" CHANop

ffmpeg -hide_banner -i "%~1" -ac %CHANop% -f flac -compression_level 0 - | opusenc %rate% --vbr - - | ffmpeg -hide_banner -i - -c copy "%folder%\%~n1.ogg"
::	opensenc sometimes has excessive overhead, but remuxing the file addresses it
exit/B 0

:OPUSlibVBR <input> <rate>
set rate=%~2
if NOT "%rate%"=="" set rate=-b:a %rate%
CALL :AUDchannel "%~1" CHANop

ffmpeg -hide_banner -i "%~1" -vn -ac %CHANop% -c:a libopus -application 2049 ^
-vbr 1 %rate% ^
-map_metadata 0 "%~dp1%folder%\%~n1.ogg"
exit /B 0

:OPUSlibCVBR <input> <rate>
set rate=%~2
if "%rate%"=="" set rate=320
ffmpeg -hide_banner -i "%~1" -vn -c:a libopus -application 2049 ^
-b:a %rate% -vbr 2 ^
-map_metadata 0 "%folder%\%~n1.ogg"
exit /B 0

:OPUSlibCBR <input> <rate>
set rate=%~2
if "%rate%"=="" set rate=256k
ffmpeg -hide_banner -i "%~1" -vn -c:a libopus -application 2049 ^
-b:a %rate% -vbr 0 ^
-map_metadata 0 "%folder%\%~n1.ogg"
exit /B 0

:AUDchannel <input> <variable> <stream>
set stream=%~3
if "%stream%"=="" set stream=0
for /f "tokens=*" %%I in ('ffprobe -v error -of default^=noprint_wrappers^=1:nokey^=1 -show_entries stream^=channels -select_streams a:%stream% -i "%~1"') do set OUT=%%I
set /A "%~2=%OUT%"
exit /B 0
