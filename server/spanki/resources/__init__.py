from flask import Blueprint
from flask_restful import Api

api_bp = Blueprint("api", __name__, url_prefix="/api")

import spanki.resources.ocr as ocr

ocr_bp = Blueprint("ocr", ocr.__name__, url_prefix="/ocr")
ocr_api = Api(ocr_bp)
ocr_api.add_resource(ocr.OCR, "/get_ocr")

import spanki.resources.docs as docs

docs_bp = Blueprint("docs", docs.__name__, url_prefix="/docs")
docs_api = Api(docs_bp)
docs_api.add_resource(docs.Docs, "/add_word")

api_bp.register_blueprint(ocr_bp)
api_bp.register_blueprint(docs_bp)
