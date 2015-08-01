#---------------------#
#      MumbleDJ       #
# By Matthieu Grieger #
#---------------------#--------------------------------------------------#
# download_audio.py                                                      #
# Downloads audio (ogg format) from specified YouTube ID. If no ogg file #
# exists, it creates an empty file called .video_fail that tells the Lua #
# side of the program that the download failed. .video_fail will get     #
# deleted on the next successful download.                               #
#------------------------------------------------------------------------#

from sys import argv
from os.path import isfile
from os import remove, system
from time import sleep
import subprocess

url = argv[1]

subprocess.check_call(["wget", url, "-O", "modules/jukebox/song.3gpp"])
subprocess.check_call(["python", "./modules/jukebox/includes/normalize.py", "-i", "modules/jukebox/song.3gpp", "-l", "-20", "-f"])

if isfile('modules/jukebox/song.3gpp'):
	remove('modules/jukebox/song.3gpp')
