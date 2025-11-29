from __future__ import annotations

import json
import logging
from typing import Any, Dict

from ai_client import client, MODEL_NAME  # <-- new import

logger = logging.getLogger(__name__)


def _parse_json_response(raw_text: str) -> Dict[str, Any]:
    """
    Gemini sometimes wraps JSON in code fences; strip and parse safely.
    """
    text = raw_text.strip()
    if text.startswith("```"):
        parts = text.split("```")
        if len(parts) >= 2:
            text = parts[1].strip()
            if text.lower().startswith("json"):
                text = text[4:].strip()
    try:
        return json.loads(text)
    except Exception as exc:  # pragma: no cover - defensive parsing
        logger.exception("Failed to parse Gemini JSON response: %s", text)
        raise ValueError("Gemini response not valid JSON") from exc


def evaluate_ielts_writing(
    prompt: str,
    candidate_answer: str,
    task_type: str,
    target_band: float,
) -> Dict[str, Any]:
    """
    Evaluate an IELTS writing response using Gemini and return the parsed JSON payload.
    Uses the new google.genai client.
    """
    system_prompt = (
        "You are an official IELTS Writing examiner. "
        "Score the candidate strictly by IELTS criteria and respond with JSON ONLY using the schema: "
        '{"overall_band": float, "task_response": float, "coherence_and_cohesion": float, '
        '"lexical_resource": float, "grammatical_range_and_accuracy": float, '
        '"is_good_enough": bool, "feedback_short": str, "feedback_detailed": str, "model_answer": str}. '
        "Do not include any text outside the JSON object."
    )

    user_content = (
        f"Task type: {task_type}\n"
        f"Target band threshold: {target_band}\n"
        f"Question prompt:\n{prompt}\n\n"
        f"Candidate answer:\n{candidate_answer}\n"
    )

    response = client.models.generate_content(
        model=MODEL_NAME,
        contents=[
            {
                "role": "user",
                "parts": [
                    {"text": system_prompt},
                    {"text": user_content},
                ],
            }
        ],
    )

    return _parse_json_response(response.text)


def evaluate_ielts_speaking(
    audio_bytes: bytes,
    audio_mime_type: str,
    question_text: str,
    target_band: float,
) -> Dict[str, Any]:
    """
    Evaluate an IELTS speaking attempt (audio) via Gemini using the new google.genai client.
    """
    system_prompt = (
        "You are an official IELTS Speaking examiner. "
        "Listen to the provided audio and respond ONLY with JSON using the schema: "
        '{"overall_band": float, "fluency_and_coherence": float, "lexical_resource": float, '
        '"grammatical_range_and_accuracy": float, "pronunciation": float, '
        '"is_good_enough": bool, "feedback_short": str, "feedback_detailed": str, "transcript": str}. '
        "No additional commentary or code fences."
    )

    user_part = (
        f"Question: {question_text}\n"
        f"Target band threshold: {target_band}\n"
        "Evaluate the speaking performance and transcribe the response."
    )

    response = client.models.generate_content(
        model=MODEL_NAME,
        contents=[
            {
                "role": "user",
                "parts": [
                    {"text": system_prompt},
                    {
                        "inline_data": {
                            "mime_type": audio_mime_type,
                            # google-genai will handle bytes; no manual base64 needed
                            "data": audio_bytes,
                        }
                    },
                    {"text": user_part},
                ],
            }
        ],
    )

    return _parse_json_response(response.text)
