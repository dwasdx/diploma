import UIKit

class CartHeaderView: UITableViewHeaderFooterView {
    static let reuseId = String(describing: self)
    
    @IBOutlet weak var reuseButton: UIButton!
    @IBOutlet weak var label: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        reuseButton.layer.cornerRadius = reuseButton.frame.height / 2
    }

}
