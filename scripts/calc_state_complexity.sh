#!/bin/sh

# オセロの state-space complexity を概算する script
# 各種文献で 10^28 という主張が書かれてるが、導出過程が書かれてない。というわけで、それをやる script を用意した。
# ^ の各種文献
# * [Searching for Solutions in Games and Artificial Intelligence](http://fragrieu.free.fr/SearchingForSolutions.pdf)
# * [Optimizing Search Space of Othello Using Hybrid Approach](https://www.researchgate.net/publication/289505529_Optimizing_Search_Space_of_Othello_Using_Hybrid_Approach)
#
# ちなみに、game-tree complexity の話は [An estimation method for game complexity](https://arxiv.org/abs/1901.11161) が良かった。

# @param [$1] formula. e.g. '3^64'
bc_l() {
  echo $1 | bc -l
}

# オセロのルールを度外視した、盤面状態の空間量
all_states_without_rule_limit=`bc_l '3^64'` # ≈ 10^30

# オセロのルールを考慮した、ありえない盤面状態の空間量
center_four_squares_empty=`bc_l '3^60'` # d4,d5,e4,e5 全てが空きマス
center_three_squares_empty=`bc_l '(3^60)*4*2'` # d4,d5,e4,e5 のうち3つが空きマス: d4,d5,e4,e5 を除いたマスの状態 * d4,d5,e4,e5 のうちどれか1つだけ石がある * その石が白or黒
center_two_squares_empty=`bc_l '(3^60)*6*(2^2)'` # d4,d5,e4,e5 のうち2つが空きマス: d4,d5,e4,e5 を除いたマスの状態 * d4,d5,e4,e5 のうちどれか2つだけ石がある * その2石が白or黒
center_one_square_empty=`bc_l '(3^60)*4*(2^3)'` # d4,d5,e4,e5 のうち1つが空きマス: d4,d5,e4,e5 を除いたマスの状態 * d4,d5,e4,e5 のうちどれか3つだけ石がある * その3石が白or黒
no_stones_in_first_move=`bc_l '(2^4)*3^58 - 1'` # 初手で着手されるはずの箇所に石がないパターン: d4,d5,e4,e5 のパターン数 * c4,d3,e6,f5 が空きマスの状態 - 全部空パターン
isolated_stones=`bc_l '(2^4)*( (2*(3^3)*2 + 2 + 2^3 + 3^5 + 2^3 + (2^2)*3)*(3^7) + 2*(2^9)*2 + 2*(2^6)*2 + 2*(2^9)  + 2*(2^11) + 2*(2^10) + 2*(2^11) + 2*(2^11) )*(3^45)*4'` # 隣接する石がない、孤立した石が存在するパターン: d4,d5,e4,e5 のパターン数 *
illegal_cases=`bc_l "$center_four_squares_empty + $center_three_squares_empty + $center_two_squares_empty + $center_one_square_empty + $no_stones_in_first_move + $isolated_stones"`

result=`bc_l "$all_states_without_rule_limit - $illegal_cases"`
exp_10=`bc_l "l($result)/l(10)" | awk -F "." '{print$1}'`
exp_2=`bc_l "l($result)/l(2)" | awk -F "." '{print$1}'`
echo "$result \n ≈ 10^$exp_10\n ≈ 2^$exp_2"
