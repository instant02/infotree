
from collections import defaultdict
from cbf import get_cbf_score
from ncf import get_ncf_score

def compute_weights(n_likes, n_users, min_w1=0.2):
    """
    사용자 활동 기반 가중치 조정
    - CBF: 초기엔 비중 높고 점차 감소
    - NCF: 점점 증가
    """
    if n_likes == 0:
        like_ratio = 0
    else:
        from math import log1p
        like_ratio = min(log1p(n_likes) / log1p(n_users), 1.0)

    w1 = max(1.0 - like_ratio, min_w1)  # CBF
    w2 = 1.0 - w1                      # NCF
    return normalize_weights(w1, w2)

def normalize_weights(w1, w2):
    total = w1 + w2
    return w1 / total, w2 / total

def combine_scores(cbf_scores, ncf_scores, w1, w2):
    final_scores = defaultdict(float)
    for bid, score in cbf_scores.items():
        final_scores[bid] += w1 * score
    for bid, score in ncf_scores.items():
        final_scores[bid] += w2 * score
    return dict(sorted(final_scores.items(), key=lambda item: item[1], reverse=True))

def hybrid2_recommend(user_id, n_likes, n_users):
    w1, w2 = compute_weights(n_likes, n_users)
    cbf_scores = get_cbf_score(user_id)
    ncf_scores = get_ncf_score(user_id)
    return combine_scores(cbf_scores, ncf_scores, w1, w2)
