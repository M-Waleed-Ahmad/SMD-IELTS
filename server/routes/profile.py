from __future__ import annotations
from venv import logger
from flask import Blueprint, jsonify, request
from datetime import datetime, timezone
from supabase_client import get_supabase
from utils import get_current_user_id

profile_bp = Blueprint("profile", __name__, url_prefix="/api")


@profile_bp.get("/me")
def get_me():
    user_id = get_current_user_id()
    print(f"Fetching profile for user_id: {user_id}")
    sb = get_supabase()

    # 1) Try to fetch existing profile (NO .single())
    resp = (
        sb.table("profiles")
        .select(
            "user_id, full_name, avatar_url, band_goal, is_premium, premium_until, created_at, updated_at"
        )
        .eq("user_id", user_id)
        .execute()
    )

    rows = resp.data or []
    print(f"Profile query result: {rows}")

    # 2) If not found, create a default profile
    if not rows:
        now = datetime.now(timezone.utc).isoformat()
        insert_resp = (
            sb.table("profiles")
            .insert(
                {
                    "user_id": user_id,
                    "full_name": None,
                    "avatar_url": None,
                    "band_goal": None,
                    "is_premium": False,
                    "premium_until": None,
                    "created_at": now,
                    "updated_at": now,
                }
            )
            .execute()
        )
        prof = insert_resp.data[0]
        print(f"Created new profile: {prof}")
    else:
        prof = rows[0]
        print(f"Using existing profile: {prof}")

    return jsonify(prof)

@profile_bp.patch("/me")
def patch_me():
    user_id = get_current_user_id()
    print(f"Patching profile for user_id: {user_id}")
    sb = get_supabase()
    body = request.get_json(force=True) or {}
    print(f"Request body: {body}")
    allowed = {k: v for k, v in body.items() if k in {"full_name", "band_goal", "avatar_url"}}
    allowed["updated_at"] = datetime.now(timezone.utc).isoformat()
    prof = sb.table("profiles").update(allowed).eq("user_id", user_id).execute().data
    if not prof:
        return jsonify({"error": "Profile not found"}), 404
    print(f"Updated profile: {prof[0]}")
    return jsonify(prof[0])


@profile_bp.get("/faqs")
def get_faqs():
    sb = get_supabase()
    rows = sb.table("faqs").select("id,category,question,answer,sort_order").order("sort_order").execute().data or []
    return jsonify(rows)


@profile_bp.get("/testimonials")
def get_testimonials():
    sb = get_supabase()
    rows = sb.table("testimonials").select("id,name,role_or_band,quote,avatar_url,sort_order").order("sort_order").execute().data or []
    return jsonify(rows)

