from __future__ import annotations
from flask import Blueprint, jsonify, request, abort
from datetime import datetime, timezone
from supabase_client import get_supabase
from utils import get_current_user_id

exam_bp = Blueprint("exam", __name__, url_prefix="/api")


def _ensure_premium(user_id: str):
    sb = get_supabase()
    prof = sb.table("profiles").select("is_premium").eq("user_id", user_id).single().execute().data
    if not (prof and prof.get("is_premium")):
        abort(403, description="Full exam simulations are for Premium users")


@exam_bp.post("/exam-sessions")
def create_exam_session():
    user_id = get_current_user_id()
    _ensure_premium(user_id)
    sb = get_supabase()
    row = sb.table("exam_sessions").insert({
        "user_id": user_id,
        "started_at": datetime.now(timezone.utc).isoformat(),
    }).execute().data[0]
    return jsonify({"exam_session_id": row["id"]}), 201


@exam_bp.post("/exam-sections")
def create_exam_section():
    user_id = get_current_user_id()
    body = request.get_json(force=True) or {}
    exam_session_id = body.get("exam_session_id")
    skill_slug = body.get("skill_slug")
    if not exam_session_id or not skill_slug:
        abort(400, description="exam_session_id and skill_slug required")
    sb = get_supabase()
    sess = sb.table("exam_sessions").select("id,user_id").eq("id", exam_session_id).single().execute().data
    if not sess or sess["user_id"] != user_id:
        abort(404, description="Exam session not found")
    skill = sb.table("skills").select("id").eq("slug", skill_slug).single().execute().data
    if not skill:
        abort(404, description="Skill not found")
    row = sb.table("exam_section_results").insert({
        "exam_session_id": exam_session_id,
        "skill_id": skill["id"],
        "started_at": datetime.now(timezone.utc).isoformat(),
    }).execute().data[0]
    return jsonify({"section_result_id": row["id"]}), 201


@exam_bp.post("/exam-answers")
def add_exam_answer():
    user_id = get_current_user_id()
    body = request.get_json(force=True) or {}
    exam_session_id = body.get("exam_session_id")
    section_result_id = body.get("section_result_id")
    question_id = body.get("question_id")
    option_id = body.get("option_id")
    answer_text = body.get("answer_text")
    if not (exam_session_id and section_result_id and question_id):
        abort(400, description="exam_session_id, section_result_id, question_id required")
    sb = get_supabase()
    sess = sb.table("exam_sessions").select("id,user_id").eq("id", exam_session_id).single().execute().data
    if not sess or sess["user_id"] != user_id:
        abort(404, description="Exam session not found")
    q = sb.table("questions").select("id,skill_id").eq("id", question_id).single().execute().data
    if not q:
        abort(404, description="Question not found")
    is_correct = None
    if option_id:
        correct = sb.table("question_options").select("id").eq("question_id", question_id).eq("is_correct", True).single().execute().data
        if correct:
            is_correct = (option_id == correct["id"])
    row = sb.table("exam_answers").insert({
        "exam_session_id": exam_session_id,
        "section_result_id": section_result_id,
        "skill_id": q["skill_id"],
        "question_id": question_id,
        "option_id": option_id,
        "answer_text": answer_text,
        "is_correct": is_correct,
        "answered_at": datetime.now(timezone.utc).isoformat(),
    }).execute().data[0]
    return jsonify(row), 201


@exam_bp.post("/exam-sections/<section_id>/complete")
def complete_section(section_id: str):
    user_id = get_current_user_id()
    body = request.get_json(force=True) or {}
    time_taken = body.get("time_taken_seconds")
    total_questions = body.get("total_questions")
    sb = get_supabase()
    sec = sb.table("exam_section_results").select("id,exam_session_id").eq("id", section_id).single().execute().data
    if not sec:
        abort(404, description="Section not found")
    sess = sb.table("exam_sessions").select("user_id").eq("id", sec["exam_session_id"]).single().execute().data
    if not sess or sess["user_id"] != user_id:
        abort(404, description="Exam session not found")
    correct = sb.table("exam_answers").select("id", count="exact").eq("section_result_id", section_id).eq("is_correct", True).execute().count or 0
    score = float(correct) / total_questions * 100 if total_questions else 0.0
    updated = sb.table("exam_section_results").update({
        "completed_at": datetime.now(timezone.utc).isoformat(),
        "time_taken_seconds": time_taken,
        "total_questions": total_questions,
        "correct_questions": correct,
        "score": score,
    }).eq("id", section_id).execute().data[0]
    return jsonify(updated)


@exam_bp.post("/exam-sessions/<exam_id>/complete")
def complete_exam(exam_id: str):
    user_id = get_current_user_id()
    body = request.get_json(silent=True) or {}
    total_time = body.get("total_time_seconds")
    sb = get_supabase()
    sess = sb.table("exam_sessions").select("id,user_id").eq("id", exam_id).single().execute().data
    if not sess or sess["user_id"] != user_id:
        abort(404, description="Exam session not found")
    updated = sb.table("exam_sessions").update({
        "completed_at": datetime.now(timezone.utc).isoformat(),
        "total_time_seconds": total_time,
    }).eq("id", exam_id).execute().data[0]

    # Build summary
    sections = (
        sb.table("exam_section_results")
        .select("id,skill_id,time_taken_seconds,total_questions,correct_questions,score")
        .eq("exam_session_id", exam_id)
        .execute()
        .data
        or []
    )
    out_sections = []
    for s in sections:
        skill = sb.table("skills").select("slug").eq("id", s["skill_id"]).single().execute().data
        answers = (
            sb.table("exam_answers")
            .select("question_id,option_id,answer_text,is_correct")
            .eq("section_result_id", s["id"]).execute().data
            or []
        )
        # Attach prompt and user_answer text
        for a in answers:
            q = sb.table("questions").select("prompt").eq("id", a["question_id"]).single().execute().data
            a["prompt"] = q["prompt"] if q else None
            user_answer = a.get("answer_text")
            if a.get("option_id"):
                opt = sb.table("question_options").select("text").eq("id", a["option_id"]).single().execute().data
                if opt:
                    user_answer = opt["text"]
            a["user_answer"] = user_answer
            a.pop("option_id", None)
        out_sections.append({
            "section_result_id": s["id"],
            "skill_slug": skill["slug"],
            "time_taken_seconds": s.get("time_taken_seconds"),
            "total_questions": s.get("total_questions"),
            "correct_questions": s.get("correct_questions"),
            "score": s.get("score"),
            "answers": answers,
        })
    summary = {"exam_session": updated, "sections": out_sections}
    return jsonify(summary)
