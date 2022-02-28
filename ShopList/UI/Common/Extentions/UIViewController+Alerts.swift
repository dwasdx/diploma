import UIKit

extension UIViewController {
    
    func showErrorAlert(title: String = "Error", message: String, okHandler: ((UIAlertAction)->Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: okHandler))

        present(alert, animated: true)
    }
    
    func showMessageAlert(title: String = "Message", message: String, okHandler: ((UIAlertAction)->Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: okHandler))

        present(alert, animated: true)
    }
    
    func showConformationAlert(title: String = "Message", message: String, actionHandler: ((UIAlertAction)->Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: actionHandler))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: actionHandler))

        present(alert, animated: true)
    }
}
