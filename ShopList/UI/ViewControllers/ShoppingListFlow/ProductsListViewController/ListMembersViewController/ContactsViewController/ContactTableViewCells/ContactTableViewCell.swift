import UIKit

class ContactTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = typeName
    var parentViewModel: ContactsViewModeling?
    
    @IBOutlet weak var background: DesignableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var avatarBackgroundView: UIView!
    @IBOutlet weak var isInAppImage: UIImageView!
    
    func configure(_ model: ListMemberModel) {
        
        switch model.status {
            case .member, .invited:
                avatarBackgroundView.backgroundColor = .shoppingListOrange
                nameLabel.textColor = .shoppingListTextGray
                background.backgroundColor = .shoppingListShadowGrayRegular
                addButton.isHidden = true
            
            case .notInvited, .refused:
                addButton.isHidden = false
                nameLabel.textColor = .shoppingListTextBlack
                avatarBackgroundView.backgroundColor = .shoppingListBlue
        }
        phoneNumberLabel.text = model.phoneNumber
        nameLabel.text = model.name
        isInAppImage.isHidden = !model.isInApp
    }
    
}
