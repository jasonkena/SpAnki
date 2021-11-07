//
//  Photo.swift
//  spanki-app
//
//  Created by Julian Castro on 11/6/21.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class Photo {
    
    var image: UIImage
    var photoUserID: String
    var photoUserEmail: String
    var photoURL: String
    var timeStamp: Date
    var documentID: String
    
    var dictionary: [String: Any] {
        
        let timeIntervalDate = timeStamp.timeIntervalSince1970
        return ["photoUserID": photoUserID, "photoUserEmail": photoUserEmail, "photoURL": photoURL, "timeStamp": timeIntervalDate]
        
    }
    
    init(image: UIImage, photoUserID: String, photoUserEmail: String, photoURL: String, timeStamp: Date, documentID: String)
    {
        
        self.image = image
        self.photoUserID = photoUserID
        self.photoUserEmail = photoUserEmail
        self.photoURL = photoURL
        self.timeStamp = timeStamp
        self.documentID = documentID
        
    }
    
    convenience init() {
        let photoUserID = Auth.auth().currentUser?.uid ?? ""
        let photoUserEmail = Auth.auth().currentUser?.uid ?? "Unknown Email"
        self.init(image: UIImage(), photoUserID: photoUserID, photoUserEmail: photoUserEmail, photoURL: "", timeStamp: Date(), documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let timeIntervalDate = dictionary["timeStamp"] as! TimeInterval? ?? TimeInterval()
        let timeStamp = Date(timeIntervalSince1970: timeIntervalDate)
        let photoUserID = dictionary["photoUserID"] as! String? ?? ""
        let photoUserEmail = dictionary["photoUserEmail"] as! String? ?? ""
        let photoURL = dictionary["photoURL"] as! String? ?? ""

        self.init(image: UIImage(), photoUserID: photoUserID, photoUserEmail: photoUserEmail, photoURL: photoURL, timeStamp: timeStamp, documentID: "")
    }
    
    func saveData(user: spankiUser, completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        let storage = Storage.storage()
        
        guard let photoData = self.image.jpegData(compressionQuality: 0.5) else {
            print("ERROR: Could not convert photo.image \(image)")
            return
        }
        
        // create metadata so that we can see images in the Firebase Storage Console
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        
        // create filename if necessary
        if documentID == "" {
            documentID = UUID().uuidString
        }
        
        // create a storage reference to upload this iamge file to the user's folder
        let storageRef = storage.reference().child(user.documentID).child(documentID)
        
        // create an uploadTask
        let uploadTask = storageRef.putData(photoData, metadata: uploadMetaData) { (metadata, error) in
            if let error = error {
                print("ERROR: Upload for ref \(uploadMetaData) failed. \(error.localizedDescription)")
            }
        }
        
        uploadTask.observe(.success) { (snapshot) in
            print("Upload to Firebase Storage was succesful!")
            storageRef.downloadURL { url, error in
                guard error == nil else {
                    print("ERROR: couldn't create a download URL \(error!.localizedDescription)")
                    return completion(false)
                }
                
                guard let url = url else {
                    print("ERROR: url was nil and this should not have happened because we've already shown there was no error.")
                    return completion(false)
                }
                self.photoURL = "\(url)"
                let dataToSave = self.dictionary
                if self.documentID != "" {
                    let ref = db.collection("users").document(user.documentID).collection("photos").document(self.documentID)
                    ref.setData(dataToSave) { (error) in
                        guard error == nil else {
                            print("ERROR: updating document \(error!.localizedDescription)")
                            return completion(false)
                        }
                        print("UPDATED DOCUMENT: \(self.documentID) in user: \(user.documentID)")
                        completion(true)
                    }
                } else {
                    var ref: DocumentReference? = nil
                    ref = db.collection("users").document(user.documentID).collection("photos").addDocument(data: dataToSave) { error in
                        if let error = error {
                            print("*** ERROR: creating new document in user \(user.documentID) for new review documentID \(error.localizedDescription)")
                            completion(false)
                        } else {
                            print("New document created with ref ID \(ref?.documentID ?? "unknown")")
                            completion(true)
                        }
                    }
                }
            }
        }
        
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error {
                print("ERROR: upload task for file \(self.documentID) failed, in spot \(user.documentID), with error \(error.localizedDescription)")
            }
            completion(false)
        }
    }
    
    func loadImage(user: spankiUser, completion: @escaping (Bool) -> ()) {
        guard user.documentID != "" else {
            print("ERROR: did not pass a valid spot into loadImage")
            return
        }
        let storage = Storage.storage()
        let storageRef = storage.reference().child(user.documentID).child(documentID)
        storageRef.getData(maxSize: 25 * 1024 * 1024) { data, error in
            if let error = error {
                print("ERROR: an error occurred while reading data from file ref: \(storageRef) error = \(error.localizedDescription)")
                return completion(false)
            }
            else {
                self.image = UIImage(data: data!) ?? UIImage()
                return completion(true)
            }
        }
    }
    
}
