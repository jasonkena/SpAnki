from flask import current_app

from firebase_admin import firestore


def add_word(word, email):
    word = word.strip()

    db = firestore.client()
    users = db.collection("users")
    user = users.where("email", "==", email).get()
    assert len(user) == 1

    data = {"word": word}
    collections = list(user[0].reference.collections())
    docs = [collection for collection in collections if collection.id == "docs"]

    assert len(docs) == 1
    docs[0].document(word).set(data)

    return {"text": "success"}
