# [OLIVAW: Mastering Othello with neither Humans nor a Penny](https://arxiv.org/abs/2103.17228) の日本語訳

Antonio Norelli 氏に許可をいただいて公開しています。  

筆者の勉強不足で解釈の怪しいところがあるかもしれません。詳しい方は [Pull Request](https://github.com/sensuikan1973/othello-complete-analysis/tree/main/translations/Learning_to_Play_Othello_with_Deep_Neural_Networks) 送ってもらえると助かります🙏

【目次】
<!--ts-->
<!--te-->

以下翻訳。

---
## 概要
あの有名な AlphaGo シリーズの設計原理を採用した AI オセロプレイヤーである、OLIVAW を紹介します。  
OLIVAW の主に目指すことは、これまでのいくつもの偉大なアプローチと比べて低コストで、非自明なボードゲームにおける卓越した棋力を得ることです。  
本論文では、AlphaGo Zero のパラダイムが、コモディティハードウェアと無料のクラウドサービスだけを使って、人気のあるゲームであるオセロにうまく適用できることを示します。  
オセロは、チェスや囲碁に比べてシンプルなゲームですが、巨大な探索空間を持ち、盤面を評価するのが難しいゲームです。  
OLIVAW では、AlphaGo Zero の標準的な学習プロセスを高速化するために、最近の研究にヒントを得ていくつかの改良を行っています。  
主な改良点は、学習段階でゲームごとに収集される盤面情報を2倍にすることです。これは、エージェントがプレイしていないものの、深く探索した盤面も含めることによって実現しています。  
我々は、OLIVAW の強さを3つの異なる方法でテストしました。  
* 最強のオープンソースオセロエンジンである Edax との対戦
* ウェブプラットフォーム OthelloQuest での匿名対局
* 人間の一流プレイヤーとの対戦
  * vs 全米チャンピオン
  * vs 元世界チャンピオン

## 索引用語

Deep Learning, Computational Efficiency, Neural Networks, Monte Carlo methods, Board Games, Othello

## I. 導入
aaa
