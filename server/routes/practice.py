from __future__ import annotations
from flask import Blueprint, jsonify, request, abort
from datetime import datetime, timezone
from supabase_client import get_supabase
from utils import get_current_user_id, to_jsonable
from ai_helpers import evaluate_ielts_writing

practice_bp = Blueprint("practice", __name__, url_prefix="/api")


def _get_profile(user_id: str):
    sb = get_supabase()
    res = sb.table("profiles").select("user_id,is_premium").eq("user_id", user_id).single().execute()
    return res.data


@practice_bp.post("/practice-sessions")
def create_practice_session():
    user_id = get_current_user_id()
    sb = get_supabase()
    body = request.get_json(force=True) or {}
    ps_id = body.get("practice_set_id")
    if not ps_id:
        abort(400, description="practice_set_id required")
    ps = sb.table("practice_sets").select("id,title,estimated_minutes,is_premium").eq("id", ps_id).single().execute().data
    if not ps:
        abort(404, description="Practice set not found")
    profile = _get_profile(user_id)
    if ps.get("is_premium") and not (profile and profile.get("is_premium")):
        abort(403, description="Premium required for this practice set")
    started_at = datetime.now(timezone.utc).isoformat()
    row = sb.table("practice_sessions").insert({
        "user_id": user_id,
        "practice_set_id": ps_id,
        "started_at": started_at,
    }).execute().data[0]
    return jsonify({
        "id": row["id"],
        "practice_set": {"id": ps_id, "title": ps["title"], "estimated_minutes": ps["estimated_minutes"]},
        "started_at": started_at,
    }), 201


@practice_bp.post("/practice-sessions/<session_id>/answers")
def add_practice_answer(session_id: str):
    user_id = get_current_user_id()
    sb = get_supabase()
    sess = sb.table("practice_sessions").select("id,user_id").eq("id", session_id).single().execute().data
    if not sess or sess["user_id"] != user_id:
        abort(404, description="Session not found")
    body = request.get_json(force=True) or {}
    q_id = body.get("question_id")
    option_id = body.get("option_id")
    answer_text = body.get("answer_text")
    if not q_id:
        abort(400, description="question_id required")
    q = sb.table("questions").select("id,type").eq("id", q_id).single().execute().data
    if not q:
        abort(404, description="Question not found")
    is_correct = None
    if option_id:
        correct = (
            sb.table("question_options").select("id").eq("question_id", q_id).eq("is_correct", True).single().execute().data
        )
        if correct:
            is_correct = (option_id == correct["id"])
    row = sb.table("practice_answers").insert({
        "session_id": session_id,
        "question_id": q_id,
        "option_id": option_id,
        "answer_text": answer_text,
        "is_correct": is_correct,
        "answered_at": datetime.now(timezone.utc).isoformat(),
    }).execute().data[0]
    return jsonify(row), 201


@practice_bp.post("/writing-eval/practice/<practice_answer_id>")
def create_writing_eval_for_practice(practice_answer_id: str):
    user_id = get_current_user_id()
    sb = get_supabase()
    body = request.get_json(silent=True) or {}
    target_band = float(body.get("target_band") or 7.0)

    ans = (
        sb.table("practice_answers")
        .select("id,question_id,answer_text,session_id")
        .eq("id", practice_answer_id)
        .single()
        .execute()
        .data
    )
    if not ans:
        abort(404, description="Practice answer not found")

    sess = (
        sb.table("practice_sessions")
        .select("user_id")
        .eq("id", ans["session_id"])
        .single()
        .execute()
        .data
    )
    if not sess or sess["user_id"] != user_id:
        abort(404, description="Session not found")

    q = sb.table("questions").select("id,prompt,task_type").eq("id", ans["question_id"]).single().execute().data
    if not q:
        abort(404, description="Question not found")

    eval_res = evaluate_ielts_writing(
        q.get("prompt") or "",
        ans.get("answer_text") or "",
        q.get("task_type") or "Task 2",
        target_band,
    )
    print("Writing eval result:", eval_res)

    row = (
        sb.table("writing_evaluations")
        .insert(
            {
                "mode": "practice",
                "practice_answer_id": practice_answer_id,
                "exam_answer_id": None,
                "exam_session_id": None,
                "exam_section_result_id": None,
                "user_id": user_id,
                "question_id": q["id"],
                "overall_band": eval_res.get("overall_band"),
                "band_task_response": eval_res.get("task_response"),
                "band_coherence": eval_res.get("coherence_and_cohesion"),
                "band_lexical": eval_res.get("lexical_resource"),
                "band_grammar": eval_res.get("grammatical_range_and_accuracy"),
                "is_good_enough": eval_res.get("is_good_enough"),
                "feedback_short": eval_res.get("feedback_short"),
                "feedback_detailed": eval_res.get("feedback_detailed"),
                "model_answer": eval_res.get("model_answer"),
            }
        )
        .execute()
        .data[0]
    )
    print("Inserted writing eval:", row)
    return jsonify(to_jsonable(row)), 201


