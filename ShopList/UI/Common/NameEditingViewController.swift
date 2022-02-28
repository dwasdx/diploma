import UIKit

class NameEditingViewController: BaseViewController {
    var nameEditingTextField: UITextField?
}

extension NameEditingViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == nameEditingTextField {
            if textField.text == "",
               CharacterSet.whitespacesAndNewlines
                .isSuperset(of: CharacterSet(charactersIn: string)) {
                return false
            }
        }
        return true
    }
}
