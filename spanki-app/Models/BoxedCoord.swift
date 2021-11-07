//
//  BoxedCoord.swift
//  spanki-app
//
//  Created by Julian Castro on 11/7/21.
//

import Foundation
import Firebase
import FirebaseFirestore

class BoxedCoord {
    var x1: Int
    var x2: Int
    var y1: Int
    var y2: Int
    var documentID: String

    var dictionary: [String: Any] {
        return ["x1": x1, "x2": x2, "y1": y1, "y2": y2, "documentID": documentID]
    }

    init(x1: Int, x2: Int, y1: Int, y2: Int, documentID: String) {
        self.x1 = x1
        self.x2 = x2
        self.y1 = y1
        self.y2 = y2
        self.documentID = documentID
    }

    convenience init(dictionary: [String: Any]) {
        let x1 = dictionary["x1"] as! Int? ?? 0
        let x2 = dictionary["x2"] as! Int? ?? 0
        let y1 = dictionary["y1"] as! Int? ?? 0
        let y2 = dictionary["y2"] as! Int? ?? 0

        self.init(x1: x1, x2: x2, y1: y1, y2: y2, documentID: "")
    }
    
    convenience init() {
        self.init(x1: 0, x2: 0, y1: 0, y2: 0, documentID: "")
    }

    func saveData(user: spankiUser, photo: Photo, completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()

        // Create the dictionary representing the data we want to save
        let dataToSave: [String: Any] = self.dictionary
        if self.documentID == "" {
            var ref: DocumentReference? = nil
            ref = db.collection("users").document(user.documentID).collection("photos").document(photo.documentID).collection("boxedCoords").addDocument(data: dataToSave){ (error) in
                guard error == nil else {
                    print("*** ERROR: updating document \(self.documentID) in group \(user.documentID) \(error!.localizedDescription)")
                    return completed(false)
                }
                self.documentID = ref!.documentID
                print("^^^ Document updated with ref ID \(ref!.documentID)")
                // TODO: increase number of trips by 1 and decrease if deleted
                completed(true)
                
            }
        } else {
            let ref = db.collection("users").document(user.documentID).collection("photos").document(photo.documentID).collection("boxedCoords").document(self.documentID) // Let firestore create the new documentID
            ref.setData(dataToSave) { (error) in
                guard error == nil else {
                    print("*** ERROR: creating new document in spot \(user.documentID) for new review documentID \(error!.localizedDescription)")
                    return completed(false)
                }
                print("^^^ new document created with ref ID \(self.documentID ?? "unknown")")
                // TODO: increase number of trips by 1 and decrease if deleted
                completed(true)
            }
        }
    }
}
