# [WIP] オセロの完全解析、どうやるか? いくらかかるか?
<p align="center">
   <img src="https://raw.githubusercontent.com/sensuikan1973/othello-complete-analysis/main/images/head_image.png" width="300">
</p>

## 目次
<!--ts-->
* [[WIP] オセロの完全解析、どうやるか? いくらかかるか?](#wip-オセロの完全解析どうやるか-いくらかかるか)
   * [目次](#目次)
   * [想定読者](#想定読者)
   * [序論 「オセロ界におけるソフト事情の概要」](#序論-オセロ界におけるソフト事情の概要)
      * [ここで言う「オセロ」の定義](#ここで言うオセロの定義)
      * [現在の解析状況](#現在の解析状況)
      * [ソフトの活用 〜世界大会を例に〜](#ソフトの活用-世界大会を例に)
      * [用語定義](#用語定義)
   * [本論 「完全解析を考える」](#本論-完全解析を考える)
      * [考えること と 考えないこと](#考えること-と-考えないこと)
         * [考えること](#考えること)
         * [考えないこと](#考えないこと)
      * [<em>完全</em> とは](#完全-とは)
      * [使うソフトウェアは?](#使うソフトウェアは)
      * [方法/構成 X つ](#方法構成-x-つ)
         * [A: お手元のマシン](#a-お手元のマシン)
         * [B: スパコン](#b-スパコン)
         * [C: Compute Engine Service](#c-compute-engine-service)
         * [D: Map Reduce Service](#d-map-reduce-service)
         * [まとめ](#まとめ)
      * [学習データの活用](#学習データの活用)
         * [個人が携帯可能なものとして](#個人が携帯可能なものとして)
         * [オンラインサービスとして](#オンラインサービスとして)
   * [結論](#結論)
   * [参考](#参考)
      * [Othello](#othello)
         * [Software](#software)
         * [Others (Paper, Blog, Slide, ...)](#others-paper-blog-slide-)
      * [General](#general)
      * [Other Games](#other-games)
         * [Chess](#chess)
         * [Checker](#checker)
         * [Shogi](#shogi)
         * [Go](#go)
      * [Infrastructure](#infrastructure)
         * [Services](#services)
         * [Others](#others)

<!-- Added by: runner, at: Sun Sep 12 13:28:15 UTC 2021 -->

<!--te-->

## 想定読者
オセロに興味がある人、関連技術に詳しい人、富豪

## 序論 「オセロ界におけるソフト事情の概要」
### ここで言う「オセロ」の定義
[「オセロ」の公式サイト](https://www.megahouse.co.jp/othello/what/)にある通り、`8 × 8` の大きさで、特定の初期配置から打ち進めるものを指すとします。  
エイトスターズオセロやグランドオセロなどの派生競技は含めません。

### 現在の解析状況
前提としてざっくり書いておきます。

* 黒と白が最善を尽くせば `引分` と考えられてるが、完全解析は済んでない。
* 人間 vs ソフトの話は[昔話](https://www.skatgame.net/mburo/event.html)で、今はいかに上手く _活用_ するかが焦点。
* 最近のプレイヤーが研究に使うソフトは、[edax](https://github.com/abulmo/edax-reversi) や [Zebra](http://radagast.se/othello/zebra.html) など。
  * 個人/数人単位での学習が進んだことで、_一個人が対人戦に勝つための_ 情報は出揃いつつあると言っていい。<br/>
  _誤解を恐れずに言えば、手持ちの情報全て覚えればほぼ負けない世界になりつつある_。<br/>
  でも覚えきれないので、「人に勝つための定石をいかに研究しておくか」+「未知の局面に対応する力をいかに磨けるか」が重要な昨今。<br/>

### ソフトの活用 〜世界大会を例に〜
オセロ大会に馴染みがない人向けに、具体例を挙げて簡単に説明しておきます。  
これは [World Othello Championship 2019 の決勝戦第 3 局](http://transcripts.worldothello.org/woc_history/2019/transcripts/round_14/html/TAKAHASHI%20Aki-TAKANASHI%20Yus_2.htm)の序盤(黒番)。  
<img src="https://raw.githubusercontent.com/sensuikan1973/othello-complete-analysis/main/images/woc_2019_third_day_3th_game_opening.png" width="200"/>  
この局面、`d7` が最善手とされていますが、黒は _あえて_ `c6` に着手しました。  
そして、その後も _あえて_ 最善とされる手ではない所に着手し、自身の得意な進行に持ち込んで行きました。  
このように、`自分の得意な形の進行や相手の研究が手薄そうな進行`に持ち込むために、事前にソフトで研究しているのです。  
大会だと相手は人間であり、ソフトと違ってどっかしらでミスをするので、最善進行のみにこだわる理由はほぼ無いのです。

また、_お互いに最後まで研究範囲のまま終局_ みたいな試合も起きえます。  
これは [World Othello Championship 2019 の決勝戦第 2 局](http://transcripts.worldothello.org/woc_history/2019/transcripts/round_14/html/TAKANASHI%20Yus-TAKAHASHI%20Aki.htm)の終局図。  
<img src="https://raw.githubusercontent.com/sensuikan1973/othello-complete-analysis/main/images/woc_2019_third_day_2th_game_ending.png" width="200"/>  
引分です。これ、お互いに永遠に最善を打ち続けただけです。  
このように、特定の進行について研究通り 60 手打ち終える ということがたまに発生します。  
現在のオセロ界におけるソフト活用話は、主旨とずれるので詳細は省略します。もう少し知りたい方には、[中森弘樹六段のスライド](https://www.slideshare.net/bakumomoki/ss-72668518)がオススメです。

皆めちゃくちゃソフトを活用してます。

### 用語定義
この記事で使う用語を定義しておく。

|       用語       |                                                     意味                                                     |                                                                 補足                                                                 |
| :--------------: | :----------------------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------------------------------: |
|      大目標      |                                   `誰もが最高の情報を手軽に獲得できる世界`                                   |                                                                  -                                                                   |
|      小目標      |                                                  `完全解析`                                                  |                                           今回の目標、完全解析を `小目標` と呼ぶことにする                                           |
|      オセロ      |                                    [先述](#ここで言うオセロの定義) の通り                                    |                                                                  -                                                                   |
|     オセラー     |                                      大会やネットでオセロをやっている人                                      |                                                                  -                                                                   |
|     完全解析     |                           _全_ パターンの `結論(最善進行時の終局石差)` を出すこと                            |                                       _完全_ は、ありうる局面の全パターンを意味するということ                                        |
|    最強の AI     |                             _あらゆる_ パターンに対して、最強手を導ける評価関数                              |                                                  `完全解析` 済みかどうかは関係ない                                                   |
| 事実上の完全解析 |                                 `対人戦のために` 必要な情報が揃っていること                                  | 例えば、`-30` という大悪手の分岐は、人間からすると興味の対象外。<br>目安としては、`0 ~ -8` の分岐が8割ほど網羅されているような状態。 |
|      評価値      | 特定の箇所に着手することの評価値。<br/>完全解析による `確かな` 値の場合もあれば、`不確かな` 値のこともある。 |                                                                  -                                                                   |
|       book       |                                     学習を通して獲得した、評価値テーブル                                     |                                                                  -                                                                   |
|   `完全` book    |                                         `完全解析` が実現された book                                         |                                                                  -                                                                   |
|  `対人用` book   |                                  `事実上の完全解析` の実現を目的とした book                                  |                                                                  -                                                                   |
|   `統合` book    |                              全ての情報を 1 つのファイルで持っている状態の book                              |                                                                  -                                                                   |
|   `分割` book    |            特定の基準によって、分割された状態の book。<br/>全てを統合すると `統合 book` になる。             |                                                                  -                                                                   |
|  book の`展開`   |                          book を、アプリが高速にアクセス可能な領域に配置すること。                           |                                                              インメモリ                                                              |

## 本論 「完全解析を考える」

### `考えること` と `考えないこと`

#### 考えること
* 完全解析をする方法と費用
* 完全解析の結果活用

#### 考えないこと
* [参考](#参考)にもいくつか挙げたような、`最強の AI` の話
* 費用の工面法

### _完全_ とは
先述の通り、ありうる局面のパターンを意味するが、具体的に何パターンの話なのか?  
状態空間, ツリー空間

### 使うソフトウェアは?
勝負は横に並べてのスケールをどこまで頑張れるか。  
最終的には、担当する分岐量が最大であったノードの実行時間が全体の実行時間になる。  
ただし、それは Reduce 省略して逐次処理をほぼ無にできた場合の話に過ぎない。  
スパコンも考える。

あと、ゼロから新規のソフトを作る選択肢については考えないものとする。  
やっても既存のを拡張する程度とする。

[要素メモ書き]  
メモリ  
Map Reduce  
book 分散  
Reduce 省略  
既存アセット  
マルチプロセス  
マルチスレッド  
Platform  
API  

### 方法/構成 X つ
[要素メモ書き]  
CPU, メモリ, aaa

#### A: お手元のマシン
ただの叩き台

#### B: スパコン
aaa

#### C: Compute Engine Service
aaa

#### D: Map Reduce Service
Reduce いらん & インスタンス間通信が不要なら筋悪な気がする。要調査。

#### まとめ
| 方法  | 概要  | 調達方法 | 所用時間 | 費用  |
| :---: | :---: | :------: | :------: | :---: |
|   A   |   -   |    -     |    -     |   -   |
|   B   |   -   |    -     |    -     |   -   |
|   C   |   -   |    -     |    -     |   -   |
|   D   |   -   |    -     |    -     |   -   |

XXX(仮に1500)万円をオセロにサクッと溶かせる大富豪の登場が待たれる。  
冗談はさておき、将棋や囲碁と違ってプロが存在しないので、一企業が手を出す旨味があるかというと、厳しそう。(XXX 万で名を残せると考えれば...)

試しに、研究熱心なオセラー皆で少しずつ出した場合一人あたりいくら必要かを考えてみる。  
完全解析にお金を出すくらいに熱心なオセラーは、雑に考えると、全国大会に出場するような層がメインでしょう。  
2020 年の名人戦の参加者が 200 人、そこに熱心なネットオセラーや海外プレイヤー等々も考慮し、雑に 500 人もお金を出してくれるとしましょう。  
1500 万 / 500人 = 3万/人。  
研究熱心なオセラー全員が 3 万ずつ出せばいけそう。みたいな。  

これは資源費だけの話で、そもそもの人手の話とかは無視してる。

### 学習データの活用
いよいよ大目標、`誰もが最高の情報を手軽に獲得できる世界` の話。

#### 個人が携帯可能なものとして
一個人が持ってるスマホ/PCのスペックは知れているので、統合 book を個人が携帯できる未来というのはそうそうやってこない。  
携帯出来るのは、一部の分割 book に留まるでしょう。

んー、あんま明るくない。

#### オンラインサービスとして
`評価値 API を提供する小さなサービス` が生まれるのが理想。明るい。  
他の何かを作る開発者もそれを使って強力なエンジンを備えられる、そういう世界。

当然、開発/運営してくれる人/お金が必要なので、全然簡単な話ではないが、個々人の端末レベル話から抜け出せるのはでかい。  

[大まかな構成図](https://app.diagrams.net/#G1-f-UyKno-cqsMco1N8A5sSH_f-CAxukd)を書いてみると、こんな感じのものが考えられる。  

![othello-eval-service-architecture](https://raw.githubusercontent.com/sensuikan1973/othello-complete-analysis/main/images/othello-eval-service-architecture.png)

* ビジネスロジックが詰まった API サーバは常駐の必要がないので、オートスケールなり Cloud Functions(/Lambda) なりを活用可能。  
* 勝負になるのは、book を _高速にアクセス可能な領域に展開したまま_ にしておきたい点。<br/>
  統合 book はサイズがでかすぎるので、丸ごと展開は現実的でない。<br/>
  分散 book にしたとしても、都度展開する場合、処理時間に対してそれが支配的になるのは明らかなので、都度展開は避けたい。<br/>
  そこで、常駐インスタンスを用意し、予め分散 book を展開しておくという工夫が考えられる。<br/>
  でも、それすると固定費が痛い。

## 結論
aaa

## 参考

※ 一部の英語文献は、著者の許可を得て[日本語訳を公開してます](https://github.com/sensuikan1973/othello-complete-analysis/tree/main/translations)。

### Othello
#### Software
* [edax](https://github.com/abulmo/edax-reversi)
* [Zebra](http://radagast.se/othello/zebra.html)
  * [作者 Gunnar Andersson による解説記事など](http://radagast.se/othello/)
    * Booby Reversi などで有名な[奥原氏の翻訳もある](http://www.amy.hi-ho.ne.jp/okuhara/howtoj.htm)
  * for Windows: [WZebra](http://radagast.se/othello/download.html)
  * for Linux: [LZebra](http://radagast.se/othello/download3.html)
  * for Android: [Reversatile (旧 DroidZebra)](https://play.google.com/store/apps/details?id=de.earthlingz.oerszebra)
     * [Source Code](https://github.com/oers/reversatile)
* [Logistello](https://www.skatgame.net/mburo/log.html)
  * [paper list](https://skatgame.net/mburo/publications.html)
* [Saio](https://www.romanobenedetto.it/Saio.htm)
  * [SAIO: UN SISTEMA ESPERTO PER ILGIOCO DELL’OTHELLO](https://www.romanobenedetto.it/tesi.pdf)
  * [ANALYZE: SAIO - World Othello Federation News](https://www.worldothello.org/news/131/analyze-saio)
* [Nboard](http://www.orbanova.com/nboard/)
  * [NTest Opening Book](http://www.orbanova.com/nbook/)
* [Herakles](http://www.tournavitis.de/herakles/)
  * [Mouse(m): A self-teaching algorithm that achieved master-strength at Othello](http://www.tournavitis.de/herakles/Paper.zip)
* [FOREST](https://ocasile.pagesperso-orange.fr/forest.htm)
  * [Developing an Artificial Intelligence for Othello/Reversi](https://ocasile.pagesperso-orange.fr/neurone.htm)
  * See also: https://github.com/sensuikan1973/othello-complete-analysis/issues/1#issuecomment-716798458
* OLIVAW
  * [OLIVAW: reaching superhuman strength at Othello](https://www.slideshare.net/MeetupDataScienceRoma/olivaw-reaching-superhuman-strength-at-othello)
* [Booby Reversi](http://www.amy.hi-ho.ne.jp/okuhara/index.htm)
  * [リバーシのビットボードテクニック](http://www.amy.hi-ho.ne.jp/okuhara/bitboard.htm)
* [Tothello](http://www.tothello.com/index.html)
* [HAYABUSA](https://www.slideshare.net/uenokazu/20130906-hayabusa)
* Others
  * [Alpha Zero General](https://github.com/suragnair/alpha-zero-general)
  * [reversi-alpha-zero](https://github.com/mokemokechicken/reversi-alpha-zero)
  * [othello-zero](https://github.com/2Bear/othello-zero)

#### Others (Paper, Blog, Slide, ...)
* [Computer Othello | Wikipedia](https://en.wikipedia.org/wiki/Computer_Othello)
* [Othello | Chess Programming Wiki](https://www.chessprogramming.org/Othello)
* [Searching for Solutions in Games and Artificial Intelligence](http://fragrieu.free.fr/SearchingForSolutions.pdf)
* [Optimizing Search Space of Othello Using Hybrid Approach](https://www.researchgate.net/publication/289505529_Optimizing_Search_Space_of_Othello_Using_Hybrid_Approach)
* [Complexity of Othello game](https://ci.nii.ac.jp/naid/110003191565)
* [Alpha-Beta vs Scout Algorithms for the Othello Game](http://ceur-ws.org/Vol-2486/icaiw_wdea_3.pdf)
* [La base WTHOR](https://www.ffothello.org/informatique/la-base-wthor/)
  * [オセロの棋譜データベースWTHORの読み込み方](https://qiita.com/tanaka-a/items/e21d32d2931a24cfdc97)
* [Learning to Play Othello with Deep Neural Networks](https://arxiv.org/abs/1711.06583)
* [縮小盤オセロにおける完全解析](https://www.ipsj-kyushu.jp/page/ronbun/hinokuni/1004/1A/1A-2.pdf)
* [オセロの完全解析を解説する](https://blog.sakasin.net/solving-othello)
* [Alpha "Othello" Zero 深層強化学習の理論と実装](https://www.slideshare.net/takehiko-ohkawa/alphaothello-zero-127398324)
* [キロキティア](https://choi.lavox.net/start)
* [もしオセロの初心者が Edax の評価関数を読んだら](https://qiita.com/tanaka-a/items/6d6725d5866ebe85fb0b)
* [A World-Championship-Level Othello Program - 1981](https://apps.dtic.mil/dtic/tr/fulltext/u2/a106560.pdf)
* [オセロ界はソフトといかに向き合ってきたか](https://www.slideshare.net/mobile/bakumomoki/ss-72668518)
* [program rainting | World Othello Federation](https://www.worldothello.org/ratings/player?searchPlayerInput=+)
* [XOT](http://berg.earthlingz.de/xot/aboutxot.php?lang=en)
* [煮詰まった](http://f5-openning.blogspot.com/)

### General
* [Game complexity](https://en.wikipedia.org/wiki/Game_complexity) : ゲームの `複雑さ` がまとまった wiki。
* [An estimation method for game complexity](https://arxiv.org/abs/1901.11161) : `Tree Size` (合法的なゲームの数)の複雑さの尺度を推定する方法を書いた論文
* [A Deep Dive into Monte Carlo Tree Search](http://www.moderndescartes.com/essays/deep_dive_mcts/) : モンテカルロ木探索の詳細を解説する記事

### Other Games
#### Chess
* [Bitboards on the Chess Programming Wiki](https://www.chessprogramming.org/Bitboards) : BitBoard のアルゴリズムの基礎を知るのにとても有用。チェスの wiki という位置付けですが、内容は一般的に重要なものが多い。
* [LeelaChessZero](https://github.com/LeelaChessZero/lc0)
* [Stockfish](https://github.com/official-stockfish)
* [Stockfish完全解析](http://yaneuraou.yaneu.com/stockfish%e5%ae%8c%e5%85%a8%e8%a7%a3%e6%9e%90/)
* [Mastering Chess and Shogi by Self-Play with a General Reinforcement Learning Algorithm](https://arxiv.org/abs/1712.01815)
* [チェスの棋譜約220万戦を分析してわかったことを可視化](https://gigazine.net/news/20160301-chess-game-visual-look/)

#### Checker
* [Checker is Solved](https://science.sciencemag.org/content/317/5844/1518/tab-pdf)

#### Shogi
* [Apery](https://github.com/HiraokaTakuya/apery)
* [やねうら王](https://github.com/yaneurao/YaneuraOu)
* [elmo](https://mk-takizawa.github.io/elmo/howtouse_elmo.html)
* [コンピュータ将棋のHASHの概念について詳しく](http://yaneuraou.yaneu.com/2018/11/18/%e3%80%90%e6%b1%ba%e5%ae%9a%e7%89%88%e3%80%91%e3%82%b3%e3%83%b3%e3%83%94%e3%83%a5%e3%83%bc%e3%82%bf%e5%b0%86%e6%a3%8b%e3%81%aehash%e3%81%ae%e6%a6%82%e5%bf%b5%e3%81%ab%e3%81%a4%e3%81%84%e3%81%a6/)
* [Bonanza](https://forest.watch.impress.co.jp/library/software/bonanza/)
* [KENTO](https://note.com/shogi_kento/n/ncc05cc261b7e)
* [Ponanza開発者、山本一成氏が語る強化学習とA/Bテスト運用の舞台裏](https://logmi.jp/tech/articles/321123)

#### Go
* [Leela Zero](https://github.com/leela-zero/leela-zero)
* [Mastering the game of Go without human knowledge](https://www.nature.com/articles/nature24270)
* [四路盤囲碁の完全解析](http://id.nii.ac.jp/1001/00058633/)

### Infrastructure

#### Services
* [GCP](https://cloud.google.com/)
  * [GCE](https://cloud.google.com/compute)
  * [Dataproc](https://cloud.google.com/dataproc)
  * [Dataflow](https://cloud.google.com/dataflow)
  * [Google Cloud for AWS Professionals: Big Data](https://cloud.google.com/docs/compare/aws/big-data#transformation)
* [AWS](https://aws.amazon.com/)
  * [EC2](https://aws.amazon.com/jp/ec2/)
  * [Amazon EMR](https://aws.amazon.com/jp/emr/)
* [さくら](https://cloud.sakura.ad.jp/)
  * [さくらのクラウドでHadoop/Spark/Asakusa環境を構築する](https://knowledge.sakura.ad.jp/3633/)
* [Azure](https://azure.microsoft.com/)
  * [Virtual Machine](https://azure.microsoft.com/ja-jp/services/virtual-machines/)
  * [What is Apache Hadoop in Azure HDInsight?](https://docs.microsoft.com/ja-jp/azure/hdinsight/hadoop/apache-hadoop-introduction)

#### Others
* [並列コンピュータ 非定量的アプローチ](https://www.ohmsha.co.jp/book/9784274225710/)
* [並行コンピューティング技法 --実践マルチコア/マルチスレッドプログラミング](https://www.oreilly.co.jp/books/9784873114354/)
* [分散システムデザインパターン --コンテナを使ったスケーラブルなサービスの設計](https://www.oreilly.co.jp/books/9784873118758/)
* [Microsoft: Cloud Design Patterns](https://docs.microsoft.com/ja-jp/azure/architecture/patterns/)

---
[![source](https://img.shields.io/badge/source-black.svg?logo=github)](https://github.com/sensuikan1973/othello-complete-analysis)
