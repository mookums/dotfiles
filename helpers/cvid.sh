#!/usr/bin/env bash

# Uses FFMPEG to convert OBS recordings for DaVinci Resolve
extensions=("mkv" "mp4" "MP4")

echo "List of videos being converted:"
for ext in ${extensions[@]}; do
    find . -maxdepth 1 -name "*.$ext"
done

if [ -z "$FRAMERATE" ]; then
    FRAMERATE=30
fi

echo "Conversion Framerate: $FRAMERATE"
read -p "Do you want to convert all compatible videos in the given directory? [y/N] -> " confirmation

case $confirmation in
    [yY] )
        for ext in ${extensions[@]}; do
            for i in "./*.$ext"; do ffmpeg -r $FRAMERATE -i "$i" -c:v prores_ks -c:a pcm_s24le "${i%.*}.mov"; done
        done
        ;;
    *)  
        echo "TERMINATED!"
        ;;
esac

