import UIKit

protocol CreateShoppingListViewModeling: BaseViewModeling {
    func createModel(name: String)
}

protocol FromTemplateToShopingList {
    func fromTemplateToShopingList(productList: ProductModel)
}

protocol CreateShoppingListViewControllerRouting {
    func navigateBack(_ completion: (() -> Void)?)
}

class CreateShoppingListViewController: NameEditingViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewHeightAnchor: NSLayoutConstraint!
    @IBOutlet weak var containerViewYPosition: NSLayoutConstraint!
    @IBOutlet weak var invalidLabel: UILabel!
    @IBOutlet weak var createButton: DesignableButton!
    
    var initialFingerYPosition: CGFloat = 0
    var currentFingerYPosition: CGFloat = 0
    let defaultContainerViewHeight: CGFloat = 325
    var didDismiss: (() -> Void)? {
        return { [weak self] in
            self?.router?.navigateBack(nil)
        }
    }
    
    var router: CreateShoppingListViewControllerRouting?
    var viewModel: CreateShoppingListViewModeling!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldValidTarget()
        scrollViewHeightAnchor.constant = 0
        super.nameEditingTextField = textField
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scrollViewHeightAnchor.constant = defaultContainerViewHeight
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {
                        self.view.backgroundColor = .shoppingListBlackTransparent
                        self.view.layoutSubviews()
        },
                       completion: nil)
        
        textField.becomeFirstResponder()
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
        
    }
    
    func textFieldValidTarget() {
        textField.addTarget(self, action: #selector(validCheck), for: .editingChanged)
    }
    
    @ objc
    func validCheck() {
        guard let text = textField.text else {
            return
        }
        invalidLabel.isHidden = text.isValid
        createButton.isEnabled = text.isValid
        createButton.backgroundColor = text.isValid ? UIColor(named: "shoppinglist.orange") : UIColor(named: "shoppinglist.icons.gray")
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func dismiss(_ completion: @escaping (()->Void)) {
        self.scrollViewHeightAnchor.constant = 0
        
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {
                        self.view.backgroundColor = .clear
                        self.view.layoutSubviews()
        }) { (_) in
            completion()
        }
    }
    
}

//MARK: Actions

extension CreateShoppingListViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        containerViewYPosition.constant = keyboardSize.height
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: { [weak self] in
                        self?.view.layoutIfNeeded()
            },
                       completion: nil)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        containerViewYPosition.constant = 0
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: { [weak self] in
                        self?.view.layoutIfNeeded()
            },
                       completion: nil)
    }
    
    @IBAction func createButtonTapped() {
        guard let name = textField.text, name != "" else {
            return
        }
       
        viewModel.createModel(name: name)
        router?.navigateBack(nil)
        
    }
    
    @IBAction func backgroundTapped(_ sender: Any) {
        dismiss {
            self.didDismiss?()
        }
    }
    
    @IBAction func cancelButtonTapped() {
        dismiss {
            self.didDismiss?()
        }
    }
    
    @IBAction func didPanContainerView(_ sender: UIPanGestureRecognizer) {
        self.didSwipeContainerView(sender)
    }
}

extension CreateShoppingListViewController: SwipeableViewController {
    var threshold: CGFloat {
//        textField.isEditing ? 0.5 : 0.3
        0.3
    }
}

extension CreateShoppingListViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let gesture = gestureRecognizer as? UIPanGestureRecognizer else {
            return false
        }
        let direction = gesture.velocity(in: gesture.view).y
        
        if scrollView.contentOffset.y == 0, direction > 0 {
            return false
        }
        return true
    }
}
