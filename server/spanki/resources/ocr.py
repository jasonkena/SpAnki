from spanki.actions import ocr
from flask_restful import Resource
from flask import request


class OCR(Resource):
    def post(self):
        data = request.get_json(force=True)
        return ocr(data["user_hash"])
