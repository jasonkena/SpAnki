from spanki.actions import add_word
from flask_restful import Resource
from flask import request


class Docs(Resource):
    def post(self):
        data = request.get_json(force=True)
        word = data["word"]
        email = data["email"]

        return add_word(word, email)
