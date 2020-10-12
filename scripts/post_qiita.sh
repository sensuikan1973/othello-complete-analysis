#!/bin/sh

# @param [$1] relative path of the github markdown file
generate_qiita_doc() {
  # 行末の空白スペース(GitHub だとそれが改行を意味する)を削除
  sed -e 's/[ \t]*$//' $1 > $1.qiita
  # 目次いらない
  sed -i '.backup' -e '/## 目次/,/<!--te-->/d' $1.qiita
  sed -i '.backup' -e '/【目次】/,/<!--te-->/d' $1.qiita
  # h1 見出しもいらない
  sed -i '.backup' -e '1d' $1.qiita

  rm -f $1.qiita.backup
}

# @param [$1] item id
# @param [$2] Qiita Access Token
# @param [$3] json data
# See: https://qiita.com/api/v2/docs#%E6%8A%95%E7%A8%BF
post() {
  curl "https://qiita.com/api/v2/items/$1" \
  -v \
  -X PATCH \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $2" \
  -d "$3"
}


## NOTE: 本文(README.md)
markdown_path="README.md"
generate_qiita_doc $markdown_path
data=$(cat <<EOS
{
  "body": $(ruby -e 'p ARGF.read.sub(/\A---.*---/m, "")' $markdown_path.qiita),
  "title": "オセロの完全解析、どうやるか? いくらかかるか?",
  "private": true,
  "tags": [ {"name":"オセロ"}, {"name":"ゲームAI"}, {"name":"機械学習"} ]
}
EOS
)
post "dd432a60208db9b62c56" ${QIITA_ACCESS_TOKEN} "${data}"

## NOTE: 翻訳(Developing_an_Artificial_Intelligence_for_Othello)
markdown_path="translations/Developing_an_Artificial_Intelligence_for_Othello/README.md"
generate_qiita_doc $markdown_path
data=$(cat <<EOS
{
  "body": $(ruby -e 'p ARGF.read.sub(/\A---.*---/m, "")' $markdown_path.qiita),
  "title": "[翻訳] Developing an Artificial Intelligence for Othello/Reversi",
  "private": true,
  "tags": [ {"name":"オセロ"}, {"name":"ゲームAI"}, {"name":"機械学習"} ]
}
EOS
)
post "2fda85acc0411698ee8c" ${QIITA_ACCESS_TOKEN} "${data}"

## NOTE: 翻訳(Learning_to_Play_Othello_with_Deep_Neural_Networks)
markdown_path="translations/Learning_to_Play_Othello_with_Deep_Neural_Networks/README.md"
generate_qiita_doc $markdown_path
data=$(cat <<EOS
{
  "body": $(ruby -e 'p ARGF.read.sub(/\A---.*---/m, "")' $markdown_path.qiita),
  "title": "[翻訳] Learning to Play Othello with Deep Neural Networks",
  "private": true,
  "tags": [ {"name":"オセロ"}, {"name":"ゲームAI"}, {"name":"機械学習"}, {"name":"DeepLearning"} ]
}
EOS
)
post "7a4e2a9b8e09c1753fbf" ${QIITA_ACCESS_TOKEN} "${data}"
