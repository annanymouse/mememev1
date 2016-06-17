//
//  ViewController.swift
//  PhotoPicker
//
//  Created by Anna Hull on 3/20/16.
//  Copyright © 2016 Anna Hull. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var navBar: UINavigationItem!
    
    //var activeField: UITextField?
    
//    func hideToolBars(flag:Bool){
//        navBar.hidden = flag
//        toolbar.hidden = flag
//    }
    
    //inspired by https://github.com/Roselai/MemeMe1.0/tree/master/memeMe1.0
    func setupTextField(textField: UITextField) {
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : -3.0
        ]
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.widthAnchor.constraintEqualToAnchor(imagePickerView.widthAnchor, multiplier: 1)
        textField.textAlignment = .Center
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupTextField(topText)
        setupTextField(bottomText)
        topText.text = "TOP"
        bottomText.text = "BOTTOM"
        
        shareButton.enabled = false
        view.backgroundColor = UIColor.lightGrayColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    //inspired by https://github.com/Roselai/MemeMe1.0/tree/master/memeMe1.0
    func pickAnImage (source: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        pickAnImage(.PhotoLibrary)
    }
    
    @IBAction func pickAnImageFromCamera(sender: AnyObject) {
        pickAnImage(.Camera)
    }

//    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            imagePickerView.contentMode = .ScaleAspectFit
//            imagePickerView.image = image
//        }
//        dismissViewControllerAnimated(true, completion: nil)
//        shareButton.enabled = true
//    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.contentMode = .ScaleAspectFit
            imagePickerView.image = image
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
        shareButton.enabled = true
    }
   
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelButton(sender: UIBarButtonItem) {
        imagePickerView.image = nil
        topText.text = "TOP"
        bottomText.text = "BOTTOM"
        shareButton.enabled = false
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        //NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        //NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if bottomText.isFirstResponder(){
            view.frame.origin.y -= getKeyboardHeight(notification);
        }
        else if topText.isFirstResponder(){
            view.frame.origin.y = 0;
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        //UIKeyboardWillHideNotification
        //view.frame.origin.y += getKeyboardHeight(notification)
        view.frame.origin.y = 0
    }
    
    
    @IBAction func shareButton(sender: UIBarButtonItem) {
        let image = UIImage()
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        self.presentViewController(controller, animated: true, completion: nil)

    }
    
    // when editing begins the default text is cleared
    //inspired by code from https://github.com/jhyqt5/mememe/blob/master/MemeApp
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.tag == 0 {
            topText.placeholder = ""
        } else if textField.tag == 1 {
            bottomText.placeholder = ""
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        }
    }
    
    @IBAction func topText(sender: UITextField) {
        textFieldDidBeginEditing(topText)
    }
    
    
    @IBAction func bottomText(sender: UITextField) {
        textFieldDidBeginEditing(bottomText)
    }
    
    //https://github.com/jhyqt5/mememe/blob/master/MemeApp
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.tag == 1 {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        }
    }
    
//    func textFieldDidBeginEditing(textField: UITextField) {
//        textField.text = ""
//    }
    
    // closes keyboard when return is pressed
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    func generateMemedImage() -> UIImage
    {
    
     self.navigationController!.navigationBar.hidden = true
     navigationController?.setToolbarHidden(false, animated: false)
        
    // Render view to an image
    UIGraphicsBeginImageContext(self.view.frame.size)
    view.drawViewHierarchyInRect(self.view.frame,
    afterScreenUpdates: true)
    let memedImage : UIImage =
    UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
        
    self.navigationController!.navigationBar.hidden = false
    navigationController?.setToolbarHidden(true, animated: false)
    
    return memedImage
    }

    func save() {
        //Create the meme
        let memedImage = generateMemedImage()
        let meme = Meme(topText: topText.text, bottomText: bottomText.text, originalImage: imagePickerView.image, memedImage: memedImage)
    }
    
}

