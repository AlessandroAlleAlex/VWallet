//
//  AccountVC.swift
//  VWallet
//
//  Created by Alessandro on 11/3/19.
//  Copyright © 2019 Alessandro Liu. All rights reserved.
//

import UIKit

class AccountVC: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var transferAmount: UITextField!
    @IBOutlet weak var piker: UIPickerView!
    @IBOutlet weak var transferPopup: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var amountLabel: UILabel!
    var accountIndex = -1
    var inputAmount = 0.0
    var user:Wallet?
    override func viewDidLoad() {
        super.viewDidLoad()
        transferAmount.delegate = self
        transferPopup.isHidden = true
        print("modify account number ->", accountIndex)
        setupPopupView()
        apiCall()
        // Do any additional setup after loading the view.
    }
    
    func setupPopupView() {
        transferPopup.layer.borderWidth = 1
        transferPopup.layer.borderColor = UIColor.black.cgColor
        transferPopup.layer.cornerRadius = 20
        transferPopup.layer.shadowColor = UIColor.black.cgColor
        transferPopup.layer.shadowOpacity = 1
        transferPopup.layer.shadowOffset = .zero
        transferPopup.layer.shadowRadius = 10
    }
    
    func apiCall() {
        self.view.isUserInteractionEnabled = false
        Api.user() { response, error in
            guard let _ = response else {
                print("Api.user call failed...........")
                return
            }
            self.user = Wallet.init(data: response ?? ["name": "alex"], ifGenerateAccounts: false)
            Api.setAccounts(accounts: self.user?.accounts ?? []){ response, error in
                guard let _ = response else {
                    print("Api.setAccounts call failed...........")
                    return
                }
                self.nameLabel.text = self.user?.accounts[self.accountIndex].name
                self.amountLabel.text = "$ \(self.user?.accounts[self.accountIndex].amount ?? -1)"
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
    @IBAction func popupDoneBtn() {
        transferPopup.isHidden = true
        guard let amountText = transferAmount.text else {
            print("Fail to get input text")
            return
        }
        guard let thisWallet = user else {
            print("error")
            return
        }
        inputAmount = Double(amountText) ?? 0
        if self.inputAmount > thisWallet.accounts[self.accountIndex].amount {
            self.inputAmount = 0.0
        }
        transferAmount.text = ""
        if let thisWallet = self.user {
            let toAccount = piker.selectedRow(inComponent: 0)
            Api.transfer(
            wallet: thisWallet,
            fromAccountAt: self.accountIndex,
            toAccountAt: toAccount,
            amount: inputAmount) {
                responds, error in
                if let error = error {
                    print("Error: \(error.message)")
                } else {
                    //MARK: picker has delay
                    self.apiCall()
                    print("Sucessfully transfered")
                    self.transferAmount.resignFirstResponder()
                }
            }
        }
        
    }
    @IBAction func popupCancelBtn() {
        transferPopup.isHidden = true
        transferAmount.text = ""
        self.transferAmount.resignFirstResponder()
    }
    @IBAction func depositBtn() {
        let alertController = UIAlertController(title: "Deposit", message: "Enter deposit amount",
            preferredStyle: .alert)
        alertController.addTextField { amountField in
            amountField.keyboardType = UIKeyboardType.decimalPad
            let touchDone = UIAlertAction(title: "Done", style: .default) {
                alertController in
                guard let amountText = amountField.text else {
                    print("Fail to get input text")
                    return
                }
                self.inputAmount = Double(amountText) ?? 0
                guard let thisWallet = self.user else {
                    print("Something is wrong with user:Wallet?")
                    return
                }
                Api.deposit(wallet: thisWallet, toAccountAt: self.accountIndex, amount: self.inputAmount) { responds, error in
                    if let error = error {
                        print("Error: \(error.message)")
                    } else {
                        self.apiCall()
                        print("Sucessfully deposit")
                    }}
            }
            alertController.addAction(touchDone)
        }
        present(alertController, animated: true, completion: nil)
    }
        
//        Api.deposit(wallet: userWallet, toAccountAt: accountIndex, amount: <#T##Double#>) { response, error in
//            guard let _ = response else {
//                print("Api.deposit failed.........")
//                return
//            }
            
            
            
//        }
//    }
    @IBAction func withdrawBtn() {
            let alertController = UIAlertController(title: "Withdraw", message: "Enter withdraw amount",
                preferredStyle: .alert)
            alertController.addTextField {
                amountField in
                amountField.keyboardType = UIKeyboardType.numberPad
                let touchDone = UIAlertAction(title: "Done", style: .default) { alertController in
                    guard let amountText = amountField.text else {
                        print("Fail to get input text.")
                        return
                    }
                    self.inputAmount = Double(amountText) ?? 0
                    if let thisWallet = self.user {
                        if self.inputAmount > thisWallet.accounts[self.accountIndex].amount {
                            self.inputAmount = 0.0
                        }
                        Api.withdraw(wallet: thisWallet, fromAccountAt: self.accountIndex, amount: self.inputAmount) { responds, error in
                            if let error = error {
                                print("Error: \(error.message)")
                            } else {
                                self.apiCall()
                                print("Sucessfully withdraw")
                            }
                        }
                    } else {
                        print("Fail to get user wallet or row")
                    }
                }
                alertController.addAction(touchDone)
            }
            present(alertController, animated: true, completion: nil)
    }
    @IBAction func transferBtn() {
        transferPopup.isHidden = false
        piker.dataSource = self
        piker.delegate = self
        transferAmount.keyboardType = UIKeyboardType.decimalPad
        self.transferAmount.becomeFirstResponder()
        piker.reloadAllComponents()
        
    }
    @IBAction func deleteBtn() {
        guard let thisWallet = user else {
            print("Fail to get user wallet.")
            return
        }
        Api.removeAccount(wallet: thisWallet, removeAccountat: self.accountIndex) { responds, error in
            if let err = error {
                print("Error: \(err.message)")
            } else {
                print("Sucessfully deleted.")
                self.doneBtn()
            }
        }
    }
    @IBAction func doneBtn() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vs = storyboard.instantiateViewController(identifier: "HomeID")
        let goBack = vs as! HomeVC
//        goBack.isOld = true
        self.present(goBack, animated: true, completion: nil)
    }
    

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return user?.accounts.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let row = pickerView.selectedRow(inComponent: 0)
        guard let accountName = user?.accounts[row].name else {
            return "Fail to get info at selected row."
        }
        guard let accountAmount = user?.accounts[row].amount else {
            return "Fail to get info at selected row."
        }
        print("account Name = \(accountName), $\(accountAmount)")
        let info = "\(accountName)  $\(accountAmount)"
        return info
   
    }

}
