from spanki.actions import ocr
from flask_restful import Resource


class OCR(Resource):
    def post(self, image_hash):
        word = ocr(image_hash)
        return {"word": word}
