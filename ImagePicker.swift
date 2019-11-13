//
//  ImagePicker.swift
//  Beeconz
//
//  Created by Umair on 24/02/2019.
//  Copyright © 2019 beeconz. All rights reserved.
//

import Foundation
import UIKit

// MARK: -

protocol ImagePickerDelegate: class {
    func didSelect(image: UIImage?)
    func didRemove()
}

// MARK: -

class ImagePicker: NSObject {
    
    // MARK: -
    
    fileprivate let pickerController: UIImagePickerController
    fileprivate weak var presentationController: UIViewController?
    fileprivate weak var delegate: ImagePickerDelegate?
    
    // MARK: - Init method
    
    init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
        self.pickerController = UIImagePickerController()
        
        super.init()
        
        self.presentationController = presentationController
        self.delegate = delegate
        
        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
    }
    
    // MARK: - Public methods
    
    func present(removePhotoOption: Bool) {
        let alertController = UIAlertController(title: NSLocalizedString("ChoosePhoto", comment: ""), message: nil, preferredStyle: .actionSheet)
        
        if let action = self.action(for: .camera, title: NSLocalizedString("Camera", comment: "")) {
            alertController.addAction(action)
        }

        if let action = self.action(for: .photoLibrary, title: NSLocalizedString("PhotoLibrary", comment: "")) {
            alertController.addAction(action)
        }
        
        if removePhotoOption {
            alertController.addAction(UIAlertAction(title: NSLocalizedString("RemovePhoto", comment: ""), style: .default, handler: { (UIAlertAction) in
                self.delegate?.didRemove()
            }))
        }
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        
        self.presentationController?.present(alertController, animated: true)
    }

    // MARK: - Private methods
    
    fileprivate func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }
        
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }
    
    fileprivate func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        
        controller.dismiss(animated: true, completion: nil)
        
        self.delegate?.didSelect(image: image)
//
//        controller.dismiss(animated: false) {
//
//            if image != nil {
//
//                CropPickerController.show(presentationController: self.presentationController!, imageToUse: image!) { [weak self] (image) in
//                    guard let strongSelf = self else { return }
//
//                    strongSelf.delegate?.didSelect(image: image)
//                }
//            }
//        }
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate methods

extension ImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImage : UIImage?
        
        // Developer's Note: Cropping manually because there is a bug in iOS 11 & 12 with UIImagePickerControllerEditedImage
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImage = image
            
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImage = image
            
            
            if let cropValue = info[UIImagePickerController.InfoKey.cropRect] as? NSValue, image.cgImage != nil {
                let cropRect = cropValue.cgRectValue
                
                if let imageRef = image.cgImage!.cropping(to: cropRect) {
                    selectedImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
                }
            }   
        }

        self.pickerController(picker, didSelect: selectedImage)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - How to use

// Create property
// fileprivate var imagePicker: ImagePicker!

// Init
// imagePicker = ImagePicker(presentationController: self, delegate: self)

// Call image picker
// imagePicker.present(removePhotoOption: true)

// Listen delegates

//    func didSelect(image: UIImage?) { }
//    func didRemove() { }

