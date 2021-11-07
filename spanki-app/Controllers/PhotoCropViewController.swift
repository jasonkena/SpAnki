//
//  PhotoCropViewController.swift
//  spanki-app
//
//  Created by Julian Castro on 11/6/21.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseAuthUI

class PhotoCropViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var photo: Photo!
    var boxedCoord: BoxedCoord!
    var authUI: FUIAuth!
    var user: spankiUser!
    
    var startPoint: CGPoint?
    
    let rectShapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 3
        return shapeLayer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUserInterface()
        
        authUI = FUIAuth.defaultAuthUI()
        // pulls currentUser
        if user == nil {
            let currentUser = authUI.auth?.currentUser
            user = spankiUser(user: currentUser!)
        }
        
        if boxedCoord == nil {
            boxedCoord = BoxedCoord()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let startPoint = startPoint else { return }

        let currentPoint: CGPoint

        if let predicted = event?.predictedTouches(for: touch), let lastPoint = predicted.last {
            currentPoint = lastPoint.location(in: imageView)
        } else {
            currentPoint = touch.location(in: imageView)
        }
        let frame = rect(from: startPoint, to: currentPoint)
        // you might do something with `frame`, e.g. show bounding box
        rectShapeLayer.path = UIBezierPath(rect: frame).cgPath
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        startPoint = nil
        guard let touch = touches.first else { return }
        startPoint = touch.location(in: imageView)
        // you might want to initialize whatever you need to begin showing selected rectangle below, e.g.
        rectShapeLayer.path = nil
        
        imageView.layer.addSublayer(rectShapeLayer)
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let startPoint = startPoint else { return }

        let currentPoint = touch.location(in: imageView)

        let height = Int(imageView.image?.size.height ?? 0)
        let width = Int(imageView.image?.size.width ?? 0)
        //let originalScale = imageView.image?.scale ?? 0
        let originalScale = imageView.image!.size.height / imageView.frame.height
        print(originalScale)
        print(startPoint.x)
        print(startPoint.y)
        print(currentPoint.x)
        print(currentPoint.y)

        print(CGFloat(height) * originalScale)
        print(CGFloat(width) * originalScale)
        
        boxedCoord.x1 = Int(CGFloat(startPoint.x) * originalScale)
        boxedCoord.y1 = Int(CGFloat(startPoint.y) * originalScale)
        boxedCoord.x2 = Int(CGFloat(currentPoint.x) * originalScale)
        boxedCoord.y2 = Int(CGFloat(currentPoint.y) * originalScale)
    
        boxedCoord.saveData(user: user, photo: photo) { success in
            if success {
                print("Added Boxed Coord succesfully")
            } else {
                print("ERROR in adding Boxed Coord")
            }
        }
        
        let frame = rect(from: startPoint, to: currentPoint)
        
        // you might do something with `frame`, e.g. remove bounding box but take snapshot of selected `CGRect`

        rectShapeLayer.removeFromSuperlayer()
        //let image = imageView.snapshot(rect: frame, afterScreenUpdates: true)

        // do something with this `image`
        //imageView.image = image
    }
    
    private func rect(from: CGPoint, to: CGPoint) -> CGRect {
        return CGRect(x: min(from.x, to.x),
               y: min(from.y, to.y),
               width: abs(to.x - from.x),
               height: abs(to.y - from.y))
    }
    
    func updateUserInterface() {
        guard let url = URL(string: photo.photoURL) else {
            print("URL Didn't Work")
            // Is new image
            imageView.image = photo.image
            return
        }
        imageView.sd_imageTransition = .fade
        imageView.sd_imageTransition?.duration = 0.5
        imageView.sd_setImage(with: url)
    }
    
    func leaveViewController() {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        
//        let parameters = ["image_hash": photo.documentID, "user_hash": user.documentID]
//
//        guard let url = URL(string: "https://cscigpu06:5000/api/ocr/get_ocr") else { return }
//
//        let session = URLSession.shared
//
//        let request = NSMutableURLRequest(url: url)
//        request.httpMethod = "POST"
//
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
//        } catch let error {
//            print(error.localizedDescription)
//        }
//
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//
//        //create dataTask using the session object to send data to the server
//
//        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
//
//            guard error == nil else {
//                return
//            }
//
//            guard let data = data else {
//                return
//            }
//
//            //
//            //
//            do {
//                //create json object from data
//                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
//                    print(json)
//                    // handle json...
//                }
//            } catch let error {
//                print(error.localizedDescription)
//            }
//        })
//        task.resume()
//
        leaveViewController()
    }
}


extension UIView {

    /// Create image snapshot of view.
    ///
    /// - Parameters:
    ///   - rect: The coordinates (in the view's own coordinate space) to be captured. If omitted, the entire `bounds` will be captured.
    ///   - afterScreenUpdates: A Boolean value that indicates whether the snapshot should be rendered after recent changes have been incorporated. Specify the value false if you want to render a snapshot in the view hierarchy’s current state, which might not include recent changes.
    /// - Returns: The `UIImage` snapshot.

    func snapshot(rect: CGRect? = nil, afterScreenUpdates: Bool = true) -> UIImage {
        return UIGraphicsImageRenderer(bounds: rect ?? bounds).image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: afterScreenUpdates)
        }
    }
}
