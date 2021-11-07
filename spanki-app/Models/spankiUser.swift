//
//  spankiUser.swift
//  spanki-app
//
//  Created by Julian Castro on 11/6/21.
//

import Foundation
import Firebase
import UIKit
import FirebaseFirestore
import FirebaseAuth

class spankiUser {
    var email: String
    var displayName: String
    var documentID: String
    
    var dictionary: [String: Any] {
        return ["email": email, "displayName": displayName, "documentID": documentID]
    }
    
    init(email: String, displayName: String, documentID: String) {
        self.email = email
        self.displayName = displayName
        self.documentID = documentID
    }
    
    convenience init(user: User) {
        let email = user.email ?? ""
        let displayName = user.displayName ?? ""
        self.init(email: email, displayName: displayName, documentID: user.uid)
    }
    
    convenience init(dictionary: [String: Any]) {
        let email = dictionary["email"] as! String? ?? ""
        let displayName = dictionary["displayName"] as! String? ?? ""
        self.init(email: email, displayName: displayName, documentID: "")

    }
    
    func saveIfNewUser(completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        
        let userRef = db.collection("users").document(documentID)
        userRef.getDocument { document, error in
            guard error == nil else {
                print("ERROR: could not access document for user \(self.documentID)")
                return completion(false)
            }
            guard document?.exists == false else {
                print("The document for user \(self.documentID) already exists. No reason to re-create it.")
                return completion(true)
            }
            
            // create new document
            let dataToSave: [String: Any] = self.dictionary
            db.collection("users").document(self.documentID).setData(dataToSave) { (error) in
                guard error == nil else {
                    print("ERROR: \(error!.localizedDescription), could not save data for \(self.documentID)")
                    return completion(false)
                }
                return completion(true)
            }
        }
    }
}
