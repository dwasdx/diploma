import UIKit

@IBDesignable
open class SpacingLabel : UILabel {
    
    @IBInspectable
    open var characterSpacing: CGFloat = 1 {
        didSet {
            guard let text = text else {
                return
            }
            
            let attributedString = NSMutableAttributedString(string: text)
            attributedString.addAttribute(NSAttributedString.Key.kern, value: characterSpacing, range: NSRange(location: 0, length: attributedString.length))
            attributedText = attributedString
        }

    }
}
