#!/bin/sh

# 目次生成
./gh-md-toc --insert README.md
./gh-md-toc --insert translations/Learning_to_Play_Othello_with_Deep_Neural_Networks/README.md
./gh-md-toc --insert translations/Developing_an_Artificial_Intelligence_for_Othello/README.md
find ./ -name "*.orig.*" | xargs rm
find ./ -name "*.toc.*" | xargs rm

# commit + force push。推敲段階入るまでは amend + force push でいいや。
git add -u
git commit --amend --no-edit
git push--f origin main
