#!/bin/bash
# Test ok: cat aaa.amr | ./ffmpeg_test.sh
cat - |  ffmpeg -i pipe:0 -y -f adts dsadsadasaa.aac
