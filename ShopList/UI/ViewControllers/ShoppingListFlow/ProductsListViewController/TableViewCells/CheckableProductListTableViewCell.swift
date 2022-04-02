import UIKit

class CheckableProductListTableViewCell: UITableViewCell {
    
    static let reuseId = "UncheckedPruductListTableViewCell"

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var checkoutButton: UIButton!
    @IBOutlet weak var valueView: UIView!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var dotsImageView: UIImageView!
    @IBOutlet weak var labelStackView: UIStackView!
    
    var panGesture: UIPanGestureRecognizer?
    var valueTapGesture: UITapGestureRecognizer?
    var nameTapGesture: UITapGestureRecognizer?
    weak var gestureDelegate: UIGestureRecognizerDelegate?
    
    private func gesturesInit(_ model: ProductModel) {
        guard containerView != nil else {
            return
        }
        
        containerView.gestureRecognizers?.removeAll()
        valueView.gestureRecognizers?.removeAll()
        labelStackView.gestureRecognizers?.removeAll()
        
        if !model.isMarked {
            makeGesture(&panGesture, container: containerView, selector: #selector(panGestureAction))
            makeGesture(&nameTapGesture, container: labelStackView, selector: #selector(tapGestureAction))
            makeGesture(&valueTapGesture, container: valueView, selector: #selector(tapGestureAction))
        }
        
        panGesture?.delegate = gestureDelegate
        valueTapGesture?.delegate = gestureDelegate
        nameTapGesture?.delegate = gestureDelegate
    }
    
    private func makeGesture<T: UIGestureRecognizer>(_ gesture: inout T?, container: UIView, selector: Selector) {
        if let gestureRecognizer = gesture {
            container.addGestureRecognizer(gestureRecognizer)
        } else {
            gesture = T(target: self, action: selector)
            container.addGestureRecognizer(gesture!)
        }
    }
    
    var panGestureBlock: ((UIPanGestureRecognizer, CheckableProductListTableViewCell) -> Void)?
    var tapGestureBlock: ((CheckableProductListTableViewCell) -> Void)?
    
    @objc private func panGestureAction() {
        guard let panGesture = panGesture else {
            return
        }
        panGestureBlock?(panGesture, self)
    }
    
    @objc private func tapGestureAction() {
        tapGestureBlock?(self)
    }
    
    func configure(with model: ProductModel) {
        print ("NAME: \(String(describing: nameLabel.text))")
        nameLabel.text = model.name
        print(nameLabel.text)
        if !model.value.isEmpty {
            valueLabel.text = model.value
            valueLabel.isHidden = false
            dotsImageView.isHidden = true
        } else {
            valueLabel.isHidden = true
            dotsImageView.isHidden = false
        }
        if model.isMarked {
            checkoutButton.setImage(UIImage(named: "productcell.checked.circle"), for: .normal)
            dotsImageView.image = UIImage(named: "productcell.gray.three-dots")
            nameLabel.textColor = .shoppingListTextGray
            valueLabel.textColor = .shoppingListTextGray
        } else {
            checkoutButton.setImage(UIImage(named: "productcell.circle"), for: .normal)
            dotsImageView.image = UIImage(named: "productcell.yellow.three-dots")
            nameLabel.textColor = .shoppingListTextBlack
            valueLabel.textColor = .shoppingListOrange
        }
        if let category = model.categoryName {
            categoryLabel.isHidden = false
            categoryLabel.text = category
        } else {
            categoryLabel.isHidden = true
        }
        gesturesInit(model)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        containerView.center.x = self.superview?.center.x ?? containerView.center.x
    }

}
