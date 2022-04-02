import UIKit

protocol ShareAppRouting: BaseRouting {
    func navigateBack(animated: Bool, _ completion: (() -> Void)?)
}

protocol ShareAppViewModeling: BaseViewModeling {
    func getShareMessage() -> String
}

class ShareAppViewController: UIViewController {
    
    var viewModel: ShareAppViewModeling?
    var router: ShareAppRouting?
    weak var delegate: AddNewContactDelegate?
    
    @IBAction func shareButtonTapped() {
        delegate?.actionButtonTapped()
        guard let shareMessage = self.viewModel?.getShareMessage() else {
            return
        }
        let vc = UIActivityViewController(activityItems: [shareMessage], applicationActivities: [])
        present(vc, animated: true)
        
    }
    
    @IBAction func closeButtonTapped() {
        router?.navigateBack(animated: true, nil)
    }
    
}
