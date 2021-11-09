//
//  CameraViewController.swift
//  spanki-app
//
//  Created by Julian Castro on 11/6/21.
//

import UIKit
import AVFoundation
import FirebaseAuthUI

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    // OUTLETS
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var captureImageView: UIImageView!
    @IBOutlet weak var captureButton: UIButton!
    
    // VARIABLES
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var authUI: FUIAuth!
    var photoTaken: Photo!
    var user: spankiUser!
    var imagePicker = UIImagePickerController()
    
    // Stop the session when we leave the camera view!
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self

        captureImageView.layer.cornerRadius = 25
        
        authUI = FUIAuth.defaultAuthUI()
        // pulls currentUser
        if user == nil {
            let currentUser = authUI.auth?.currentUser
            user = spankiUser(user: currentUser!)
        }
        
        if photoTaken == nil {
            photoTaken = Photo()
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 1. SETUP CAMERA HERE
        
        // Create a new session
        captureSession = AVCaptureSession()
        // Configure the session for high resolution still photo capture. We'll use a convenient preset to that.
        captureSession.sessionPreset = .high
        
        // Activate rear camera
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
            else {
                print("Unable to access back camera!")
                return
        }
        
        // 2. MAKE AN AVCaptureDeviceInput TO ATTACH INPUT DEVICE TO SESSION. SERVES AS MIDDLE MAN TO ATTACH CAMERA.
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            // AVCapturePhotoOutput to help us attach output to the session.
            stillImageOutput = AVCapturePhotoOutput()
            
            // Add input, add output to the session.
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
               
            }
           
        }
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "AddPhoto":
            let navigationController = segue.destination as! UINavigationController
            let destination = navigationController.viewControllers.first as! PhotoViewController
            // TODO: add destination variables (user, photo)
        case "ShowPhoto":
            let destination = segue.destination as! PhotoViewController
            // TODO: add destination variables (user, photo)
        default:
            print("Couldn't find a case for a segue indentifier \(segue.identifier). This should not have happened.")
        }
    
    }
    
    func leaveViewController() {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    // LIVE PREVIEW
    func setupLivePreview() {
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        videoPreviewLayer.cornerRadius = 25
        previewView.layer.cornerRadius = 25
        previewView.layer.insertSublayer(videoPreviewLayer, at: 0)
        
        // Start the session on the background thread, so it starts immediately.
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            self.captureSession.startRunning()
            // Once the live view starts, set the preview layer to fit. Return to the main thread to do so.
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.previewView.layer.bounds
            }
        }
    }
    
    // AVCapturePhotoOutput delivers the capture photo to the assigned delegate which is our current View Controller.
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation()
            else { return }
        
        let image = UIImage(data: imageData)
        captureImageView.image = image
        photoTaken.image = image!
        photoTaken.saveData(user: user) { success in
            if success {
                print("Saved Image")
            }
            else {
                print("ERROR: Can't save image.")
            }
        }

    }

    // TAKING THE PICTURE
    @IBAction func captureButtonPressed(_ sender: UIButton) {
        // Make a jpeg file
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }

    
    
    // TODO: add imageview pressed option that sends you to the photoviewcontroller
}

extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        photoTaken = Photo()
        
        photoTaken.saveData(user: user) { success in
            if success {
                print("Saved Image")
            }
            else {
                print("ERROR: Can't save image.")
            }
        }
        dismiss(animated: true, completion: nil)
    }
     
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func libraryAlert() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (_) in
            self.accessLibrary()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(photoLibraryAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func accessLibrary() {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

}

