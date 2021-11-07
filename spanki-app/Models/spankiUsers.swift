//
//  spankiUsers.swift
//  spanki-app
//
//  Created by Julian Castro on 11/6/21.
//

import Foundation
import Firebase

class spankiUsers {
    var spankiUserArray = [spankiUser]()
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping () -> ()) {
        db.collection("users").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("*** ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            
            self.spankiUserArray = []
            for document in querySnapshot!.documents {
                let spankiUser = spankiUser(dictionary: document.data())
                spankiUser.documentID = document.documentID
                self.spankiUserArray.append(spankiUser)
            }
        }
    }
}
