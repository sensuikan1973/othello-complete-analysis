#!/bin/sh

# オセロの state-space complexity を概算する script
# [Searching for Solutions in Games and Artificial Intelligence](http://fragrieu.free.fr/SearchingForSolutions.pdf) や Optimizing Search Space of Othello Using Hybrid Approach](https://www.researchgate.net/publication/289505529_Optimizing_Search_Space_of_Othello_Using_Hybrid_Approach) にて、
# 10^28 という主張が書かれてるが、導出過程が書かれてないので、それをやる script。
# ちなみに、game-tree complexity の話は [An estimation method for game complexity](https://arxiv.org/abs/1901.11161) が分かりやすい
# あと、[wikipedia](https://en.wikipedia.org/wiki/Game_complexity) にはいろんなゲームのこの話がまとめられているので、おすすめ

# @param [$1] formula. e.g. '3^64'
bc_l() {
  echo $1 | bc -l
}

# オセロのルールを度外視した、盤面状態の空間量
all_states_without_rule_limit=`bc_l '3^64'` # ≒ 10^30

# オセロのルールを考慮した、ありえない盤面状態の空間量
center_four_squares_empty=`bc_l '3^60'` # d4,d5,e4,e5 全てが空きマス
center_three_squares_empty=`bc_l '(3^60)*4*2'` # d4,d5,e4,e5 のうち3つが空きマス: d4,d5,e4,e5 を除いたマスの状態 * d4,d5,e4,e5 のうちどれか1つだけ石がある * その石が白or黒
center_two_squares_empty=`bc_l '(3^60)*4*(2^2)'` # d4,d5,e4,e5 のうち2つが空きマス: d4,d5,e4,e5 を除いたマスの状態 * d4,d5,e4,e5 のうちどれか2つだけ石がある * その2石が白or黒
center_one_square_empty=`bc_l '(3^60)*4*(2^3)'` # d4,d5,e4,e5 のうち1つが空きマス: d4,d5,e4,e5 を除いたマスの状態 * d4,d5,e4,e5 のうちどれか3つだけ石がある * その3石が白or黒
illegal_cases=$(($center_four_squares_empty + $center_three_squares_empty + $center_two_squares_empty + $center_one_square_empty))

result=`bc_l "$all_states_without_rule_limit - $illegal_cases"`
exp=`echo "l($result)/l(10)" | bc -l | awk -F "." '{print$1}'`
echo "10^$exp ($result)"
