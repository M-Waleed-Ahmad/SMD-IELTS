from __future__ import annotations
from flask import request, abort
from datetime import datetime
from decimal import Decimal


def get_current_user_id() -> str:
    user_id = request.headers.get("X-User-Id")
    if not user_id:
        abort(401, description="Missing X-User-Id header (placeholder for real auth)")
    return user_id


def to_jsonable(value):
    if isinstance(value, Decimal):
        return float(value)
    if isinstance(value, datetime):
        return value.isoformat()
    if isinstance(value, dict):
        return {k: to_jsonable(v) for k, v in value.items()}
    if isinstance(value, list):
        return [to_jsonable(v) for v in value]
    return value


def json_list(rows):
    return [to_jsonable(r) for r in rows]

