import UIKit

class SelfSizedTableView: UITableView {

    var maxHeight: CGFloat = UIScreen.main.bounds.size.height
    
    func reloadSize() {
        self.invalidateIntrinsicContentSize()
        self.layoutIfNeeded()
    }
    
    override var intrinsicContentSize: CGSize {
        let height = min(contentSize.height, maxHeight)
        return CGSize(width: contentSize.width, height: height)
    }

}
