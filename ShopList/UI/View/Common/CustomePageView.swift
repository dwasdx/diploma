import UIKit

@IBDesignable
class CustomePageView: UIStackView {
    
    //MARK: Properties
        
    @IBInspectable
    var currentPage: Int = 1 {
        didSet {
            update()
        }
    }
    
    @IBInspectable
    var pageCount: Int = 3 {
        didSet {
            setup()
        }
    }
    
    @IBInspectable
    open var currentPageImage: UIImage? {
        didSet {
            setup()
        }
    }
    
    @IBInspectable
    open var defaultPageImage: UIImage? {
        didSet {
            setup()
        }
    }
    
    @IBInspectable
    var pictureSize: CGSize = CGSize(width: 20, height: 20) {
        didSet {
            setup()
        }
    }
    
    //MARK: Inits
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    //MARK: setup view
    
    private func setup() {
        
        for view in subviews {
            removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        for _ in 0..<pageCount {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.heightAnchor.constraint(equalToConstant: pictureSize.height).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: pictureSize.width).isActive = true
            imageView.isUserInteractionEnabled = true
            
            addArrangedSubview(imageView)
        }
        
        update()
    }
    
    //MARK: Update View
    
    private func update() {
        
        guard let currImage = currentPageImage,
              let defImage = defaultPageImage else {
                return
        }
        
        for (index, subview) in subviews.enumerated() {
            let imageView = subview as! UIImageView
            imageView.image = index == currentPage ? currImage : defImage
            print("index: \(index), currentPage: \(currentPage)")
        }
    }
}
