import UIKit

protocol ChangeNameShoppingListViewControllerRouting {
    func navigateBack(animated: Bool, _ completion: (() -> Void)?)
}

class ChangeNameShoppingListViewController: NameEditingViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewYPosition: NSLayoutConstraint!
    @IBOutlet weak var scrollViewHeightAnchor: NSLayoutConstraint!
    
    var initialFingerYPosition: CGFloat = 0
    var currentFingerYPosition: CGFloat = 0
    let defaultContainerViewHeight: CGFloat = 325
    var didDismiss: (() -> Void)? {
        return { [weak self] in
            self?.router?.navigateBack(animated: false, nil)
        }
    }
    
    var router: ChangeNameShoppingListViewControllerRouting?
    var viewModel: ChangeNameListViewModeling!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollViewHeightAnchor.constant = 0
        super.nameEditingTextField = textField
        textField.text = viewModel.name
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

extension ChangeNameShoppingListViewController {
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
    
    @IBAction func didPanContainerView(_ sender: UIPanGestureRecognizer) {
        didSwipeContainerView(sender)
    }
    
    @IBAction func saveButtonTapped() {
        guard let name = textField.text, name != "" else {
            return
        }
        viewModel.name = name
        dismiss {
            self.router?.navigateBack(animated: false, { [weak self] in
                self?.viewModel.changeModelInParentViewModel()
            })
        }
        
    }
    
    @IBAction func backgroundTapped() {
        dismiss {
            self.router?.navigateBack(animated: false, nil)
        }
    }
    
    @IBAction func cancelButtonTapped() {
        dismiss {
            self.router?.navigateBack(animated: false, nil)
        }
    }
}

extension ChangeNameShoppingListViewController: SwipeableViewController {
    var threshold: CGFloat {
        textField.isEditing ? 0.5 : 0.3
    }
}

extension ChangeNameShoppingListViewController: UIGestureRecognizerDelegate {
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
