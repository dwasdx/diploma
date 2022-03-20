import UIKit

//MARK: Protocols

protocol ApprovedViewRouting {
    func dissmissApprovedViewController(_ completion: (()->Void)?)
}

protocol ApprovedViewModeling: BaseViewModeling {
    var title: String { get }
    var messege: String? { get }
}

//MARK: General

class ApprovedViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messegeLabel: UILabel!
    
    var router: ApprovedViewRouting?
    var viewModel: ApprovedViewModeling? {
        didSet {
            guard let viewModel = viewModel else {
                return
            }
            
            viewModel.didChange = {
                return
            }
            
            viewModel.didGetError = { [weak self] message in
                DispatchQueue.main.async { [weak self] in
                    self?.showErrorAlert(message: message)
                }
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        update()
    }
    
    private func update() {
        titleLabel.text = viewModel?.title
        messegeLabel.text = viewModel?.messege
    }
    
    @IBAction func returnBackButtonTapped(_ sender: Any) {
        router?.dissmissApprovedViewController(nil)
    }
}
