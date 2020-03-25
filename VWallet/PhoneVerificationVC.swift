//
//  ViewController.swift
//  Number Validator
//
//  Created by Alessandro on 10/5/19.
//  Copyright © 2019 Alessandro Liu. All rights reserved.
//

import UIKit
import PhoneNumberKit


class PhoneVerificationVC: UIViewController {

    @IBOutlet weak var inputNumber: PhoneNumberTextField!
    @IBOutlet weak var validationLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        if (Storage.phoneNumberInE164 != nil) {
            inputNumber.text = Storage.phoneNumberInE164
        }
        configureTapGesture()  // turns off the keypad when tapped on the blank screen
    }
    
    
    
    
    private func configureTapGesture() {
        // turn off the keypad when tapped on the screen
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PhoneVerificationVC.closeKeypad))
        // run closeKeypad() when tapped
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func closeKeypad() {
        // turn off the keypad forcefully
        view.endEditing(true)
    }

    @IBAction func verifyBtn(_ sender: Any) {
        // turn off the keypad forcefully
        view.endEditing(true)
        let phoneNumberKit = PhoneNumberKit()
        do {
            // TRY if the number is valid
            let phoneNumberCustomDefaultRegion = try phoneNumberKit.parse(inputNumber.text!, withRegion: "US", ignoreType: true)
            // if it IS valid:
            // print the phone number in national format
            print("national:", phoneNumberKit.format(phoneNumberCustomDefaultRegion, toType: .national))
            // print the phone number in national format
            let phoneNumber1 = phoneNumberKit.format(phoneNumberCustomDefaultRegion, toType: .e164)
            print("E164 format:", phoneNumber1)
            validationLabel.text = "Valid"
            
            // text in green
            validationLabel.textColor = UIColor.green
            // inputNumber.backgroundColor = UIColor.green
            inputNumber.layer.borderWidth = 1
            // change the border of the text box to green
            inputNumber.layer.borderColor = UIColor.green.cgColor
            // disable the touch listener
            self.view.isUserInteractionEnabled = false
            activityIndicator.startAnimating()
            if (phoneNumber1 == Storage.phoneNumberInE164 ?? "-1") {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vs = storyboard.instantiateViewController(identifier: "HomeID")
                let oldUser = vs as! HomeVC
                self.present(oldUser, animated: true, completion: nil)
                self.activityIndicator.stopAnimating()
            } else {
                Api.sendVerificationCode(phoneNumber: phoneNumber1) { response, error in
                    // .. what you want to do with response or error
                    // .. both response and error can be nil
                    if (response != nil) {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(identifier: "CodeVerificationVC")
                        let codeVerification = vc as! CodeVerificationVC
                        codeVerification.phoneNumber2 = phoneNumber1
                        self.navigationController?.pushViewController(codeVerification, animated: true)
                        // reset the test box and the label and the border color
                        self.inputNumber.layer.borderWidth = 0
                        self.inputNumber.text = ""
                        self.validationLabel.text = ""
                        // enable the touch listener
                        self.view.isUserInteractionEnabled = true
                        self.activityIndicator.stopAnimating()
                    }
                }
                
            }
            
            // transition to the CodeVerificationVC
            // DispatchQueue is for 5 seconds delay
//            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//
//            }
            
        }
        catch {
            // if it is NOT valid:
            if inputNumber.text == "" {
                // error message 1
                validationLabel.text = "Empty"
            } else {
                // error message 2
                validationLabel.text = "Not Valid"
            }
            // change text to red
            validationLabel.textColor = UIColor.red
            inputNumber.layer.borderWidth = 1
            // change the border of the text box to red
            inputNumber.layer.borderColor = UIColor.red.cgColor
            // reset the input box when it is not valid
            inputNumber.text = ""
        }
    }
    
}
