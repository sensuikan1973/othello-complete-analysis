#!/bin/sh

# 目次生成
./gh-md-toc --insert README.md \
translations/Learning_to_Play_Othello_with_Deep_Neural_Networks/README.md \
translations/Developing_an_Artificial_Intelligence_for_Othello/README.md

# 一時ファイルを削除
find ./ -name "*.orig.*" | xargs rm
find ./ -name "*.toc.*" | xargs rm
