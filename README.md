# Anjelica
==========
**A Mumble bot built on piepan**

## Features
Modular design, enabling only features you want. Modules can be added/removed in the modules.lua file.
Current modules include:
- Jukebox, queue music from Youtube to play to people who opt to hear it across channels. Built using [MumbleDJ](https://github.com/matthieugrieger/mumbledj)
- Welcome tones, play a sound to a users channel when they connect
- Autoregister, pretty self explanatory.
- Soundboard, based on the original piepan example. Plays to the users channel.
- A seperate module exists for AIML based conversation using A.L.I.C.E from [A.L.I.C.E. AI Foundation, Inc.](http://www.alicebot.org/), which is LGPL licensed.

## How to install
1 Install [piepan](https://github.com/layeh/piepan)
2 Install [ffmpeg](https://www.ffmpeg.org/) and [jshon](http://kmkeen.com/jshon/). `sudo apt-get install jshon ffmpeg`
3 Download a copy of this repo and edit the config.lua file to include your own [Mashape api key](https://www.mashape.com/)
4 Copy your piepan executable to the anjelica folder, and run start.sh.

## Commands
Send a message to Anjelica containing "!help" to see an updated list of commands. At the time of writing these were:
```
Help Menu:

Commands:
!mods - List all admins and moderators.
!vol 0.1 - 1 - Change Anjelica volume.

Moderator Tasks:
!kick user - Kick a user immediately.
!channels - Lists channel numbers.
!move user channel# - Move a user to another channel.

Admin Tasks:
!addmod user - Adds a user to the list of moderators.
!delmod user - Removes a user from the list of moderators.
!ban user - Bans a user from the server.

Music Commands:
!play - Lets you hear the music.
!quit - Deafens you from the music.
!add url - Adds a song to the playlist.
!stop - Stops the music.
!start - Resumes the music.
!skip - Skips the current song.

Soundboard Sounds:
#cheer, #hello, #huh, #image, #lol, #mock, #nice

Soundboard Sounds:
#cheer, #hello, #huh, #image, #lol, #mock, #nice

Welcome Tones (Admin Commands):
!addwelcome user file.ogg - Add a welcome sound for a user.
!delwelcome user - Remove a welcome sound for a user.
```

## Thanks
- [Tim Cooper](https://github.com/bontibon) for the piepan framework
- [Matthieu Grieger](https://github.com/matthieugrieger) for MumbleDJ
- [Pierre Chapuis](https://github.com/catwell) for dequeue library
- Gerhard Roethlin for persistence library
- [Werner Robitza](https://github.com/slhck) for python normalize script

## License
```
The MIT License (MIT)

Copyright (c) 2015 Sean O'Leary

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```