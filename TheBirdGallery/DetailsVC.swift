//
//  DetailsVC.swift
//  TheBirdGallery
//
//  Created by Hikmet Tütüncü on 12.06.2024.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var oldText: UITextField!
    @IBOutlet weak var speciesText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    
    var chosenBird = ""
    var chosenBirdID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if chosenBird != "" {
            
            saveButton.isHidden = true
            
            // Core Data
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bird")
            
            let idString = chosenBirdID?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String {
                            nameText.text = name
                        }
                        if let species = result.value(forKey: "species") as? String {
                            speciesText.text = species
                        }
                        if let old = result.value(forKey: "old") as? Int {
                            oldText.text = String(old)
                        }
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
            } catch {
                print("error")            }
            
            
            
        } else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
        }
        
        // hide keyboard
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
    }

    @IBAction func saveButtonClick(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newBird = NSEntityDescription.insertNewObject(forEntityName: "Bird", into: context)
        newBird.setValue(nameText.text!, forKey: "name")
        newBird.setValue(speciesText.text!, forKey: "species")
        
        if let year = Int(oldText.text!) {
            newBird.setValue(year, forKey: "old")
        }
        newBird.setValue(UUID(), forKey: "id")
        
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        newBird.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("success")
        } catch {
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func selectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        saveButton.isEnabled = true
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }

}
