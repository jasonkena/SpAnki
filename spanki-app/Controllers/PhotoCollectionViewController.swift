//
//  PhotoCollectionViewController.swift
//  spanki-app
//
//  Created by Julian Castro on 11/6/21.
//

import UIKit
import FirebaseAuthUI
import SDWebImage

class PhotoCollectionViewController: UICollectionViewController {

    var photos: Photos!
    var user: spankiUser!
    var authUI: FUIAuth!
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        
        photos = Photos()
        
        authUI = FUIAuth.defaultAuthUI()
        // pulls currentUser
        if user == nil {
            let currentUser = authUI.auth?.currentUser
            user = spankiUser(user: currentUser!)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        photos.loadData(user: user) {
            self.photoCollectionView.reloadData()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "ShowPhoto":
            let destination = segue.destination as! PhotoViewController
            guard let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first else {
                print("ERROR: couldn't get selected collectionView item")
                return
            }
            destination.photo = photos.photoArray[selectedIndexPath.row]
            destination.user = user
        default:
            print("Couldn't find a case for segue identifier \(segue.identifier ?? "Unknown"). This should not have happened.")
        }
    }
    
}

extension PhotoCollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.photoArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! PhotoCollectionViewCell
        cell.user = user
        cell.photo = photos.photoArray[indexPath.row]
        return cell
    }
}


