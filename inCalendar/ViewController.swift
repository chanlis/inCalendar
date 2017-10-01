//
//  ViewController.swift
//  inCalendar
//
//  Created by Lisa Chan on 9/29/17.
//  Copyright © 2017 Lisa Chan. All rights reserved.
//

import UIKit
import TesseractOCR
import EventKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, G8TesseractDelegate  {

    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    // 
    @IBAction func pickPhoto(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func takePhoto(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    @IBOutlet weak var myImg: UIImageView!
    @IBOutlet weak var textView: UITextView!
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.myImg.image = pickedImage
            if let tesseract = G8Tesseract(language: "eng") {
                tesseract.delegate = self
                tesseract.image = pickedImage.g8_blackAndWhite()
                tesseract.recognize()
            
                textView.text = tesseract.recognizedText
            }
        }
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var loc: UITextField!
    @IBOutlet weak var date: UITextField!
    @IBOutlet weak var startTime: UITextField!
    @IBOutlet weak var endTime: UITextField!
    @IBAction func addEventToCalendar(_ sender: Any) {
        let eventStore = EKEventStore()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMMM dd, yyyy h:mm a"
        eventStore.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {
                let event = EKEvent(eventStore: eventStore)
                event.title = self.titleText.text!
                event.location = self.loc.text!
                event.startDate = (formatter.date(from: (self.date!.text! + " " + self.startTime!.text!)))!
                event.endDate = (formatter.date(from: (self.date!.text! + " " + self.endTime!.text!)))!
                print(event.startDate)
                print(event.endDate)
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                    let eventText = "\(self.titleText.text!), \(self.loc.text!) on \(self.date.text!) \(self.startTime.text!)-\(self.endTime.text!)"
                    print(eventText)
                    let alert = UIAlertController(title: "Event Added to Calendar", message: eventText, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } catch let error as NSError {
                    print("failed to save event with error : \(error)")
                }
                
            }
        })
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
                // self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
                self.scrollView.contentInset = .zero
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

