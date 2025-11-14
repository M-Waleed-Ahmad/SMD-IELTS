from __future__ import annotations
from flask import Blueprint, jsonify, request, abort
from datetime import datetime, timedelta, timezone
from supabase_client import get_supabase
from utils import get_current_user_id

premium_bp = Blueprint("premium", __name__, url_prefix="/api")


@premium_bp.get("/plans")
def list_plans():
    sb = get_supabase()
    rows = sb.table("subscription_plans").select("id,name,description,price_cents,currency,billing_interval").eq("is_active", True).order("created_at", desc=True).execute().data or []
    return jsonify(rows)


@premium_bp.post("/payments/session")
def create_payment_session():
    user_id = get_current_user_id()
    body = request.get_json(force=True) or {}
    plan_id = body.get("plan_id")
    if not plan_id:
        abort(400, description="plan_id required")
    sb = get_supabase()
    plan = sb.table("subscription_plans").select("id,price_cents,currency").eq("id", plan_id).single().execute().data
    if not plan:
        abort(404, description="Plan not found")
    row = sb.table("payment_sessions").insert({
        "user_id": user_id,
        "plan_id": plan_id,
        "provider": "mock",
        "provider_session_id": f"mock_{datetime.now(timezone.utc).timestamp()}",
        "amount_cents": plan["price_cents"],
        "currency": plan["currency"],
        "status": "created",
        "created_at": datetime.now(timezone.utc).isoformat(),
    }).execute().data[0]
    return jsonify({
        "id": row["id"],
        "plan_id": plan_id,
        "amount_cents": row["amount_cents"],
        "currency": row["currency"],
        "status": row["status"],
    }), 201


@premium_bp.post("/payments/session/<ps_id>/confirm")
def confirm_payment_session(ps_id: str):
    user_id = get_current_user_id()
    sb = get_supabase()
    # Mark payment as paid
    paid = sb.table("payment_sessions").update({
        "status": "paid",
        "completed_at": datetime.now(timezone.utc).isoformat(),
    }).eq("id", ps_id).eq("user_id", user_id).execute().data
    if not paid:
        abort(404, description="Payment session not found")
    payment = sb.table("payment_sessions").select("id,plan_id").eq("id", ps_id).single().execute().data
    # Create subscription
    now = datetime.now(timezone.utc)
    sub = sb.table("subscriptions").insert({
        "user_id": user_id,
        "plan_id": payment["plan_id"],
        "payment_session_id": ps_id,
        "status": "active",
        "current_period_start": now.isoformat(),
        "current_period_end": (now + timedelta(days=30)).isoformat(),
    }).execute().data[0]
    # Update profile
    sb.table("profiles").update({
        "is_premium": True,
        "premium_until": (now + timedelta(days=30)).isoformat(),
        "updated_at": now.isoformat(),
    }).eq("user_id", user_id).execute()
    # Premium event (optional)
    try:
        sb.table("premium_events").insert({
            "user_id": user_id,
            "event_type": "grant",
            "reason": "mock_payment",
            "created_at": now.isoformat(),
        }).execute()
    except Exception:
        pass
    return jsonify({"subscription": sub, "profile": {"is_premium": True}})


@premium_bp.get("/subscriptions/current")
def current_subscription():
    user_id = get_current_user_id()
    sb = get_supabase()
    sub = (
        sb.table("subscriptions")
        .select("id,plan_id,status,current_period_start,current_period_end")
        .eq("user_id", user_id)
        .order("created_at", desc=True)
        .limit(1)
        .execute()
        .data
    )
    prof = sb.table("profiles").select("is_premium,premium_until").eq("user_id", user_id).single().execute().data
    return jsonify({"subscription": (sub[0] if sub else None), "profile": prof})

