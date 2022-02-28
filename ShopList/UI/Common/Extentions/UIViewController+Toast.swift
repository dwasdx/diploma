import UIKit

extension UIViewController {
    func showDefaultToast(withMessage message: String, point: CGPoint? = nil) {
        if let point = point {
            view.makeToast(message,
                           point: point,
                           title: nil,
                           image: nil,
                           completion: nil)
            return
        }
        view.makeToast(message)
    }
}
