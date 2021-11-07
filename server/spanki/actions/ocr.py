from flask import current_app

import firebase
import pytesseract


def ocr(image_name):
    pytesseract.pytesseract.tesseract_cmd = current_app.config["TESSERACT_PATH"]

    firebase = Firebase(current_app.config["FIREBASE_CONFIG"])
    storage = firebase.storage()

    image = storage.child(image_name).download("temp.jpeg")
    image = cv2.imread("temp.jpeg")

    return pytesseract.image_to_string(
        image, config=current_app.config["TESSERACT_CONFIG"]
    )
