import UIKit

@IBDesignable
class RotatableLabel: UILabel {
    
    @IBInspectable
    var rotation: CGFloat = 0 {
        didSet {
            rotateLabel(degrees: rotation)
            layoutIfNeeded()
        }
    }

    func rotateLabel(degrees: CGFloat)  {
        let radiansPerDegree = CGFloat(CGFloat(Double.pi) / CGFloat(180.0))
        let radians = radiansPerDegree * degrees
        self.transform = CGAffineTransform(rotationAngle: radians)
    }
}
