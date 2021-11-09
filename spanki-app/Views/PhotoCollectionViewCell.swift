//
//  PhotoCollectionViewCell.swift
//  spanki-app
//
//  Created by Julian Castro on 11/6/21.
//

import UIKit
import SDWebImage

class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    
    var user: spankiUser!
    var photo: Photo! {
        didSet {
            if let url = URL(string: self.photo.photoURL) {
                self.photoImageView.sd_imageTransition = .fade
                self.photoImageView.sd_imageTransition?.duration = 0.2
                self.photoImageView.sd_setImage(with: url)
            } else {
                print("URL didn't work \(self.photo.photoURL)")
                self.photo.loadImage(user: self.user) { success in
                    self.photo.saveData(user: self.user) { success in
                        print("Image updated with URL \(self.photo.photoURL)")
                    }
                }
            }
        }
    }
}
