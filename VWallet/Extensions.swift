import UIKit

protocol PinTextFieldDelegate : UITextFieldDelegate {
    func didPressBackspace(textField : PinTextField)
}

class PinTextField: UITextField, UITextFieldDelegate {

    override func deleteBackward() {
        if let pinDelegate = self.delegate as? PinTextFieldDelegate {
            pinDelegate.didPressBackspace(textField: self)
        }
        super.deleteBackward()
        
    }
    
}
