import UIKit

protocol DeleteProductConfirmationViewControllerRouting {
    func presentProductsListViewController(_ completion: (() -> Void)?)
}

class DeleteProductConfirmationViewController: BaseViewController {
    
    @IBOutlet weak var messageLabel: UILabel!
    
    var router: DeleteProductConfirmationViewControllerRouting?
    var viewModel: DeleteProductViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageLabel.text = "\(messageLabel.text!) \(viewModel.description)?"
    }
    
    @IBAction func deleteButtonTapped() {
        router?.presentProductsListViewController { [weak self] in
            self?.viewModel.deleteProduct()
        }
    }
    
    @IBAction func cancelButtonTapped() {
        router?.presentProductsListViewController { [weak self] in
            self?.viewModel.reloadCell()
        }
    }
    
}
