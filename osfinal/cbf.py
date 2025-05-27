from sklearn.feature_extraction.text import CountVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from sqlalchemy import create_engine
import pandas as pd

engine = create_engine('postgresql+psycopg2://infotree:info1234@localhost:5432/infotree')

def preprocess_categories(categories):
    if isinstance(categories, list):
        return ' '.join(categories)
    return categories or ''

def get_recommendations(user, benefits, top_n=10):
    user_vec = preprocess_categories(user['categories'])

    benefit_texts = []
    benefit_info = []

    for benefit in benefits:
        benefit_texts.append(preprocess_categories(benefit['categories']))
        benefit_info.append({
            "id": benefit["id"],
        })

    corpus = [user_vec] + benefit_texts
    vectorizer = CountVectorizer()
    vectors = vectorizer.fit_transform(corpus)

    cosine_sim = cosine_similarity(vectors[0:1], vectors[1:]).flatten()
    top_indices = cosine_sim.argsort()[::-1][:top_n]

    top_benefits = [benefit_info[i] for i in top_indices]
    return top_benefits

def get_cbf_score(user_id):
    # 사용자 카테고리 불러오기
    user_query = f"SELECT categories FROM users WHERE id = {user_id}"
    user_df = pd.read_sql(user_query, engine)

    if user_df.empty or user_df["categories"][0] is None:
        return {}

    user = {
        "categories": user_df["categories"][0]
    }

    # 현재 진행 중이며 공개된 혜택만 불러오기
    benefit_query = """
        SELECT id, categories
        FROM benefits
        WHERE start_date <= NOW() AND end_date >= NOW() AND private = FALSE
    """
    benefit_df = pd.read_sql(benefit_query, engine)
    benefits = benefit_df.to_dict(orient="records")

    # 추천 수행
    top_benefits = get_recommendations(user, benefits, top_n=10)
    return {item["id"]: 1.0 - 0.1 * i for i, item in enumerate(top_benefits)}
