//
//  RateAppViewController.swift
//  ShoppingList
//
//  Created by Андрей Журавлев on 23.09.2020.
//  Copyright © 2020 Dmitry Lemaykin. All rights reserved.
//

import UIKit
import MessageUI

protocol RateAppViewControllerRouting {
    func navigateBack(_ completion: (() -> Void)?)
}

protocol RateAppViewModeling: BaseViewModeling {
    var rating: Int { get set }
    
    var theme: String? { get set }
    var problemDescription: String? { get set }
    
    var sendEmail: ((String, String) -> Void)? { get set }
    func sendEmailIfPossible()
}

class RateAppViewController: BaseViewController {
    
    @IBOutlet weak var ratingStarsView: RatingController!
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var headerTextField: UITextField!
    @IBOutlet weak var headerUnderline: UIView!
    
    @IBOutlet weak var problemTextView: UITextView!
    @IBOutlet weak var problemUnderline: UIView!
    @IBOutlet weak var problemHeightAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var sendReportButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scrollViewHeightAnchor: NSLayoutConstraint!
    @IBOutlet weak var containerViewSupportHeightAnchor: NSLayoutConstraint!
    @IBOutlet weak var containerViewYPosition: NSLayoutConstraint!
    
    var initialFingerYPosition: CGFloat = 0
    var currentFingerYPosition: CGFloat = 0
    var defaultContainerViewHeight: CGFloat = 353
    var didDismiss: (() -> Void)? {
        return { [weak self] in
            self?.router?.navigateBack(nil)
        }
    }
    
    var containerViewAndScrollViewHeight: CGFloat {
        get {
            scrollViewHeightAnchor.constant
        }
        set {
            
            scrollViewHeightAnchor.constant = newValue
            containerViewSupportHeightAnchor.constant = newValue
        }
    }
    
    var router: RateAppViewControllerRouting?
    var viewModel: RateAppViewModeling? {
        didSet {
            viewModel?.sendEmail = { theme, message in
                DispatchQueue.main.async { [weak self] in
                    self?.sendEmail(withTheme: theme, message: message)
                }
            }
            viewModel?.didChange = { [weak self] in
                DispatchQueue.main.async { [weak self] in
                    self?.update()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollViewHeightAnchor.constant = 0
        ratingStarsView.starsRating = viewModel?.rating ?? -1
        ratingStarsView.delegate = self
        setupTextView()
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func setupTextView() {
        problemTextView.text = placeholderText
        problemTextView.textColor = .shoppingListTextGray
        problemTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        problemTextView.delegate = self
    }
    
    private func resignFirstResponders() {
        headerTextField.resignFirstResponder()
        problemTextView.resignFirstResponder()
    }
    
    func dismiss(_ completion: @escaping (()->Void)) {
        self.scrollViewHeightAnchor.constant = 0
        self.containerViewSupportHeightAnchor.constant = 0
        resignFirstResponders()
        
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {
                        self.view.backgroundColor = .clear
                        self.view.layoutIfNeeded()
                        self.containerView.layoutIfNeeded()
        }) { (_) in
            completion()
        }
    }
    
    private func update() {
        guard isViewLoaded else {
            return
        }
        let isHiddenHeaderLabel = (headerTextField.text?.isEmpty ?? false)
        headerLabel.isHidden = isHiddenHeaderLabel
    }
    
    private func sendEmail(withTheme theme: String, message: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["support@shoppinglist.globus-ltd.com"])
            mail.setMessageBody(message, isHTML: false)
            mail.setSubject(theme)
            resignFirstResponders()
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
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
    
    @IBAction func backgroundTapped(_ sender: Any) {
        dismiss {
            self.didDismiss?()
        }
    }
    
    @IBAction func cancelButtonPressed() {
        dismiss {
            self.didDismiss?()
        }
    }
    
    @IBAction func sendReviewButtonPressed() {
        viewModel?.sendEmailIfPossible()
    }
    
    @IBAction func headerTextFieldEditingChanged(_ sender: UITextField) {
        viewModel?.theme = sender.text
    }
    
}

extension RateAppViewController: SwipeableViewController {
    var threshold: CGFloat {
        let isEditing = headerTextField.isEditing || problemTextView.isFirstResponder
        return isEditing ? 0.5 : 0.3
    }
}

extension RateAppViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let gesture = gestureRecognizer as? UIPanGestureRecognizer else {
            return false
        }
        if otherGestureRecognizer.view is UITextView {
            return false
        }
        let direction = gesture.velocity(in: gesture.view).y
        
        if scrollView.contentOffset.y == 0, direction > 0 {
            return false
        }
        return true
    }
}

extension RateAppViewController: RatingViewControllering {
    var starsRating: Int {
        get {
            viewModel?.rating ?? 0
        }
        set {
            viewModel?.rating = newValue
        }
    }
}

// inspired by https://stackoverflow.com/questions/27652227/how-can-i-add-placeholder-text-inside-of-a-uitextview-in-swift
extension RateAppViewController: UITextViewDelegate {
    private var placeholderText: String {
        "Описание проблемы"
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .shoppingListTextGray {
            textView.text = ""
            textView.textColor = .shoppingListTextBlack
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        viewModel?.problemDescription = textView.text
        
        let numLines = Int(textView.contentSize.height / textView.font!.lineHeight)
        if numLines <= 4 {
            let textVerticalOffset: CGFloat = 4
            let newTextViewHeight = textVerticalOffset * 2 + textView.contentSize.height
            guard problemHeightAnchor.constant != newTextViewHeight else {
                return
            }
            let heightDiff = newTextViewHeight - problemHeightAnchor.constant
            defaultContainerViewHeight += heightDiff
            scrollViewHeightAnchor.constant += heightDiff
            containerViewSupportHeightAnchor.constant += heightDiff
            problemHeightAnchor.constant = newTextViewHeight
            UIView.animate(withDuration: 0.1,
                           delay: 0,
                           options: .curveEaseInOut,
                           animations: {
                            self.scrollView.layoutIfNeeded()
                            self.containerView.layoutIfNeeded()
                            self.problemTextView.layoutIfNeeded()
            },
                           completion: nil)
        } else {
        }
        print(textView.contentSize.height, textView.frame.height)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = .shoppingListTextGray
        }
    }
}

extension RateAppViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
            case .cancelled, .failed:
                controller.dismiss(animated: true)
            case .saved, .sent:
                controller.dismiss(animated: true) {
                    self.dismiss {}
                }
            @unknown default:
                break
        }
    }
}
