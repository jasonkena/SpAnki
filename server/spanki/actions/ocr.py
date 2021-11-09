from flask import current_app

from firebase_admin import firestore
import pytesseract
from skimage import io
import cv2


def set_range(number, upper):
    if number < 0:
        return 0
    if number > upper:
        return upper
    return number


def ocr(user_hash):
    pytesseract.pytesseract.tesseract_cmd = current_app.config["TESSERACT_PATH"]

    db = firestore.client()
    photos = db.collection("users").document(user_hash).collection("photos").get()
    for photo in photos:
        bounding_boxes = photo.reference.collection("boxedCoords").get()
        if len(bounding_boxes):
            image_url = photo.get("photoURL")
            image = io.imread(image_url)
            for bounding_box in bounding_boxes:
                coords = bounding_box.to_dict()
                height, width = image.shape[:2]


                subregion = image[
                    set_range(coords["y1"], height) : set_range(coords["y2"], height),
                    set_range(coords["x1"], width) : set_range(coords["x2"], width),
                    :,
                ]

                word = pytesseract.image_to_string(
                    subregion, config=current_app.config["TESSERACT_CONFIG"]
                ).strip()

                print(word)
                coords["word"] = word
                bounding_box.reference.set(coords)
    return {"text": "success"}
