//
//  CodeVerificationVC.swift
//  VWallet
//
//  Created by Alessandro on 10/15/19.
//  Copyright © 2019 Alessandro Liu. All rights reserved.
//

import UIKit

class CodeVerificationVC: UIViewController, PinTextFieldDelegate {
    
    @IBOutlet weak var first: UITextField!
    @IBOutlet weak var second: UITextField!
    @IBOutlet weak var third: UITextField!
    @IBOutlet weak var fourth: UITextField!
    @IBOutlet weak var fifth: UITextField!
    @IBOutlet weak var sixth: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var resultLabel: UILabel!
    
    var phoneNumber2 = String()  // == ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
//        print(phoneNumber2)
        
        second.isUserInteractionEnabled = false
        third.isUserInteractionEnabled = false
        fourth.isUserInteractionEnabled = false
        fifth.isUserInteractionEnabled = false
        sixth.isUserInteractionEnabled = false
        
        first.delegate = self
        second.delegate = self
        third.delegate = self
        fourth.delegate = self
        fifth.delegate = self
        sixth.delegate = self
    }
    
    func didPressBackspace(textField: PinTextField) {
        if textField == sixth {
            self.resultLabel.text = ""
            fifth.isUserInteractionEnabled = true
            fifth.text = ""
            fifth.becomeFirstResponder()
        }
        if textField == fifth {
            fourth.isUserInteractionEnabled = true
            fourth.text = ""
            fourth.becomeFirstResponder()
        }
        if textField == fourth {
            third.isUserInteractionEnabled = true
            third.text = ""
            third.becomeFirstResponder()
        }
        if textField == third {
            second.isUserInteractionEnabled = true
            second.text = ""
            second.becomeFirstResponder()
        }
        if textField == second {
            first.isUserInteractionEnabled = true
            first.text = ""
            first.becomeFirstResponder()
        }
        if textField == first {
            first.resignFirstResponder()
            first.isUserInteractionEnabled = true
            return
        }
        textField.isUserInteractionEnabled = false
    }
    
    func verifyCode() {
        let code1 = first.text ?? "a"
        let code2 = second.text ?? "b"
        let code3 = third.text ?? "c"
        let code4 = fourth.text ?? "d"
        let code5 = fifth.text ?? "e"
        let code6 = sixth.text ?? "f"
        let OTPcode = code1 + code2 + code3 + code4 + code5 + code6
//        print("---------->>>", OTPcode)
//        print("---------->", phoneNumber2)
        // disable the touch listener
        self.view.isUserInteractionEnabled = false
        self.activityIndicator.startAnimating()
        
        Api.verifyCode(phoneNumber: phoneNumber2, code: OTPcode) { response, error in
            
            print(error ?? "default error")
            print(response ?? "default response")
            guard let _ = error else {
                // no error message if it is inside the 'guard let':
//                presentViewController(nextViewController, animated: true, completion: nil)
                self.resultLabel.text = "Success"
                // text in green
                self.resultLabel.textColor = UIColor.green
                // store the phone number in E164 
                Storage.phoneNumberInE164 = self.phoneNumber2
                // record the user unique token
                let authToken = response?["auth_token"] as? String
                Storage.authToken = authToken
//                print(authToken ?? "111", "-------------------------------------------")
//                print(Storage.phoneNumberInE164 ?? "222", "###################################")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(identifier: "HomeID")
                //  let homeScreen = vc as! HomeVC
                self.present(vc, animated: true, completion: nil)
                self.view.isUserInteractionEnabled = false
                self.activityIndicator.stopAnimating()
                return
            }
            self.resultLabel.text = "Fail"
            
            // text in green
            self.resultLabel.textColor = UIColor.red
            self.activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
        //          // .. what you want to do with response or error
        //          // .. both response and error can be nil
        }
    }
    
    @IBAction func resend() {
        Api.sendVerificationCode(phoneNumber: phoneNumber2) { response, error in
            // .. what you want to do with response or error
            // .. both response and error can be nil
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.count > 0 {
            if textField == first {
                second.isUserInteractionEnabled = true
                second.becomeFirstResponder()
            }
            if textField == second {
                third.isUserInteractionEnabled = true
                third.becomeFirstResponder()
            }
            if textField == third {
                fourth.isUserInteractionEnabled = true
                fourth.becomeFirstResponder()
            }
            if textField == fourth {
                fifth.isUserInteractionEnabled = true
                fifth.becomeFirstResponder()
            }
            if textField == fifth {
                sixth.isUserInteractionEnabled = true
                sixth.becomeFirstResponder()
            }
            if textField == sixth {
                sixth.resignFirstResponder()
                textField.text = string
                verifyCode()
                return false
            }
            textField.text = string
            textField.isUserInteractionEnabled = false
            return false
        }
        return true
    }
}


