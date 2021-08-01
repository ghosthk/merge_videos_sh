# 生成歌曲视频
# 随机生成

# 分离音频与视频&分割视频
1. 找到文件夹里面所有的视频文件(mp4|mov)
2. 遍历对视频文件进行音频、视频的分离
3. 分离后的视频进行裁剪，裁剪为默认60s左右的一个个短视频
	
#### 执行
```
./separate_videos.sh 分离视频的文件夹
```
* 执行`./separate_videos.sh` 并带上要分离音视频的文件夹
* 分离后的音频统一在 `~/Downloads/GH_separateAudioDir/` 文件夹中
* 分离后的视频统一在 `~/Downloads/GH_separateVideoDir/` 文件夹中
* 切割后的视频统一在 `~/Downloads/GH_clipVideoDir` 文件夹中

# 裁剪音频
```
./clip_audio.sh 音频路径 第一段秒数 第二段秒数 第三段秒数 ....
```
* 执行`./clip_audio.sh `进行裁剪音频
* 裁剪后的音频统一在 `~/Downloads/GH_clipAudioDir/` 文件夹中

# 切割视频
* 将视频裁剪为默认60s一个个的短视频

```
./clip_video.sh 视频路径
```
* 执行`./clip_video.sh `进行裁剪音频
* 裁剪后的音频统一在 `~/Downloads/GH_clipVideoDir/` 文件夹中

# 简单命令操作
* 快捷打开搜索框  `option option`  快速连续按两次`option`
* 输入`iterm` 回车键打开 `iterm` 软件
* 打开文件夹，找到当前`shells`所在的文件夹
* 在`iterm`中输入`cd` 之后按空格
* 将`shells`所在的文件夹拖入到`iterm`软件中，然后回车确认
* 之后就可以输入以上命令执行相应操作
* 在`iterm`中想打开对应文件夹，直接输入`open` 空格，之后输入文件夹名字，就可以打开对应的文件夹

```
open ~/Downloads/GH_separateAudioDir/		#打开分离音频文件夹
open ~/Downloads/GH_separateVideoDir/		#打开分离视频文件夹
open ~/Downloads/GH_clipVideoDir			#打开切割视频文件夹
```