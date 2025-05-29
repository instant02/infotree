from fastapi import FastAPI, HTTPException
from hybrid import hybrid_recommend
from sqlalchemy import create_engine
import pandas as pd
import traceback


app = FastAPI()

engine = create_engine('postgresql+psycopg2://postgres:oyun1211@localhost:5433/infotree')

@app.get("/recommend/{user_id}")
def recommend(user_id: int):
    try:
        user_df = pd.read_sql(f"SELECT likes FROM users WHERE id = {user_id}", engine)
        if user_df.empty:
            raise HTTPException(status_code=404, detail="User not found")

        likes = user_df.get('likes', [])[0] if 'likes' in user_df.columns and not user_df.empty else []
        likes = likes if isinstance(likes, list) else []
        n_likes = len(likes)

        total_users = pd.read_sql("SELECT COUNT(*) FROM users", engine).iloc[0, 0]

        results = hybrid_recommend(user_id, n_likes, total_users)
        recommendations = list(results.keys())[:10]

        return {
            "user_id": user_id,
            "recommendations": recommendations
        }
    except Exception as e:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))
    
@app.get("/demographic_recommend/{user_id}")
def demographic_recommend(user_id: int, top_k: int=5):
    print(user_id)
    recommendations = df.inference_multi_channel(user_id, top_k=top_k)

    return {
        "user_id": user_id,
        "top_k": top_k,
        "recommendations": recommendations
    }
    
    """
from fastapi import FastAPI, HTTPException
from hybrid import hybrid_recommend
from sqlalchemy import create_engine
import pandas as pd
import traceback
import df

app = FastAPI()

engine = create_engine('postgresql+psycopg2://infotree:info1234@localhost:5432/infotree')

@app.get("/recommend/{user_id}")
def recommend(user_id: int):
    try:
        user_df = pd.read_sql(f"SELECT likes FROM users WHERE id = {user_id}", engine)
        if user_df.empty:
            raise HTTPException(status_code=404, detail="User not found")

        likes = user_df.get('likes', [])[0] if 'likes' in user_df.columns and not user_df.empty else []
        likes = likes if isinstance(likes, list) else []
        n_likes = len(likes)

        total_users = pd.read_sql("SELECT COUNT(*) FROM users", engine).iloc[0, 0]

        results = hybrid_recommend(user_id, n_likes, total_users)
        recommendations = list(results.keys())[:10]

        return {
            "user_id": user_id,
            "recommendations": recommendations
        }
    except Exception as e:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))

    """
