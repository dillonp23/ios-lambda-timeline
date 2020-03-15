//
//  ImagePostViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import Photos
import CoreImage
import CoreImage.CIFilterBuiltins

class ImagePostViewController: ShiftableViewController {
    
    // MARK: - View Set-Up
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageViewHeight(with: 1.0)
        
        updateViews()
    }
    
    func updateViews() {
        
        switch imageEffectSegmentedControl.selectedSegmentIndex {
        case 2:
            effectControlsStackView.isHidden = false
            topEffectLabel.text = "Radius"
            bottomEffectLabel.text = "Intensity"
        case 3:
            effectControlsStackView.isHidden = false
            bottomEffectControlsStackView.isHidden = true
            topEffectSlider.minimumValue = -200
            topEffectSlider.maximumValue = 200
            topEffectLabel.text = "Intensity"
        case 4:
            effectControlsStackView.isHidden = false
            topEffectSlider.minimumValue = 0
            topEffectSlider.maximumValue = 100
            topEffectLabel.text = "Radius"
            bottomEffectSlider.minimumValue = 0
            bottomEffectSlider.maximumValue = 1
            bottomEffectLabel.text = "Intensity"
        case 5:
            effectControlsStackView.isHidden = false
        default:
            effectControlsStackView.isHidden = true
        }
        
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else {
                title = "New Post"
                return
        }
        
        title = post?.title
        
        setImageViewHeight(with: image.ratio)
        
        imageView.image = image
        
        chooseImageButton.setTitle("", for: [])
        
    }
    
    func setImageViewHeight(with aspectRatio: CGFloat) {
        
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        
        view.layoutSubviews()
    }
    
    
    
    // MARK: - Actions
    @IBAction func createPost(_ sender: Any) {
        
        view.endEditing(true)
        
        guard let imageData = imageView.image?.jpegData(compressionQuality: 0.1),
            let title = titleTextField.text, title != "" else {
            presentInformationalAlertController(title: "Uh-oh", message: "Make sure that you add a photo and a caption before posting.")
            return
        }
        
        postController.createPost(with: title, ofType: .image, mediaData: imageData, ratio: imageView.image?.ratio) { (success) in
            guard success else {
                DispatchQueue.main.async {
                    self.presentInformationalAlertController(title: "Error", message: "Unable to create post. Try again.")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func chooseImage(_ sender: Any) {
        
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch authorizationStatus {
        case .authorized:
            presentImagePickerController()
        case .notDetermined:
            
            PHPhotoLibrary.requestAuthorization { (status) in
                
                guard status == .authorized else {
                    NSLog("User did not authorize access to the photo library")
                    self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
                    return
                }
                
                self.presentImagePickerController()
            }
            
        case .denied:
            self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
        case .restricted:
            self.presentInformationalAlertController(title: "Error", message: "Unable to access the photo library. Your device's restrictions do not allow access.")
            
        }
        presentImagePickerController()
    }
    
    private func presentImagePickerController() {
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            presentInformationalAlertController(title: "Error", message: "The photo library is unavailable")
            return
        }
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        
        imagePicker.sourceType = .photoLibrary

        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func segmentedControlIndexChanged(_ sender: UISegmentedControl) {
        updateViews()
        updateImage()
    }
    
    @IBAction func topSliderAdjusted(_ sender: UISlider) {
        updateImage()
    }
    
    @IBAction func bottomSliderAdjusted(_ sender: UISlider) {
        updateImage()
    }
    
    //MARK: - Properties
    var postController: PostController!
    var post: Post?
    var imageData: Data?
//    var uneditedImage: UIImage?
    var originalImage: UIImage? {
        didSet {
            updateImage()
        }
    }
    
    //MARK: - CIImage Specfic Properties
    private let context = CIContext()
    private let chromeFilter = CIFilter.photoEffectChrome()
    private let vignetteFilter = CIFilter.vignette()
    private let zoomBlurFilter = CIFilter.zoomBlur()
    private let bloomFilter = CIFilter.bloom()
    
    
    //MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
    
    @IBOutlet weak var imageEffectSegmentedControl: UISegmentedControl!
    @IBOutlet weak var topEffectSlider: UISlider!
    @IBOutlet weak var bottomEffectSlider: UISlider!
    @IBOutlet weak var topEffectLabel: UILabel!
    @IBOutlet weak var bottomEffectLabel: UILabel!
    
    @IBOutlet weak var effectControlsStackView: UIStackView!
    @IBOutlet weak var bottomEffectControlsStackView: UIStackView!
    
    
    
    
    //MARK: - Custom Filter Methods
    
    func makeImageChrome(byFiltering image: UIImage) -> UIImage {
        // 1. UI Image -> CG Image
        guard let cgImage = image.cgImage else {
            print("Couldn't get CGImage from UIImage input")
            return image
        }
        // 2a. CGImage -> CIImage as filter input
        let inputImage = CIImage(cgImage: cgImage)
        // 2b. Filter CIImage
        chromeFilter.inputImage = inputImage
        // 2c. CIImage as filter output
        guard let outputImage = chromeFilter.outputImage else {
            print("Unable to get filter output image")
            return image
        }
        // 3. Render filtered output CIImage to a CGImage
        guard let renderedImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            print("Unable to render chrome filtered image")
            return image
        }
        // 4. Return UIImage
        return UIImage(cgImage: renderedImage)
    }
    
    func addVignette(byFiltering image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else {
            print("Couldn't get CGImage from UIImage input")
            return image
        }
        let inputImage = CIImage(cgImage: cgImage)
        vignetteFilter.inputImage = inputImage
        vignetteFilter.radius = topEffectSlider.value
        vignetteFilter.intensity = bottomEffectSlider.value
        guard let outputImage = vignetteFilter.outputImage else {
            print("Unable to filter output image")
            return image
        }
        guard let renderedImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            print("Unable to render vignette filtered image")
            return image
        }
        return UIImage(cgImage: renderedImage)
    }
    
    
    func addZoomBlur(byFiltering image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else {
            print("Couldn't get CGImage from UIImage input")
            return image
        }
        let inputImage = CIImage(cgImage: cgImage)
        zoomBlurFilter.inputImage = inputImage.clampedToExtent()
        zoomBlurFilter.amount = topEffectSlider.value
        guard let outputImage = zoomBlurFilter.outputImage else {
            print("Unable to filter output image")
            return image
        }
        guard let renderedImage = context.createCGImage(outputImage, from: inputImage.extent) else {
            print("Unable to render zoom blur filtered image")
            return image
        }
        return UIImage(cgImage: renderedImage)
    }
    
    func addBloom(byFiltering image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else {
            print("Couldn't get CGImage from UIImage input")
            return image
        }
        
        let inputImage = CIImage(cgImage: cgImage)
        bloomFilter.inputImage = inputImage.clampedToExtent()
        bloomFilter.radius = topEffectSlider.value
        bloomFilter.intensity = bottomEffectSlider.value
        guard let outputImage = bloomFilter.outputImage else {
            print("Unable to filter output image")
            return image
        }
        guard let renderedImage = context.createCGImage(outputImage, from: inputImage.extent) else {
            print("Unable to render bloom filtered image")
            return image
        }
        
        return UIImage(cgImage: renderedImage)
    }
    
    func updateImage() {
        guard let image = originalImage else { return }
        
        switch imageEffectSegmentedControl.selectedSegmentIndex {
        case 0:
            imageView.image = image
        case 1:
            imageView.image = makeImageChrome(byFiltering: image)
        case 2:
            imageView.image = addVignette(byFiltering: image)
        case 3:
            imageView.image = addZoomBlur(byFiltering: image)
        case 4:
            imageView.image = addBloom(byFiltering: image)
        case 5:
            return
        default:
            return
        }
    }
    
}


//MARK: - ImagePicker Delegate
extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        chooseImageButton.setTitle("", for: [])
        
        picker.dismiss(animated: true, completion: nil)
        
        // If edited image is avaialable use that, else use original image
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imageView.image = editedImage
            setImageViewHeight(with: editedImage.ratio)
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = originalImage
            setImageViewHeight(with: originalImage.ratio)
        }
        
        originalImage = imageView.image
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


