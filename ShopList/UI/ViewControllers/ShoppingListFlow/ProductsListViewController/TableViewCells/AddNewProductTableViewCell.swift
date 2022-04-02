import UIKit

class AddNewProductTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = typeName
    
    @IBOutlet weak var nameLabel: UILabel!
    
    func configure(model: ProductViewModeling) {
        nameLabel.text = model.title
        
    }
}
