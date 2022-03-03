//
//  ShoppingListCollectionViewCell.swift
//  ShoppingList
//
//  Created by Андрей Журавлев on 24.05.2021.
//  Copyright © 2021 Dmitry Lemaykin. All rights reserved.
//

import UIKit
import SwipeCellKit

class ShoppingListCollectionViewCell: SwipeCollectionViewCell {
    
    static let reuseIdentifier = typeName
    
    @IBOutlet weak var listNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
//    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var userIconImageView: UIImageView!
    @IBOutlet weak var userIconContainerView: UIView!
    @IBOutlet weak var productsLabel: UILabel!
    @IBOutlet weak var labelsContainerTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var notificationBadge: UIImageView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureUI()
    }
    
    private func configureUI() {
        clipsToBounds = false
        layer.cornerRadius = 16
        backgroundColor = .shoppingListRed
        self.layer.shadowColor = UIColor.shoppingListShadowGray.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowRadius = 7
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 16
        contentView.backgroundColor = .white
        let imageView = UIImageView(image: UIImage(named: "tablecell.trash.icon"))
        imageView.contentMode = .center
        imageView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(imageView, belowSubview: contentView)
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
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
//        commonInit()
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let layoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        layoutIfNeeded()
        layoutAttributes.frame.size = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return layoutAttributes
    }
}
