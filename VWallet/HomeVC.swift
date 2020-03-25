//
//  HomeVC.swift
//  VWallet
//
//  Created by Alessandro on 10/19/19.
//  Copyright © 2019 Alessandro Liu. All rights reserved.
//

import UIKit

class HomeVC: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var PopupView: UIView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var accountsTable: UITableView!
    @IBOutlet weak var accountText: UITextField!
//    var isOld = false
    
    var user:Wallet?
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(isOld, "====================================================")
        PopupView.isHidden = true
        
        accountsTable.delegate = self
        accountsTable.dataSource = self
        accountsTable.allowsSelection = true
        
        nameText.delegate = self
        accountText.delegate = self
        
        setupPopupView()
        apiCall()
       
    }
    
    func setupPopupView() {
        PopupView.layer.borderWidth = 1
        PopupView.layer.borderColor = UIColor.black.cgColor
        PopupView.layer.cornerRadius = 20
        PopupView.layer.shadowColor = UIColor.black.cgColor
        PopupView.layer.shadowOpacity = 1
        PopupView.layer.shadowOffset = .zero
        PopupView.layer.shadowRadius = 10
    }
    
    func apiCall() {
//        print(self.user?.phoneNumber ?? "-1")
//        print(Storage.phoneNumberInE164 ?? "0")
//        if isOld {
            Api.user(){ response, error in
                self.user = Wallet.init(data: response ?? ["name": "alex"], ifGenerateAccounts: false)
                Api.setAccounts(accounts: self.user?.accounts ?? []){ response, error in
                }
                self.amountLabel.text =  String(format:"%0.02f", self.user?.totalAmount ?? 0.0)
                
                let jsonObject = response?["user"]  as! [String : Any]
                let getName = jsonObject["name"] ?? ""
                let strName = "\(getName)"  // reassign as string
                // remove all the spaces and \n\r in a String
                let filteredStrName = String(strName.filter { !" \n\t\r".contains($0) })
                if (filteredStrName.isEqual("") || filteredStrName.isEqual("<null>")) {
                    // set to phone number is the user name is nil
                    self.nameText.text = Storage.phoneNumberInE164
                } else {
                    self.nameText.text = strName
                }
                self.accountsTable.reloadData()
                print("------------------------")
                self.user?.printWallet()
                print("------------------------")
            }
//        } else {
//            Api.user(){ response, error in
//                self.user = Wallet.init(data: response ?? ["name": "alex"], ifGenerateAccounts: true)
//                Api.setAccounts(accounts: self.user?.accounts ?? []){ response, error in
//                }
//    //            self.user?.phoneNumber = Storage.phoneNumberInE164 ?? ""
//                self.amountLabel.text =  String(format:"%0.02f", self.user?.totalAmount ?? 0.0)
//
//                let jsonObject = response?["user"]  as! [String : Any]
//                let getName = jsonObject["name"] ?? ""
//                let strName = "\(getName)"  // reassign as string
//                // remove all the spaces and \n\r in a String
//                let filteredStrName = String(strName.filter { !" \n\t\r".contains($0) })
//                if (filteredStrName.isEqual("") || filteredStrName.isEqual("<null>")) {
//                    // set to phone number is the user name is nil
//                    self.nameText.text = Storage.phoneNumberInE164
//                } else {
//                    self.nameText.text = strName
//                }
//                self.accountsTable.reloadData()
//                print("------------------------")
//                self.user?.printWallet()
//                print("------------------------")
//                self.isOld = true
//            }
//        }
    }
    
    @IBAction func logoutBtn(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let phoneVerificationVC = storyBoard.instantiateViewController(withIdentifier: "myNavController") as! UINavigationController
                self.present(phoneVerificationVC, animated: true, completion: nil)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameText.resignFirstResponder()
        performAction()
        return true
    }
    
    @IBAction func addAccountBtn(_ sender: Any) {
        PopupView.isHidden = false
        accountText.becomeFirstResponder()
        
        
    }
    
    @IBAction func doneBtn() {
        var name = accountText.text
        if name ?? "" == "" {
            let defautName = "Account " + String((user?.accounts.count ?? 0)+1)
            name = defautName
        }
        guard let wallet = user else {
            print("error")
            return
        }
        Api.addNewAccount(wallet: wallet, newAccountName: name ?? "-1"){ response, error in
            guard let _ = response else {
                print("Api.addNewAccount error.........")
                return
            }
            self.accountText.text = ""
            self.accountText.resignFirstResponder()
            self.PopupView.isHidden = true
            self.apiCall()
        }
    }
    
    func performAction() {
        print("enter pressed")
        let temp = nameText.text ?? ""
        // remove all the spaces and \n\r in a String
        let filteredText = String(temp.filter { !" \n\t\r".contains($0) })
        if filteredText != "" {
            nameText.text = filteredText
            Api.setName(name: filteredText){ response, error in
                print(response ?? "-1")
            }
        } else {
            nameText.text = "Enter Username"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // table column
        return user?.accounts.count ?? 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // table row
        let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell") ?? UITableViewCell(style: .default, reuseIdentifier: "accountCell")

                
        let moneyAmout = String(format:"%0.02f", user?.accounts[indexPath.row].amount ?? 1314.520)
        let name = self.user?.accounts[indexPath.row].name ?? "-1"
                
        cell.textLabel?.text = "\(name)                                  \(moneyAmout)"
        return cell
        }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRowIndex = indexPath.row
        print("row index --->", selectedRowIndex)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "AccountID")
        let accountVC = vc as! AccountVC
        accountVC.accountIndex = selectedRowIndex
        present(accountVC, animated: true, completion: nil)
    }
}
    
//    @IBAction func doneEditingBtn() {
//        let temp = nameText.text ?? ""
//        // remove all the spaces and \n\r in a String
//        let filteredText = String(temp.filter { !" \n\t\r".contains($0) })
//        if filteredText != "" {
//            nameText.text = editNameBox.text
//            Api.setName(name: editNameBox.text ?? "-1"){ response, error in
//
//            }
//            editNameBox.text = ""
//        }
//        editNameBox.text = ""
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


