#!/bin/bash
# File: converter.sh
# Date: August 19th, 2016
# Time: 18:56:52 +0800
# Author: kn007 <kn007@126.com>
# Blog: https://kn007.net
# Link: https://github.com/kn007/silk-v3-decoder
# Usage: sh converter.sh silk_v3_file/input_folder output_format/output_folder flag(format)
# Flag: not define   ----  not define, convert a file
#       other value  ----  format, convert a folder, batch conversion support
# Requirement: gcc ffmpeg

# Colors
RED="$(tput setaf 1 2>/dev/null || echo '\e[0;31m')"
GREEN="$(tput setaf 2 2>/dev/null || echo '\e[0;32m')"
YELLOW="$(tput setaf 3 2>/dev/null || echo '\e[0;33m')"
WHITE="$(tput setaf 7 2>/dev/null || echo '\e[0;37m')"
RESET="$(tput sgr 0 2>/dev/null || echo '\e[0m')"

# Main
cur_dir=$(cd `dirname $0`; pwd)
# 首次使用时,编译生成silk/decoder文件
if [ ! -r "$cur_dir/silk/decoder" ]; then
	echo -e "${WHITE}[Notice]${RESET} Silk v3 Decoder is not found, compile it."
	cd $cur_dir/silk
	make && make decoder
	[ ! -r "$cur_dir/silk/decoder" ]&&echo -e "${RED}[Error]${RESET} Silk v3 Decoder Compile False, Please Check Your System For GCC."&&exit
	echo -e "${WHITE}========= Silk v3 Decoder Compile Finish =========${RESET}"
fi

cd $cur_dir

# 批量处理slk的目录: ` Batch Conversion Start ` => 0log => 2log => ` Batch Conversion Finish`
# `./converter_pipe.sh slk_dir . aac`
# 删除 。。。

# slk类型会产生pcm文件: `slk v3 file` => `xxx.slk.pcm`
if [ $2 = "slk" ]; then
    cat - | $cur_dir/silk/decoder aaabbb "$1.pcm" > /dev/null 2>&1
fi
# echo "======="$0"===="$1"----"$2"*****"$3
# =======./converter_pipe.sh====oooiii_filename----amr*****aac
# cat aaa.amr | ./converter_pipe.sh oooiii_filename amr aac

# 普通类型(不需要pcm文件),如amr,直接调用ffmpeg转格式即可`./converter_pipe.sh aaa.amr aac`,然后exit
# => 1. 接受管道的文件流`cat aaa.amr | ./converter_pipe.sh oooiii_filename amr aac`,文件保存到/tmp/xxx.aac
if [ ! -f "$1.pcm" ]; then
	cat - | ffmpeg -y -i pipe:0 "/tmp/""$1.$3" > /dev/null 2>&1 &
        echo "ok!"
        exit
fi

# 将`xxx.slk.pcm`文件转为其他格式,如aac
# => 2. 接受管道文件流` cat 63a1ba08-96c0-11e7-a76c-477c23d636ed.slk | ./converter_pipe.sh aiiioooo slk aac  `
ffmpeg -y -f s16le -ar 24000 -ac 1 -i "$1.pcm" "/tmp/""$1.$3" > /dev/null 2>&1
ffmpeg_pid=$!
while kill -0 "$ffmpeg_pid"; do sleep 1; done > /dev/null 2>&1
rm "$1.pcm"
echo "ok!"
exit
