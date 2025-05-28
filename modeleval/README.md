hybrid2.py: CBF+NCF
hybrid3.py: CBF+NCF+DF
evaluate_hybrid.py: 성능 테스트 코드

지표	설명	해석
Precision@K: 상위 K개 추천 중 실제로 사용자가 좋아한 항목의 비율 -> 높을수록 정확한 추천

Recall@K: 사용자가 좋아한 항목 중 상위 K개 추천으로 얼마나 커버했는가 -> 높을수록 놓치지 않음

Hit Ratio@K: 추천 목록에 사용자가 좋아한 항목이 하나라도 포함되었는가 (0/1) -> 높을수록 사용자 취향 포착

nDCG@K (Normalized Discounted Cumulative Gain): 추천 목록의 순서까지 반영한 정밀도 -> 상위에 정확한 추천이 많을수록 높음
