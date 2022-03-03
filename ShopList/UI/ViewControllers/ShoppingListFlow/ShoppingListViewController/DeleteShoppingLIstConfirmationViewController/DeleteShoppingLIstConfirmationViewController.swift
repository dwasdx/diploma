import UIKit

protocol DeleteShoppingListConfirmationRouting {
    func navigateBack(_ completion: (() -> Void)?)
}

class DeleteShoppingListConfirmationViewController: BaseViewController {
    
    @IBOutlet weak var messageLabel: UILabel!
    
    var viewModel: DeleteShoppingListViewModeling?
    var router: DeleteShoppingListConfirmationRouting?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let viewModel = viewModel else {
            return
        }
        messageLabel.text = "\(viewModel.descriptionText)"
    }
    
    @IBAction func deleteButtonTapped() {
        router?.navigateBack { [weak self] in
            self?.viewModel?.deleteFromParentViewModel()
        }
    }
    @IBAction func cancelButtonTapped() {
        router?.navigateBack { [weak self] in
            self?.viewModel?.reloadCell()
        }
    }
}
