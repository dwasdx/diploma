import UIKit

protocol SignInViewControllerRouting {
    func presentWelcomeViewController(_ completion: (() -> Void)?)
    func dismissSignInViewController(_ completion: (()->Void)?)
    func presentRegisterationViewController(_ completion: (()->Void)?)
    func presentConfirmPhoneViewController(_ phoneNumber: String, completion: (() -> Void)?)
}

protocol SignInViewModeling: BaseViewModeling {
    
    var phoneNumber: String? { get set }
    var isLoginAvailable: Bool { get }
    var phoneNumberPrefix: String { get }
        
    var didGetPhoneError: ((String) -> Void)? { get set }
    
    var didRequestCode: ((String) -> Void)? { get set }
    
    func signIn()
}

class SignInViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var wrongLoginLabel: UILabel!
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var loginUnderline: UIView!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var ScrollViewYPosition: NSLayoutConstraint!
    @IBOutlet weak var scrollViewHeightAnchor: NSLayoutConstraint!
    
    var initialFingerYPosition: CGFloat = 0
    var currentFingerYPosition: CGFloat = 0
    var defaultContainerViewHeight: CGFloat = 398
    var didDismiss: (() -> Void)? {
        return { [weak self] in
            self?.dismiss {
                self?.router?.presentWelcomeViewController(nil)
            }
        }
    }
    
    var router: SignInViewControllerRouting?
    var viewModel: SignInViewModeling? {
        didSet {
            guard let viewModel = viewModel else {
                return
            }
            
            viewModel.didChange = { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    self?.update()
                }
            }
            
            viewModel.didGetError = { [weak self] message in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {
                        return
                    }
                    let offsetPoint: CGPoint? = self.loginTextField.isEditing ? CGPoint(x: self.view.center.x, y: self.scrollView.frame.maxY - 25) : nil
                    self.showDefaultToast(withMessage: message, point: offsetPoint)
                }
            }
            
            viewModel.didGetPhoneError = { [weak self] message in
                DispatchQueue.main.async { [weak self] in
                    self?.updatePhoneErrorLabel(isErrorState: true, text: message)
                }
            }
            
            viewModel.didRequestCode = { [weak self] phone in
                DispatchQueue.main.async { [weak self] in
                    self?.dismiss {
                        self?.router?.presentConfirmPhoneViewController(phone, completion: nil)
                    }
                }
                
            }
        }
    }
    
    // MARK: - methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginTextField.delegate = self
        loginTextField.addTarget(self, action: #selector(loginTextFieldDidChange), for: .editingChanged)
        loginTextField.keyboardType = .phonePad
        update()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ScrollViewYPosition.constant = 0
        scrollViewHeightAnchor.constant = 0
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.scrollViewHeightAnchor.constant = self.defaultContainerViewHeight
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {
                        self.view.backgroundColor = .shoppingListBlackTransparent
                        self.view.layoutSubviews()
        },
                       completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func dismiss(_ completion: @escaping (() -> Void)) {
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
    
    private func updatePhoneErrorLabel(isErrorState: Bool, text: String? = nil) {
        wrongLoginLabel.isHidden = !isErrorState
        wrongLoginLabel.text = text
        loginUnderline.backgroundColor = isErrorState ? .shoppingListRed : .shoppingListIconsGray
    }
    
    // MARK: - updates
    
    private func update() {
        guard isViewLoaded else {
            return
        }
        loginButton.backgroundColor = viewModel?.isLoginAvailable ?? false ? .shoppingListOrange : .shoppingListIconsGray
        loginButton.isEnabled = viewModel?.isLoginAvailable ?? false
        updateLoadingState()
    }
    
    private func updateLoadingState() {
        let isLoading = viewModel?.isLoading ?? false
        loginButton.isHidden = isLoading
        loadingIndicator.isHidden = isLoading == false
        isLoading ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()
    }
    
}

// MARK: - Actions

extension SignInViewController {
    
    @IBAction func backgorundTapped(_ sender: Any) {
        dismiss {
            self.router?.presentWelcomeViewController(nil)
        }
    }
    
    @IBAction func scrollViewTapped(_ sender: Any) {
        view.endEditing(true)
    }
    
    @objc private func loginTextFieldDidChange() {
        viewModel?.phoneNumber = loginTextField.text?.decimalString
        updatePhoneErrorLabel(isErrorState: false)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            ScrollViewYPosition.constant = keyboardSize.height
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           options: .curveEaseOut,
                           animations: { [weak self] in
                            self?.view.layoutIfNeeded()
                }, completion: nil)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        ScrollViewYPosition.constant = 0
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: { [weak self] in
                        self?.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    @IBAction func registrationButtonTapped(_ sender: Any) {
        dismiss {
            self.router?.presentRegisterationViewController(nil)
        }
    }
    
    @IBAction func enterButtonTapped(_ sender: Any) {
        viewModel?.signIn()
    }
    
    @IBAction func didPanContainerView(_ sender: UIPanGestureRecognizer) {
        didSwipeContainerView(sender)
    }
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField.text ?? "").isEmpty {
            textField.text = viewModel?.phoneNumberPrefix
            update()
        }
    }
}

extension SignInViewController: SwipeableViewController {
    var threshold: CGFloat {
        loginTextField.isEditing ? 0.5 : 0.3
    }
}

extension SignInViewController: UIGestureRecognizerDelegate {
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
