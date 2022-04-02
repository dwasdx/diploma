//
//  ListMemberTableViewHeaderView.swift
//  ShoppingList
//
//  Created by Андрей Журавлев on 06.07.2020.
//  Copyright © 2020 Dmitry Lemaykin. All rights reserved.
//

import UIKit

class ListMemberTableViewHeaderView: UITableViewHeaderFooterView {
    
    static let reuseIdentifier = typeName
    
    let label: UILabel = {
        let label = UILabel()
        label.font = .RobotoSans(.regular, size: 16)
        label.textColor = .shoppingListTextBlack
        return label
    }()
    var labelCenterYAnchor: NSLayoutConstraint?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundView = UIView()
        backgroundView?.backgroundColor = .shoppingListWhite
        
        addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        labelCenterYAnchor = label.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 4)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            labelCenterYAnchor!,
        ])
    }
    
    func configure(with model: ListMemberCategoryModel) {
        label.text = model.title
        switch model.position {
            case .first:
                labelCenterYAnchor?.constant = 4
            case .second:
                labelCenterYAnchor?.constant = 12
        }
    }
}
