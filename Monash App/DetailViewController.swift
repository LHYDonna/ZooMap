//
//  DetailViewController.swift
//  Monash App
//
//  Created by 林洪钰 on 30/8/18.
//  Copyright © 2018 林洪钰. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var animal : Animal?
    var index: Int?
    var editAnimalDelegate: ManageAnimalProtocol?
    var validation: Validation?
    
    @IBOutlet weak var nameTextField: UILabel!
    @IBOutlet weak var detailTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextView!
    @IBOutlet weak var pictureImageView: UIImageView!
    
    // Choose photo
    @IBAction func choosePhotoBtn(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self
        
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        image.allowsEditing = false
        self.present(image, animated: true){
        }
    }
    // Take photo
    @IBAction func takePhotoBtn(_ sender: Any) {
        let controller = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
            controller.sourceType = UIImagePickerControllerSourceType.camera
        }
        else{
            controller.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        
        controller.allowsEditing = false
        controller.delegate = self
        self.present(controller,animated: true, completion: nil)
    }
    
    // ImagePicker controller
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            pictureImageView.image = image
        }
        else{
            //Error message
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // ImagePicker cancel action
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        createAltert(title: "There was an error in getting the photo", message: "Error")
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.text = animal?.name
        detailTextField.text = animal?.desc
        addressTextField.text = animal?.location
        let fileName = animal?.picture
        
        // Loading picture
        if (animal?.picture?.isEmpty)!{
            pictureImageView.image = UIImage(named: "default_photo")
        }
        else{
            pictureImageView.image = loadImageData(newFileName: fileName!)
        }
        
        // Do any additional setup after loading the view.
    }
    
    // load image from core data
    func loadImageData(newFileName: String) -> UIImage?{
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        var image: UIImage?
        if let pathComponent = url.appendingPathComponent(newFileName){
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            let fileData = fileManager.contents(atPath: filePath)
            if (fileData != nil){
                image = UIImage(data: fileData!)
            }
            else{
                image = UIImage(named: "default_photo")
            }
        }
        return image
    }

    // Submit changes
    @IBAction func submitBtn(_ sender: Any) {
        validation = Validation()
        if !(validation?.checkDescValid(detailTextField.text!))!{
            createAltert(title: "Invalid Description", message: "Input a valid animal description please!")
            return
        }
        else{
            animal?.name = nameTextField.text!
            animal?.desc = detailTextField.text!
            animal?.location = addressTextField.text!
            savePicture(animal: animal!)
            editAnimalDelegate?.editAnimal(animal: animal!, index: index!)
            self.navigationController!.popViewController(animated: true)
        }
    }
    
    // Save image to core data
    func savePicture(animal: Animal){
        guard let image = pictureImageView.image else{
            print("Cannot save until a phot has been taken!", "Error")
            return
        }
        
        let date = UInt(Date().timeIntervalSince1970)
        var data = Data()
        data = UIImageJPEGRepresentation(image, 0.8)!
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent("\(date)"){
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
            animal.setValue("\(date)", forKey: "picture")
            print("============================================")
            print("\(date)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }    

    // Altert massage display
    func createAltert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }

}
