//
//  ListMembersTableViewCell.swift
//  ShoppingList
//
//  Created by Андрей Журавлев on 06.07.2020.
//  Copyright © 2020 Dmitry Lemaykin. All rights reserved.
//

import UIKit

class ListMembersTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = typeName
    
    @IBOutlet weak var avatarView: DesignableView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var memberNameLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var containerView: UIView!
    
    var panGesture: UIPanGestureRecognizer?
    weak var gestureDelegate: UIGestureRecognizerDelegate?
    
    private func commonInit() {
        containerView.gestureRecognizers?.removeAll()
        makeGesture(&panGesture, container: containerView, selector: #selector(panGestureAction))
        
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
    
    var panGestureBlock: ((UIPanGestureRecognizer, ListMembersTableViewCell) -> Void)?
    
    @objc private func panGestureAction() {
        guard let panGesture = panGesture else {
            return
        }
        panGestureBlock?(panGesture, self)
    }
    
    func configure(with model: ListMemberModel) {
        memberNameLabel.text = model.name.isEmpty ? model.phoneNumber : model.name
        configureViews(basedOnMembership: model.status == .member)
        commonInit()
    }
    
    
    /// - Parameters:
    ///    - state: if state = true, then member accepted invitation, else - still awaiting for it to accept
    
    private func configureViews(basedOnMembership state: Bool) {
        memberNameLabel.textColor = state ? .shoppingListTextBlack : .shoppingListTextGray
        
        avatarView.backgroundColor = state ? .shoppingListOrange : .white
        avatarView.borderWidth = state ? 0 : 1
        
        let imageName = state ? "user.icon" : "user.gray.icon"
        avatarImageView.image = UIImage(named: imageName)
        
        activityIndicator.isHidden = state
        state ? activityIndicator.stopAnimating() : activityIndicator.startAnimating()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        containerView.center.x = self.superview?.center.x ?? containerView.center.x
    }
    
}
