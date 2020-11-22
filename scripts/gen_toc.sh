#!/bin/sh

# 目次生成
./gh-md-toc --insert --no-backup README.md

cd translations/Developing_an_Artificial_Intelligence_for_Othello
./../../gh-md-toc --insert --no-backup README.md

cd translations/Learning_to_Play_Othello_with_Deep_Neural_Networks
./../../gh-md-toc --insert --no-backup README.md
