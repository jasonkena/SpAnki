from flask import Flask, render_template, current_app, request

from spanki.resources import api_bp

import firebase_admin
from firebase_admin import credentials


def create_app():
    # create and configure the app
    app = Flask(__name__)
    app.config.from_object("config.Config")

    app.register_blueprint(api_bp)

    cred = credentials.Certificate(app.config["FIREBASE_CRED_PATH"])
    firebase_admin.initialize_app(cred)

    @app.route("/")
    def main():
        return "welp"

    return app
