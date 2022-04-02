import UIKit

class ListActtionsTableViewCell: UITableViewCell {
    static let reuseIdentifier = typeName
    
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var actionImage: UIImageView!
    
    func configure(with model: ListActionsModel) {
        actionLabel.text = model.title
        actionImage.image = model.image
    }
}
