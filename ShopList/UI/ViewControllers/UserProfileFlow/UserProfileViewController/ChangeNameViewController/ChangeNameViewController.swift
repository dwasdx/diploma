import UIKit

//MARK: RoutingProtocol

protocol ChangeUserNameRouting {
    func dismissChangeNameViewController(_ completion: (() -> Void)?)
    func presentApprovedNameViewController(_ completion: (() -> Void)?)
}

protocol ChangeNameViewModeling: BaseViewModeling {
    var currentUser: Emitter<CurrentUserModel?>? { get }
    var newName: String? { get set }
    var isAllowedToChangeName: Bool { get }
    
    var didGetNameError: ((String) -> Void)? { get set }
    
    func updateUserName(_ completion: ((Error?) -> Void)?)
    
}

class ChangeNameViewController: NameEditingViewController {
    
    //MARK: Outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var scrollViewHeightAnchor: NSLayoutConstraint!
    @IBOutlet weak var errorNameLabel: UILabel!
    @IBOutlet weak var errorNameLine: UIView!
    
    var initialFingerYPosition: CGFloat = 0
    var currentFingerYPosition: CGFloat = 0
    var currentFingerOffset: CGFloat {
        currentFingerYPosition - initialFingerYPosition
    }
    var defaultContainerViewHeight: CGFloat = 367
    var didDismiss: (() -> Void)? {
        return { [weak self] in
            self?.router?.dismissChangeNameViewController(nil)
        }
    }
    
    //MARK: General
    
    var router: ChangeUserNameRouting?
    var viewModel: ChangeNameViewModeling? {
        didSet {
            guard let viewModel = viewModel else {
                return
            }
            viewModel.didChange = {
                DispatchQueue.main.async { [weak self] in
                    self?.update()
                }
            }
            viewModel.didGetError = { [weak self] message in
                DispatchQueue.main.async { [weak self] in
                    self?.showErrorAlert(message: message)
                }
            }
            viewModel.didGetNameError = { [weak self] message in
                DispatchQueue.main.async { [weak self] in
                    self?.updateErrorLabel(isErrorState: true, message: message)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollViewHeightAnchor.constant = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setup()
        
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
        
        userNameTextField.becomeFirstResponder()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func dismiss(_ completion: @escaping (()->Void)) {
        self.scrollViewHeightAnchor.constant = 0
        userNameTextField.resignFirstResponder()
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
    
    //MARK: Updates
    
    private func setup() {
        setupUserNameTextField()
        update()
    }
    
    private func update() {
        guard isViewLoaded else {
            return
        }
        updateNextButton()
        updateErrorLabel(isErrorState: false)
    }
    
    private func setupUserNameTextField() {
        super.nameEditingTextField = userNameTextField
        userNameTextField?.text = viewModel?.currentUser?.value?.name
    }
    
    private func updateNextButton() {
        let isAllowedToChangeName = viewModel?.isAllowedToChangeName ?? false
        let color: UIColor = isAllowedToChangeName ? .shoppingListOrange : .shoppingListIconsGray
        nextButton.backgroundColor = color
    }
    
    private func updateErrorLabel(isErrorState: Bool, message: String? = nil) {
        errorNameLabel.text = message
        errorNameLabel.isHidden = !isErrorState
        errorNameLine.backgroundColor = isErrorState ? .shoppingListRed : .shoppingListIconsGray
    }
    
    //MARK: KeyboardShow/Hide
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            bottomConstraint.constant = keyboardSize.height
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           options: .curveEaseOut,
                           animations: { [weak self] in
                            self?.view.layoutIfNeeded()
                }, completion: nil)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        bottomConstraint.constant = 0
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: { [weak self] in
                        self?.view.layoutIfNeeded()
            }, completion: nil)
        
    }
    
    @IBAction func didPanContainerView(_ sender: UIPanGestureRecognizer) {
        didSwipeContainerView(sender)
    }
    
    //MARK: IBAtctions
    
    @IBAction func editingChanged(_ sender: UITextField) {
//        if viewModel?.lastError != nil {
//            viewModel?.lastError = nil
//        }
        viewModel?.newName = sender.text
    }
    
    @IBAction func backgroundTapped(_ sender: Any) {
        self.scrollViewHeightAnchor.constant = 0
        
        dismiss {
            self.router?.dismissChangeNameViewController(nil)
        }
    }
    
    @IBAction func saveNewNameButtonTapped(_ sender: Any) {
        viewModel?.updateUserName { (error) in
            if error != nil {
                return
            } else {
                self.dismiss {
                    self.router?.presentApprovedNameViewController(nil)
                }
            }
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss {
            self.router?.dismissChangeNameViewController(nil)
        }
    }
    
}

extension ChangeNameViewController: UIGestureRecognizerDelegate {
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

extension ChangeNameViewController: SwipeableViewController {
    
    var threshold: CGFloat {
        userNameTextField.isEditing ? 0.5 : 0.3
    }
}
