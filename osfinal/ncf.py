import torch
import pandas as pd
import numpy as np
from model03 import NCF

MODEL_PATH = "epoch47_20250515_155420_valrmse0.5814.pt"

def load_model(model_state_dict, num_users, num_items):
    model = NCF(num_users, num_items)
    model.load_state_dict(model_state_dict)
    model.eval()
    return model

def recommend_top_k_for_user(model, user_id, num_items, top_k=10, batch_size=512):
    device = torch.device("cuda" if torch.cuda.is_available() 
                          else "mps" if torch.backends.mps.is_available() 
                          else "cpu")
    model = model.to(device)
    model.eval()

    all_items = torch.arange(num_items, dtype=torch.long, device=device)
    user_ids = torch.full_like(all_items, user_id, dtype=torch.long, device=device)

    preds = []
    with torch.no_grad():
        for i in range(0, len(all_items), batch_size):
            u = user_ids[i:i+batch_size]
            v = all_items[i:i+batch_size]
            pred = model(u, v)
            preds.extend(pred.cpu().numpy())

    preds = np.array(preds)
    if len(preds) == 0:
        return pd.DataFrame(columns=["userId", "itemId", "predicted_rating"])

    top_k_indices = np.argsort(preds)[-top_k:][::-1].copy() 
    top_k_items = all_items[top_k_indices].cpu().numpy()
    top_k_scores = preds[top_k_indices]


    length = len(top_k_items)
    df_result = pd.DataFrame({
        "userId": [user_id]*length,
        "itemId": top_k_items,
        "predicted_rating": top_k_scores
    })

    return df_result


def inference(user_id, top_k):
    # 모델 로드
    checkpoint = torch.load(MODEL_PATH, map_location=torch.device("cpu"))
    num_users = checkpoint["num_users"]
    num_items = checkpoint["num_items"]
    model_state_dict = checkpoint["model_state_dict"]

    model = load_model(model_state_dict, num_users, num_items)

    # 추천 수행
    df_result = recommend_top_k_for_user(model, user_id, num_items, top_k)

    return df_result


def get_ncf_score(user_id):
    df_result = inference(user_id, top_k=10)
    return dict(zip(df_result["itemId"], df_result["predicted_rating"]))
