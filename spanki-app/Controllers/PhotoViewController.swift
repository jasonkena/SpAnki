//
//  PhotoViewController.swift
//  spanki-app
//
//  Created by Julian Castro on 11/6/21.
//

import UIKit
import FirebaseAuthUI
import FirebaseAuth

class PhotoViewController: UIViewController {

    @IBOutlet weak var addWordBarButton: UIBarButtonItem!
    @IBOutlet weak var backBarButton: UIBarButtonItem!
    @IBOutlet weak var photoImageView: UIImageView!

    
    // TODO: add user variable for current user
    var user: spankiUser!
    var authUI: FUIAuth!
    var photo: Photo!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        authUI = FUIAuth.defaultAuthUI()
        // pulls currentUser
        if user == nil {
            let currentUser = authUI.auth?.currentUser
            user = spankiUser(user: currentUser!)
        }
        
        if photo == nil {
            photo = Photo()
        }
        updateUserInterface()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "CropPhoto":
            let navigationController = segue.destination as! UINavigationController
            let destination = navigationController.viewControllers.first as! PhotoCropViewController
            destination.photo = photo
        default:
            print("Couldn't find a case for a segue indentifier \(segue.identifier). This should not have happened.")
        }
    }
    
    func updateUserInterface() {
        guard let url = URL(string: photo.photoURL) else {
            print("URL Didn't Work")
            // Is new image
            photoImageView.image = photo.image
            return
        }
        photoImageView.sd_imageTransition = .fade
        photoImageView.sd_imageTransition?.duration = 0.5
        photoImageView.sd_setImage(with: url)
    }
    
    func leaveViewController() {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    @IBAction func addWordBarButtonPressed(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func backBarButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
}

    

