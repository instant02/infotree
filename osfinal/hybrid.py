# hybrid.py
from collections import defaultdict
from cbf import get_cbf_score
from ncf import get_ncf_score
from df import get_df_score

import math

def compute_weights(n_likes, n_users, min_w1=0.2, min_w3=0.2):
    """
    사용자 좋아요 수 기반 동적 가중치 조정
    - w1: CBF
    - w2: NCF
    - w3: DF
    """
    # like_ratio: log 기반으로 더 천천히 감소하도록
    if n_likes == 0:
        like_ratio = 0
    else:
        like_ratio = min(math.log1p(n_likes) / math.log1p(n_users), 1.0)

    # CBF: 초반에 높고 서서히 감소
    w1 = max(1.0 - like_ratio, min_w1)

    # DF: 비슷하게 감소
    w3 = max(1.0 - like_ratio * 0.8, min_w3)

    # NCF: 증가
    w2 = 1.0 - w1 - w3
    return normalize_weights(w1, w2, w3)


def normalize_weights(w1, w2, w3):
    total = w1 + w2 + w3
    return w1 / total, w2 / total, w3 / total


def combine_scores(cbf_scores, ncf_scores, df_scores, w1, w2, w3):
    """
    가중치 기반 점수 통합
    """
    final_scores = defaultdict(float)
    for bid, score in cbf_scores.items():
        final_scores[bid] += w1 * score
    for bid, score in ncf_scores.items():
        final_scores[bid] += w2 * score
    for bid, score in df_scores.items():
        final_scores[bid] += w3 * score
    return dict(sorted(final_scores.items(), key=lambda item: item[1], reverse=True))

def hybrid_recommend(user_id, n_likes, n_users):
    """
    하이브리드 추천 시스템
    - user_id: 사용자 ID
    - n_likes: 해당 사용자의 좋아요 수
    - n_users: 전체 사용자 수
    """
    w1, w2, w3 = compute_weights(n_likes, n_users)
    cbf_scores = get_cbf_score(user_id)
    ncf_scores = get_ncf_score(user_id)
    df_scores = get_df_score(user_id)
    return combine_scores(cbf_scores, ncf_scores, df_scores, w1, w2, w3)

"""
from collections import defaultdict
from cbf import get_cbf_score
from ncf import get_ncf_score
from df import get_df_score

def compute_weights(n_likes, n_users, min_w1=0.2):
    """
    사용자 활동 기반으로 가중치 동적 계산
    """
    decay = min(n_likes / 10, 1.0) * min(n_users / 100, 1.0)
    w1 = max(1.0 - decay, min_w1)
    w2 = (1.0 - w1) * 0.6
    w3 = (1.0 - w1) * 0.4
    return w1, w2, w3

def combine_scores(cbf_scores, ncf_scores, df_scores, w1, w2, w3):
    """
    가중치 기반 점수 통합
    """
    final_scores = defaultdict(float)
    for bid, score in cbf_scores.items():
        final_scores[bid] += w1 * score
    for bid, score in ncf_scores.items():
        final_scores[bid] += w2 * score
    for bid, score in df_scores.items():
        final_scores[bid] += w3 * score
    return dict(sorted(final_scores.items(), key=lambda item: item[1], reverse=True))

def hybrid_recommend(user_id, n_likes, n_users):
    """
    하이브리드 추천 시스템
    - user_id: 사용자 ID
    - n_likes: 해당 사용자의 좋아요 수
    - n_users: 전체 사용자 수
    """
    w1, w2, w3 = compute_weights(n_likes, n_users)
    cbf_scores = get_cbf_score(user_id)
    ncf_scores = get_ncf_score(user_id)
    df_scores = get_df_score(user_id)
    return combine_scores(cbf_scores, ncf_scores, df_scores, w1, w2, w3)

# 예시 사용법
if __name__ == "__main__":
    result = hybrid_recommend(user_id=1, n_likes=6, n_users=80)
    for bid, score in result.items():
        print(f"Benefit ID: {bid}, Final Score: {score:.4f}")
"""
