from __future__ import annotations
import os
from flask import Flask, jsonify
from routes.content import content_bp
from routes.practice import practice_bp
from routes.exam import exam_bp
from routes.premium import premium_bp
from routes.profile import profile_bp


def create_app() -> Flask:
    app = Flask(__name__)

    # Health check
    @app.get("/health")
    def health():
        return jsonify({"ok": True})

    # Register blueprints
    app.register_blueprint(content_bp)
    app.register_blueprint(practice_bp)
    app.register_blueprint(exam_bp)
    app.register_blueprint(premium_bp)
    app.register_blueprint(profile_bp)

    return app


app = create_app()

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port, debug=True)

