import UIKit

protocol ClassName {
    static var className: String { get }
}

extension ClassName {
    static var className: String {
        String(describing: self)
    }
}

extension UIViewController: ClassName {
    
}