@practice_bp.post("/practice-sessions/<session_id>/complete")
def complete_practice_session(session_id: str):
    user_id = get_current_user_id()
    sb = get_supabase()

    # 1) Validate session ownership
    sess = (
        sb.table("practice_sessions")
        .select("id,user_id,practice_set_id")
        .eq("id", session_id)
        .single()
        .execute()
        .data
    )
    if not sess or sess["user_id"] != user_id:
        abort(404, description="Session not found")

    body = request.get_json(silent=True) or {}
    time_taken = body.get("time_taken_seconds") or 0
    ps_id = sess["practice_set_id"]

    # 2) Load all answers for this session
    answers_raw = (
        sb.table("practice_answers")
        .select("id, question_id, option_id, answer_text, is_correct")
        .eq("session_id", session_id)
        .execute()
        .data
        or []
    )

    answer_ids = [a["id"] for a in answers_raw]
    writing_evals = (
        sb.table("writing_evaluations")
        .select("*")
        .in_("practice_answer_id", answer_ids if answer_ids else ["_none_"])
        .execute()
        .data
        or []
    )
    writing_by_answer = {w["practice_answer_id"]: w for w in writing_evals}

    # 3) Fetch all questions + options for this practice set
    qrows = (
        sb.table("questions")
        .select("id, prompt, question_options(id, text, is_correct)")
        .eq("practice_set_id", ps_id)
        .execute()
        .data
        or []
    )
    qmap = {q["id"]: q for q in qrows}

    # 4) Build enriched answer list
    enriched_answers = []
    for ans in answers_raw:
        qid = ans["question_id"]
        q = qmap.get(qid)
        w_eval = writing_by_answer.get(ans["id"])

        prompt = q["prompt"] if q else None
        raw_opts = q.get("question_options", []) if q else []

        option_map = {opt["id"]: opt for opt in raw_opts}
        user_option = option_map.get(ans["option_id"])
        user_option_text = user_option["text"] if user_option else None

        correct_option_text = None
        for opt in raw_opts:
            if opt.get("is_correct") is True:
                correct_option_text = opt["text"]
                break

        user_answer_final = ans["answer_text"] or user_option_text

        enriched_answers.append(
            {
                "question_id": qid,
                "prompt": prompt,
                "user_answer": user_answer_final,
                "user_option_text": user_option_text,
                "answer_text": ans["answer_text"],
                "is_correct": ans["is_correct"],
                "correct_option_text": correct_option_text,
                "correct_answer": correct_option_text,  # alias for frontend
                "writing_eval": to_jsonable(w_eval) if w_eval else None,
            }
        )

    # 5) Calculate stats
    total_q = (
        sb.table("questions")
        .select("id", count="exact")
        .eq("practice_set_id", ps_id)
        .execute()
        .count
        or 0
    )
    total_correct = sum(1 for a in answers_raw if a.get("is_correct") is True)
    completed_at = datetime.now(timezone.utc).isoformat()
    score = float(total_correct) / total_q * 100 if total_q else 0.0

    # 6) Update session meta
    sb.table("practice_sessions").update(
        {
            "completed_at": completed_at,
            "time_taken_seconds": time_taken,
            "total_questions": total_q,
            "correct_questions": total_correct,
            "score": score,
        }
    ).eq("id", session_id).execute()

    # 7) Get practice set & skill
    ps = (
        sb.table("practice_sets")
        .select("id,title,skill_id")
        .eq("id", ps_id)
        .single()
        .execute()
        .data
    )
    skill = (
        sb.table("skills")
        .select("slug, name")
        .eq("id", ps["skill_id"])
        .single()
        .execute()
        .data
    )

    # 8) Final response
    return jsonify(
        {
            "practice_set": {
                "id": ps["id"],
                "title": ps["title"],
                "skill_slug": skill["slug"],
                "skill_name": skill.get("name"),
            },
            "stats": {
                "total_questions": total_q,
                "correct_questions": total_correct,
                "time_taken_seconds": time_taken,
                "score": score,
            },
            "answers": enriched_answers,
            "writing_evaluations": [to_jsonable(w) for w in writing_evals],
            "completed_at": completed_at,
        }
    )


@practice_bp.get("/practice-sessions/recent")
def recent_sessions():
    user_id = get_current_user_id()
    sb = get_supabase()
    rows = (
        sb.table("practice_sessions")
        .select("id,practice_set_id,completed_at,total_questions,correct_questions,score")
        .eq("user_id", user_id)
        .order("completed_at", desc=True)
        .limit(10)
        .execute()
        .data
        or []
    )
    # Attach practice set title and skill slug
    out = []
    for r in rows:
        ps = (
            sb.table("practice_sets").select("title,skill_id").eq("id", r["practice_set_id"]).single().execute().data
        )
        skill = sb.table("skills").select("slug").eq("id", ps["skill_id"]).single().execute().data
        r.update({"practice_set_title": ps["title"], "skill_slug": skill["slug"]})
        out.append(r)
    return jsonify(out)

