import numpy as np
import pandas as pd
from collections import defaultdict
from sqlalchemy import create_engine

from cbf import get_cbf_score
from ncf import get_ncf_score
from hybrid3 import hybrid_recommend
from hybrid2 import hybrid2_recommend

# DB 연결
engine = create_engine('postgresql+psycopg2://postgres:oyun1211@localhost:5433/infotree')

# 평가 지표 함수들
def precision_at_k(recommended, relevant, k):
    recommended_k = recommended[:k]
    hits = len(set(recommended_k) & set(relevant))
    return hits / k if k > 0 else 0

def recall_at_k(recommended, relevant, k):
    recommended_k = recommended[:k]
    hits = len(set(recommended_k) & set(relevant))
    return hits / len(relevant) if relevant else 0

def hit_ratio_at_k(recommended, relevant, k):
    recommended_k = recommended[:k]
    return int(bool(set(recommended_k) & set(relevant)))

def ndcg_at_k(recommended, relevant, k):
    recommended_k = recommended[:k]
    dcg = 0.0
    for i, item in enumerate(recommended_k):
        if item in relevant:
            dcg += 1 / np.log2(i + 2)
    idcg = sum(1 / np.log2(i + 2) for i in range(min(len(relevant), k)))
    return dcg / idcg if idcg > 0 else 0

def evaluate_all(users, recommend_fn, likes_dict, k=10):
    results = {"precision": [], "recall": [], "hit_ratio": [], "ndcg": []}
    for user_id in users:
        recommended = recommend_fn(user_id)
        relevant = likes_dict.get(user_id, [])
        if not relevant:
            continue
        results["precision"].append(precision_at_k(recommended, relevant, k))
        results["recall"].append(recall_at_k(recommended, relevant, k))
        results["hit_ratio"].append(hit_ratio_at_k(recommended, relevant, k))
        results["ndcg"].append(ndcg_at_k(recommended, relevant, k))
    return {metric: round(np.mean(values), 4) for metric, values in results.items()}

# 사용자별 likes 정보 불러오기
likes_df = pd.read_sql("""
    SELECT id AS user_id, unnest(likes) AS benefit_id
    FROM users
    WHERE array_length(likes, 1) > 0
""", engine)

likes_dict = defaultdict(list)
for row in likes_df.itertuples():
    likes_dict[row.user_id].append(row.benefit_id)

user_ids = list(likes_dict.keys())
n_likes_dict = {uid: len(likes_dict[uid]) for uid in user_ids}
total_users = pd.read_sql("SELECT COUNT(*) FROM users", engine).iloc[0, 0]

def top_recommend(score_func, user_id, k=10):
    scores = score_func(user_id)
    sorted_items = sorted(scores.items(), key=lambda x: x[1], reverse=True)
    return [item_id for item_id, _ in sorted_items[:k]]

def cbf_wrapper(user_id): return top_recommend(get_cbf_score, user_id)
def ncf_wrapper(user_id): return top_recommend(get_ncf_score, user_id)
def hybrid_wrapper(user_id): return top_recommend(lambda uid: hybrid_recommend(uid, n_likes_dict.get(uid, 0), total_users), user_id)
def hybrid2_wrapper(user_id): return top_recommend(lambda uid: hybrid2_recommend(uid, n_likes_dict.get(uid, 0), total_users), user_id)

# 평가 실행
cbf_result = evaluate_all(user_ids, cbf_wrapper, likes_dict)
ncf_result = evaluate_all(user_ids, ncf_wrapper, likes_dict)
hybrid_result = evaluate_all(user_ids, hybrid_wrapper, likes_dict)
hybrid2_result = evaluate_all(user_ids, hybrid2_wrapper, likes_dict)

# 결과 출력
result_df = pd.DataFrame([
    {"Model": "CBF", **cbf_result},
    {"Model": "NCF", **ncf_result},
    {"Model": "Hybrid3", **hybrid_result},
    {"Model": "Hybrid2", **hybrid2_result}
])

print(result_df)
