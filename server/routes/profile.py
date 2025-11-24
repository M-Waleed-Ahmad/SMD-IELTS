from __future__ import annotations

from datetime import datetime, timezone

from flask import Blueprint, jsonify, request
from postgrest.exceptions import APIError  # <-- important

from supabase_client import get_supabase
from utils import get_current_user_id

profile_bp = Blueprint("profile", __name__, url_prefix="/api")


@profile_bp.get("/me")
def get_me():
    user_id = get_current_user_id()
    print(f"[GET /me] Fetching profile for user_id: {user_id}")
    sb = get_supabase()

    # 1) Try to fetch existing profile (no .single() to avoid errors on 0 rows)
    select_q = (
        sb.table("profiles")
        .select(
            "user_id, full_name, avatar_url, band_goal, "
            "is_premium, premium_until, created_at, updated_at"
        )
        .eq("user_id", user_id)
    )

    resp = select_q.execute()
    rows = resp.data or []
    print(f"[GET /me] Initial profile query result: {rows}")

    if rows:
        prof = rows[0]
        print(f"[GET /me] Using existing profile: {prof}")
        return jsonify(prof)

    # 2) No row found: create a default profile.
    #    Make this safe under race conditions.
    now = datetime.now(timezone.utc).isoformat()
    default_row = {
        "user_id": user_id,
        "full_name": None,
        "avatar_url": None,
        "band_goal": None,
        "is_premium": False,
        "premium_until": None,
        "created_at": now,
        "updated_at": now,
    }

    try:
        insert_resp = sb.table("profiles").insert(default_row).execute()
        prof = insert_resp.data[0]
        print(f"[GET /me] Created new profile: {prof}")
        return jsonify(prof)
    except APIError as e:
        # If another request inserted at the same time, we can get a duplicate-key error.
        # In that case, just re-select and return the existing row.
        print(f"[GET /me] Insert failed with APIError: {e}")
        # PostgreSQL duplicate-key error code
        if getattr(e, "code", None) == "23505" or "duplicate key" in str(e).lower():
            print("[GET /me] Duplicate key on insert, re-selecting existing profile")
            resp2 = select_q.execute()
            rows2 = resp2.data or []
            if rows2:
                prof2 = rows2[0]
                print(f"[GET /me] Returning existing profile after duplicate: {prof2}")
                return jsonify(prof2)

        # Anything else -> bubble up as 500
        raise


@profile_bp.patch("/me")
def patch_me():
    user_id = get_current_user_id()
    print(f"[PATCH /me] Patching profile for user_id: {user_id}")
    sb = get_supabase()

    body = request.get_json(force=True) or {}
    print(f"[PATCH /me] Request body: {body}")

    allowed_fields = {"full_name", "band_goal", "avatar_url"}
    allowed = {k: v for k, v in body.items() if k in allowed_fields}

    # If nothing to update, just return the existing profile
    if not allowed:
        print("[PATCH /me] No editable fields provided, returning existing profile")
        resp = (
            sb.table("profiles")
            .select(
                "user_id, full_name, avatar_url, band_goal, "
                "is_premium, premium_until, created_at, updated_at"
            )
            .eq("user_id", user_id)
            .execute()
        )
        rows = resp.data or []
        if not rows:
            return jsonify({"error": "Profile not found"}), 404
        return jsonify(rows[0])

    allowed["updated_at"] = datetime.now(timezone.utc).isoformat()

    update_resp = (
        sb.table("profiles")
        .update(allowed)
        .eq("user_id", user_id)
        .execute()
    )

    prof_list = update_resp.data or []
    if not prof_list:
        return jsonify({"error": "Profile not found"}), 404

    prof = prof_list[0]
    print(f"[PATCH /me] Updated profile: {prof}")
    return jsonify(prof)


@profile_bp.get("/faqs")
def get_faqs():
    sb = get_supabase()
    rows = (
        sb.table("faqs")
        .select("id,category,question,answer,sort_order")
        .order("sort_order")
        .execute()
        .data
        or []
    )
    return jsonify(rows)


@profile_bp.get("/testimonials")
def get_testimonials():
    sb = get_supabase()
    rows = (
        sb.table("testimonials")
        .select("id,name,role_or_band,quote,avatar_url,sort_order")
        .order("sort_order")
        .execute()
        .data
        or []
    )
    return jsonify(rows)
