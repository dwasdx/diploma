import UIKit

protocol RegistrationViewControllerRouting: BaseRouting {
    
    func presentWelcomeViewController(_ completion: (() -> Void)?)
    func presentConfirmRegistrationViewController(phoneNumber: String, _ completion: (() -> Void)?)
    func presentSignInViewController(_ completion: (() -> Void)?)
    func presentConfidentialityAgreementViewController(_ completion: (() -> Void)?)
}

protocol RegistrationViewModeling: BaseViewModeling {
    var username: String? { get set }
    var phone: String? { get set }
    var agreementApproved: Bool { get set }
    var isRegistrationAvailable: Bool { get }
    var phoneNumberPrefix: String { get }
    
    var didSuccessfullyRegistered: (() -> Void)? { get set }
    
    var didGetPhoneError: ((String) -> Void)? { get set }
    var didGetUserError: ((String) -> Void)? { get set }
    
    func register()
}

class RegistrationViewController: NameEditingViewController {
    
    var router: RegistrationViewControllerRouting?
    var viewModel: RegistrationViewModeling? {
        didSet {
            viewModel?.didChange = { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    self?.update()
                }
            }
            viewModel?.didSuccessfullyRegistered = { [weak self] in
                DispatchQueue.main.async {
                    self?.dismiss {
                        self?.router?.presentConfirmRegistrationViewController(phoneNumber: self!.viewModel!.phone!, nil)
                    }
                }
            }
            viewModel?.didGetUserError = { [weak self] message in
                DispatchQueue.main.async { [weak self] in
                    self?.updateNameErrorLabel(isErrorState: true, message: message)
                }
            }
            viewModel?.didGetPhoneError = { [weak self] message in
                DispatchQueue.main.async { [weak self] in
                    self?.updatePhoneErrorLabel(isErrorState: true, message: message)
                }
            }
            viewModel?.didGetError = { [weak self] message in
                DispatchQueue.main.async { [ weak self] in
                    guard let self = self else {
                        return
                    }
                    let isEditing = self.nameTextField.isEditing || self.phoneTextField.isEditing
                    let offsetPoint: CGPoint? = isEditing ? CGPoint(x: self.view.center.x, y: self.scrollView.frame.maxY - 25) : nil
                    self.showDefaultToast(withMessage: message, point: offsetPoint)
                }
            }
            
        }
    }
    
    @IBOutlet weak var nameUnderline: UIView!
    @IBOutlet weak var phoneUnderline: UIView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var nameErrorLabel: UILabel!
    @IBOutlet weak var phoneErrorLabel: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scrollViewHeightAnchor: NSLayoutConstraint!
    @IBOutlet weak var scrollViewYPosition: NSLayoutConstraint!
    
    var initialFingerYPosition: CGFloat = 0
    var currentFingerYPosition: CGFloat = 0
    let defaultContainerViewHeight: CGFloat = 524
    var didDismiss: (() -> Void)? {
        return { [weak self] in
            self?.dismiss {
                self?.router?.presentWelcomeViewController(nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isOpaque = false
        super.nameEditingTextField = nameTextField //needed for handling whitespaces entering
        nameTextField.delegate = self
        phoneTextField.delegate = self
        
        scrollViewHeightAnchor.constant = 0
        loadingIndicator.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        scrollViewYPosition.constant = 0
        scrollViewHeightAnchor.constant = 0
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.scrollViewHeightAnchor.constant = 524
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {
                        self.view.backgroundColor = .shoppingListBlackTransparent
                        self.view.layoutIfNeeded()
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
    
    private func update() {
        guard isViewLoaded else {
            return
        }
        updateNextButton()
        updateLoadingState()
    }
    
    private func updateNextButton() {
        nextButton.backgroundColor = viewModel?.isRegistrationAvailable ?? false ? .shoppingListOrange : .shoppingListIconsGray
        nextButton.isEnabled = viewModel?.isRegistrationAvailable ?? false
    }
    
    private func updateLoadingState() {
        let isLoading = viewModel?.isLoading ?? false
        nextButton.isHidden = isLoading == true
        loadingIndicator.isHidden = isLoading == false
        isLoading ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()
    }
    
    private func updateNameErrorLabel(isErrorState: Bool, message: String? = nil) {
        nameErrorLabel.isHidden = !isErrorState
        nameErrorLabel.text = message
        nameUnderline.backgroundColor = isErrorState ? .shoppingListRed : .shoppingListIconsGray
    }
    
    private func updatePhoneErrorLabel(isErrorState: Bool, message: String? = nil) {
        phoneErrorLabel.isHidden = !isErrorState
        phoneErrorLabel.text = message
        phoneUnderline.backgroundColor = isErrorState ? .shoppingListRed : .shoppingListIconsGray
    }
}

// MARK: - Actions

extension RegistrationViewController {
    
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        dismiss {
            self.router?.presentWelcomeViewController(nil)
        }
    }
    
    @IBAction func scrollViewTapped(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func nextButtonTapped() {
        viewModel?.register()
    }
    
    @IBAction func signInButtonTapped() {
        dismiss {
            self.router?.presentSignInViewController(nil)
        }
    }
    
    @IBAction func didPanContainerView(_ sender: UIPanGestureRecognizer) {
        didSwipeContainerView(sender)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.scrollViewYPosition.constant = keyboardSize.height
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           options: .curveEaseOut,
                           animations: { [weak self] in
                            self?.view.layoutIfNeeded()
                }, completion: nil)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.scrollViewYPosition.constant = 0
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: { [weak self] in
                        self?.view.layoutIfNeeded()
            },
                       completion: nil)
        
    }
}

//MARK: UITextFieldDelegate
// conformed in superclass

extension RegistrationViewController {
    private func toggleLabelsHelper(nearTextField textField: UITextField, withState state: Bool) {
        if textField === nameTextField {
            updateNameErrorLabel(isErrorState: false)
            viewModel?.username = textField.text
        } else if textField === phoneTextField {
            updatePhoneErrorLabel(isErrorState: false)
            viewModel?.phone = textField.text?.decimalString
        }
    }
    
    @IBAction func editingChanged(_ sender: UITextField) {
        if sender.text!.isEmpty == false {
            toggleLabelsHelper(nearTextField: sender, withState: false)
        } else {
            toggleLabelsHelper(nearTextField: sender, withState: true)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField === phoneTextField, (textField.text ?? "").isEmpty {
            textField.text = viewModel?.phoneNumberPrefix
            update()
        }
    }
}

extension RegistrationViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        if URL.absoluteString == "agreementTapped" {
            router?.presentConfidentialityAgreementViewController(nil)
        }
        
        return false
    }
    
}

extension RegistrationViewController: UIGestureRecognizerDelegate {
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

extension RegistrationViewController: SwipeableViewController {
    var threshold: CGFloat {
        phoneTextField.isEditing || nameTextField.isEditing ? 0.5 : 0.3
//        0.3
    }
}
