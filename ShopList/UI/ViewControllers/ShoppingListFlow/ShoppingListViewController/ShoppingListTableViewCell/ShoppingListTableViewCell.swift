import UIKit

class ShoppingListTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = typeName
    
    @IBOutlet weak var listNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var userIconImageView: UIImageView!
    @IBOutlet weak var userIconContainerView: UIView!
    @IBOutlet weak var productsLabel: UILabel!
    @IBOutlet weak var labelsContainerTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var notificationBadge: UIImageView!
    
    var tapGesture: UITapGestureRecognizer?
    var panGesture: UIPanGestureRecognizer?
    weak var gestureDelegate: UIGestureRecognizerDelegate?
    
    private func commonInit() {
        containerView.gestureRecognizers?.removeAll()
        makeGesture(&tapGesture, container: containerView, selector: #selector(tapGestureAction))
        makeGesture(&panGesture, container: containerView, selector: #selector(panGestureAction))
        
        tapGesture?.delegate = gestureDelegate
        panGesture?.delegate = gestureDelegate
    }
    
    private func makeGesture<T: UIGestureRecognizer>(_ gesture: inout T?, container: UIView, selector: Selector) {
        if let gestureRecognizer = gesture {
            container.addGestureRecognizer(gestureRecognizer)
        } else {
            gesture = T(target: self, action: selector)
            container.addGestureRecognizer(gesture!)
        }
    }
    
    var panGestureBlock: ((UIPanGestureRecognizer, ShoppingListTableViewCell) -> Void)?
    var tapGestureBlock: ((ShoppingListTableViewCell) -> Void)?
    
    @objc private func panGestureAction() {
        guard let panGesture = panGesture else {
            return
        }
        panGestureBlock?(panGesture, self)
    }
    
    @objc private func tapGestureAction() {
        tapGestureBlock?(self)
    }
    
    func configure(with model: ShoppingListModel) {
        listNameLabel.text = model.name        
        notificationBadge.isHidden = !model.hasChange
        productsLabel.text = String(model.checkedProductsNumber) + "/" + String(model.productsNumber)
        
        let date = Date(timeIntervalSince1970: TimeInterval(model.updatedAt))
        let formatter = DayDateFormatter()
        //FIXME: do something with this NA
        let updatedAt = formatter.time(date) ?? "NA"
        
        dateLabel.text = updatedAt
        userIconImageView.image = [UIImage(named: "user.icon"), UIImage(named: "users.icon")].randomElement().flatMap { $0 }
        let isSharedList = model.ownerId != CurrentUserManager.shared.userIdentifier || model.isSharedList
        userIconImageView.image = isSharedList ? UIImage(named: "users.icon") : UIImage(named: "user.icon")
        userIconContainerView.backgroundColor = isSharedList ? .shoppingListBlue : .shoppingListOrange
        commonInit()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        containerView.center.x = self.superview?.center.x ?? containerView.center.x
    }
    
}
