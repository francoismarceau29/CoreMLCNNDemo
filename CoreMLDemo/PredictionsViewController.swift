//
//  ViewController.swift
//  CoreMLDemo
//
//  Created by Francois Marceau on 2017-07-24.
//  Copyright © 2017 Frank Marceau. All rights reserved.
//

import UIKit
import CoreML

enum Species {
    case Cat
    case Dog
}

// Change model output/feature name from the command line tool

class PredictionsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private let model = DogAndCatCNN()
    private let trainedImageSize = CGSize(width: 64, height: 64)

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        title = "CoreML Demo"

        let takePhotoButton = UIButton()
        takePhotoButton.setTitle("Take a photo", for: .normal)
        takePhotoButton.setTitleColor(.black, for: .normal)
        takePhotoButton.sizeToFit()
        takePhotoButton.frame = CGRect(x: 100, y: 120, width: takePhotoButton.frame.size.width, height: takePhotoButton.frame.size.height)
        takePhotoButton.addTarget(self, action: #selector(takePhotoTouched), for: .touchUpInside)
        view.addSubview(takePhotoButton)

        view.backgroundColor = .white
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func takePhotoTouched() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }

    func predict(image: UIImage) -> Species? {
        do {
            if let resizedImage = resize(image: image, newSize: trainedImageSize), let pixelBuffer = resizedImage.toCVPixelBuffer() {
                let prediction = try model.prediction(data: pixelBuffer)
                if prediction.species[0].intValue == 1 {
                    return .Dog
                } else {
                    return .Cat
                }
            }
        } catch {
            print("Error while doing predictions: \(error)")
        }

        return nil
    }

    func resize(image: UIImage, newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true) {
            if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
                let species = self.predict(image: image)

                let alertController = UIAlertController(title: "Prediction", message: String(format: "The image is a %@", self.resultString(species: species)), preferredStyle: .alert)
                let action = UIAlertAction(title: "Close", style: .default, handler: nil)
                alertController.addAction(action)
                self.navigationController?.present(alertController, animated: true, completion: nil)
            }
        }
    }

    func resultString(species: Species?) -> String {
        if let species = species {
            if species == .Dog {
                return "dog"
            } else if species == .Cat {
                return "cat"
            }
        }

        return "not a cat, nor a dog"
    }
}

