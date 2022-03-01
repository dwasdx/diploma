import UIKit

protocol ConfirmPhoneNumberViewControllerRouting {
    func navigateBack(_ completion: (() -> Void)?)
    func presentTabBarViewController(_ completion: (() -> Void)?)
}

protocol ConfirmPhoneNumberViewModeling: BaseViewModeling {
    var phone: String { get }
    var tittle: String { get }
    
    var isAllowedToQuerySMSCode: Bool { get set }
    
    var didGetSmsCodeError: ((String) -> Void)? { get set }
    var didConfirmCode: (() -> Void)? { get set }
    var didChangeAwaitingForSMSCodeState: (() -> Void)? { get set }
    
    func confirmRegistration(with code: String?)
    func queryCodeAgain()
}

class ConfirmPhoneNumberViewController: BaseViewController {
    
    var router: ConfirmPhoneNumberViewControllerRouting?
    var viewModel: ConfirmPhoneNumberViewModeling? {
        didSet {
            viewModel?.didChange = { [weak self] in
                DispatchQueue.main.async {
                    self?.update()
                }
            }
            viewModel?.didGetSmsCodeError = { [weak self] message in
                DispatchQueue.main.async {
                    self?.toggleErrorLabel(isHiddenState: false, text: message)
                }
            }
            viewModel?.didConfirmCode = { [weak self] in
                DispatchQueue.main.async {
                    self?.router?.presentTabBarViewController(nil)
                }
            }
            viewModel?.didGetError = { [weak self] message in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {
                        return
                    }
                    let offsetPoint: CGPoint? = self.smsCodeTextField.isEditing ? CGPoint(x: self.view.center.x, y: self.scrollView.frame.maxY - 25) : nil
                    self.showDefaultToast(withMessage: message, point: offsetPoint)
                }
            }
            viewModel?.didChangeAwaitingForSMSCodeState = { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    self?.updateSendCodeAgainButton()
                }
            }
        }
    }
    
    @IBOutlet weak var tittleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var smsCodeLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var smsCodeTextField: UITextField!
    
    @IBOutlet weak var sendCodeAgainButton: UIButton!
    
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scrollViewYPosition: NSLayoutConstraint!
    @IBOutlet weak var scrollViewHeightAnchor: NSLayoutConstraint!
    
    var initialFingerYPosition: CGFloat = 0
    var currentFingerYPosition: CGFloat = 0
    let defaultContainerViewHeight: CGFloat = 398
    var didDismiss: (() -> Void)? {
        return { [weak self] in
            self?.dismiss {
                self?.router?.navigateBack(nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageLabel.text = "\(messageLabel.text!) \(viewModel?.phone ?? "")"
        tittleLabel.text = viewModel?.tittle
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        smsCodeTextField.becomeFirstResponder()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollViewHeightAnchor.constant = defaultContainerViewHeight
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
        updateLoadingState()
    }
    
    private func updateLoadingState() {
        let isLoading = viewModel?.isLoading ?? false
        buttonsStackView.isHidden = isLoading
        loadingIndicator.isHidden = isLoading == false
        isLoading ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()
    }
    
    private func updateSendCodeAgainButton() {
        let buttonText = sendCodeAgainButton.titleLabel?.text ?? ""
        let isAllowedToQueryCode = viewModel?.isAllowedToQuerySMSCode ?? false
        let color: UIColor = isAllowedToQueryCode ? .shoppingListBlue : .shoppingListIconsGray
        let title = NSAttributedString(string: buttonText, attributes: [.foregroundColor : color])
        sendCodeAgainButton.setAttributedTitle(title, for: .normal)
        sendCodeAgainButton.isUserInteractionEnabled = isAllowedToQueryCode
    }
    
    private func collapseContainerView() {
        
        view.endEditing(true)
        self.scrollViewHeightAnchor.constant = 0
        
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {
                        self.view.backgroundColor = .clear
                        self.view.layoutSubviews()
        }) { (_) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.router?.presentTabBarViewController(nil)
            }
        }
    }
    
    private func toggleErrorLabel(isHiddenState state: Bool, text: String) {
        errorLabel.isHidden = state
        errorLabel.text = text
    }
    
    
}

//MARK: Atctions

extension ConfirmPhoneNumberViewController {
    
    @IBAction func scrollViewTapped(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func codeTextFieldEditingChanged(_ sender: UITextField) {
        guard sender.text != nil else {
            return
        }
        toggleErrorLabel(isHiddenState: true, text: "")
    }
    
    @IBAction func nextButtonTapped() {
        viewModel?.confirmRegistration(with: smsCodeTextField.text)
    }
    @IBAction func backButtonTapped() {
        dismiss {
            self.router?.navigateBack(nil)
        }
    }
    @IBAction func sendCodeButtonTapped() {
        viewModel?.queryCodeAgain()
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
        scrollViewYPosition.constant = 0
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: { [weak self] in
                        self?.view.layoutIfNeeded()
            }, completion: nil)
    }
}

extension ConfirmPhoneNumberViewController: SwipeableViewController {
    
    var threshold: CGFloat {
        smsCodeTextField.isEditing ? 0.5 : 0.3
    }
}
