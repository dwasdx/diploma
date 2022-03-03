//
//  ShareListCollectionViewCell.swift
//  ShoppingList
//
//  Created by Андрей Журавлев on 24.05.2021.
//  Copyright © 2021 Dmitry Lemaykin. All rights reserved.
//

import UIKit

class ShareListCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = typeName
    
    @IBOutlet weak var listNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var userIconImageView: UIImageView!
    @IBOutlet weak var messegeLabel: UILabel!
    
    var shareModel: ShareModel?
    
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
        backgroundColor = .white
        self.layer.shadowColor = UIColor.shoppingListShadowGray.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowRadius = 7
    }
    
    func configure(with model: ShareModel) {
        
        self.shareModel = model
        //To be done - get list name by id
        listNameLabel.text = model.listName
        
        let date = Date(timeIntervalSince1970: TimeInterval(model.createdAt))
        let formatter = DayDateFormatter()
        //FIXME: do something with this NA
        let updatedAt = formatter.time(date) ?? "NA"
        
        dateLabel.text = updatedAt
        
        messegeLabel.text = "Приглашение от пользователя \(model.ownerName)"
        
        userIconImageView.image = [UIImage(named: "user.icon"), UIImage(named: "users.icon")].randomElement().flatMap { $0 }
        
    }
    
    @IBAction func acceptButton(_ sender: Any) {
        guard let shareModel = shareModel else {
            return
        }
        CoreDataService.shared.acceptShare(model: shareModel, in: .view)
        SynchronizationService.shared.acceptShare(shareModel.id)
    }
    
    @IBAction func rejectButton(_ sender: Any) {
        guard let shareModel = shareModel else {
            return
        }
        CoreDataService.shared.rejectShare(model: shareModel, in: .view)
        if let token = CurrentUserManager.shared.userToken {
            SynchronizationService.shared.synchronizeDatabaseWithDelay(token: token)
        }
    }
}
