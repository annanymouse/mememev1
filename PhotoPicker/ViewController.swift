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
    //@IBOutlet weak var navBar: UINavigationItem!
    
    var activeField: UITextField?
    
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
    
    func save() {
        // Create the meme
        let memedImage = generateMemedImage()
        let meme = Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: imagePickerView.image!, memedImage: imagePickerView.image!)
    }
    
    //inspired by https://github.com/sultana-reshma/MemeMe
    // Show/Hide the tool bar and Navigation bar
    func hideToolBar(disabled:Bool){
        toolBar.hidden = disabled
        navigationController?.setNavigationBarHidden(disabled, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupTextField(topText)
        setupTextField(bottomText)
        //topText.text = "TOP"
        //bottomText.text = "BOTTOM"
        
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
    
    //inspired by https://github.com/Roselai/MemeMe1.0
    func pickAnImage (source: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        
        if(source == .Camera){
            imagePicker.cameraCaptureMode = .Photo
        }
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        pickAnImage(.PhotoLibrary)
    }
    
    @IBAction func pickAnImageFromCamera(sender: AnyObject) {
        pickAnImage(.Camera)
    }
    
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
        topText.placeholder = "TOP"
        bottomText.placeholder = "BOTTOM"
        shareButton.enabled = false
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    func keyboardWillHide(notification: NSNotification) {
        //UIKeyboardWillHideNotification
        //view.frame.origin.y += getKeyboardHeight(notification)
        view.frame.origin.y = 0
    }
   
    @IBAction func shareButton(sender: UIBarButtonItem) {
        let image = [generateMemedImage()]
        let controller = UIActivityViewController(activityItems: image, applicationActivities: nil)
        self.presentViewController(controller, animated: true, completion: nil)
        self.save()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.tag == 0 {
            topText.placeholder = ""
        } else if textField.tag == 1 {
            bottomText.placeholder = ""
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.tag == 1 {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        keyboardDisappears()
        return true
    }
    
    func dismissKeyboard () {
        view.endEditing(true)
        keyboardDisappears ()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        imagePickerView.frame.origin.y = imagePickerView.frame.origin.y - getKeyboardHeight(notification)
    }
    
    func keyboardDisappears () {
        imagePickerView.frame.origin.y = 0
    }
    
    func generateMemedImage() -> UIImage {
    
     // hide toolbar
     hideToolBar(true)
        
    // Render view to an image
    UIGraphicsBeginImageContext(self.view.frame.size)
    view.drawViewHierarchyInRect(self.view.frame,
    afterScreenUpdates: true)
    let memedImage : UIImage =
    UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
        
    self.navigationController!.navigationBar.hidden = false
    navigationController?.setToolbarHidden(true, animated: false)
    
    // show toolbar
    hideToolBar(false)
    
    return memedImage
    }

}
