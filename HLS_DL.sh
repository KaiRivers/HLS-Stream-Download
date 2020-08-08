#!/bin/bash
#Link example :
# https://live-playout.tomorrowland.com/4U1zR2jnLj.ism/4U1zR2jnLj-audio_eng=257265-video_eng=5500000.m3u8
host="live-playout.tomorrowland.com"
link="https://$host/4U1zR2jnLj.ism/"
filename="4U1zR2jnLj-audio_eng=257265-video_eng=5500000"
ext=".ts"
playlist="$filename.m3u8"
#"cookies.sqlite" file location (Firefox): Replace %USERPROFILE% and %PROFILE% with your own
cookies_path=/cygdrive/c/Users/%USERPROFILE%/AppData/Roaming/Mozilla/Firefox/Profiles/%PROFILE%.default/cookies.sqlite
sqlite3 "$cookies_path" 'select name, value, host from moz_cookies' > cookies.txt
grep "|$host" cookies.txt | sed "s/|$host//g" | sed 's/|/=/g' | tr "\n" "\;" > cookies.txt
[ $? -ne 0 ] && (echo "Exiting. Cookie not found. Keep TML webpage open."; exit)
cookies=$(cat cookies.txt)
if [ -e "$playlist" ]
then
echo "skipping \"$playlist\""
else
echo "downloading \"$playlist\""
sqlite3 "$cookies_path" 'select name, value, host from moz_cookies' > cookies.txt
grep "|$host" cookies.txt | sed "s/|$host//g" | sed 's/|/=/g' | tr "\n" "\;" > cookies.txt
[ $? -ne 0 ] && (echo "Exiting. Cookie not found. Keep TML webpage open."; exit)
cookies=$(cat cookies.txt)
wget "$link$playlist" --no-cookies --header "Cookie: $cookies"
[ $? -ne 0 ] && (echo "Exiting. Playlist download error."; exit)
fi
filenames=$(grep "$ext" $playlist)
[ $? -ne 0 ] && (echo "Exiting. Can't find $ext filenames in playlist."; exit)
dlfile="No file"
for file in $filenames
do
if [ -e "$file" ]
then
echo "skipping \"$file\""
else
echo "Processing \"$file\""
lnk="$link$file"
sqlite3 "$cookies_path" 'select name, value, host from moz_cookies' > cookies.txt
grep "|$host" cookies.txt | sed "s/|$host//g" | sed 's/|/=/g' | tr "\n" "\;" > cookies.txt
[ $? -ne 0 ] && (echo "Exiting. Cookie not found. Keep TML webpage open."; exit)
cookies=$(cat cookies.txt)
[ $? -ne 0 ] && (echo "Exiting. Cookie not found. Keep TML webpage open."; exit)
echo "cookies : $cookies"
wget "$lnk" --no-cookies --header "Cookie: $cookies"
if [ $? -ne 0 ]
then
rm "$file" >> /dev/null 2>&1
echo "Exiting. Last file downloaded: $dlfile"
exit
fi
fi
dlfile=$file
done
if [ ! -e ""$filename"_all.ts" ]
then
cmd /C ffmpeg.exe -i $playlist -c copy ""$filename"_all.ts"
echo "Done joining segments"
else
echo "Full video already exists"
fi
