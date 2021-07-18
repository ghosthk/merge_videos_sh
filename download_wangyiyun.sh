#!/bin/bash

echo "请输入网易云音乐分享地址"
read share_url

echo "请输入下载的歌曲名"
read -r music_name


id=`echo $share_url | sed 's/.*id=\([0-9]*\)&.*/\1/'`

info_url="https://api.imjad.cn/cloudmusic/?type=song&id="${id}"&br=320000"
result=`curl $info_url`

download_url=$(echo ${result} | sed  's#.*\(https:.*\.mp3\).*#\1#;s#\\##g')
wget  $download_url -O "${music_name}.mp3"