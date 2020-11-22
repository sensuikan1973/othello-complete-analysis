#!/bin/sh
# markdown の Table Of Contents(TOC) を生成する script
# See: https://github.com/ekalinin/github-markdown-toc

# 本文
./gh-md-toc --insert --no-backup README.md

# 翻訳
# カレントディレクトリを反映してパスが挿入されるので、GitHub のリンク仕様上、cd しておかないとリンクが壊れる
cd translations/Developing_an_Artificial_Intelligence_for_Othello
./../../gh-md-toc --insert --no-backup README.md

cd translations/Learning_to_Play_Othello_with_Deep_Neural_Networks
./../../gh-md-toc --insert --no-backup README.md
