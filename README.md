# FFmpeg-Server_Scripts
FFmpeg scripts to process video and audio for media server

x265 is used for the video and Opus for the audio.

**Re-encode - Opus.bat** actually uses opusenc.exe from https://opus-codec.org/, piping any audio file from FFmpeg to it (opusenc.exe does not accept all audio formats).
opusenc.exe is expected at the path "C:\Program Files\FFmpeg\opus-tools but you can use another location by editing the script or setting an Environment Variable.
The code to use libopus within FFmpeg is present, but I like opusenc and its ability to set the input smapling frequency metadata that FFmpeg will get wrong.

**Re-encode - x265 + Opus.bat** will read the height of the input video and use that to set the bit-rate limit.
These limits are set within the script and should be easy for anyone to change.
libopus is used to re-encode the audio, but as video's should use 48 KHz audio the issue mentioned above with libopus is irrelevant.

**Re-encode - x265 + Opus - multi.bat** is for handling video with multiple audio tracks.
To address FFmpeg not wanting to create files with different numbers of audio channels across the tracks, this creates multiple files and muxes them together.
The script has been developed around _The Matrix_ which has three English surround sound tracks and four stereo commentary, at least for the version in my collection.
Appropriate titles are set for each track, as are the audio channel numbers for the track groups.
Different media will require different versions of this script to properly handle the audio tracks.
(Identifying stream ID, audio channel number, and track title.)
