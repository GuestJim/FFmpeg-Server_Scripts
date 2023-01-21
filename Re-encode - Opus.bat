@echo off
set PATH=C:\Program Files\ffmpeg\opus-tools;%PATH%
::	necessary to point to opusenc.exe location

CALL :FOLDname foldUP
set folder=%foldUP% opus
CALL :FOLDcheck "%folder%"

:start
TITLE Opus - %~n1

CALL :OPUStools "%~1" 96
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
if "%rate%"=="" set rate=96
ffmpeg -hide_banner -i "%~1" -f flac -compression_level 0 - | opusenc --bitrate %rate% --vbr - "%~n1.opus"

ffmpeg -hide_banner -i "%~n1.opus" -map 0 -vn -c copy -map_metadata 0 "%folder%\%~n1.ogg"
del "%~n1.opus"
::	opensenc sometimes has excessive overhead, but remuxing the file addresses it
::	.opus is a variant of .ogg, but this protects the file from overwriting
exit/B 0

:OPUSlibVBR <input>
ffmpeg -hide_banner -i "%~1" -vn -c:a libopus -application 2049 ^
-vbr 1 ^
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