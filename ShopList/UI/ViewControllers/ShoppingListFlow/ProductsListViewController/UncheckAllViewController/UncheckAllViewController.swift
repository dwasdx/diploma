import UIKit

protocol UncheckAllViewModeling: BaseViewModeling {
    func uncheckAll(_ completion: (() -> Void)?)
}

protocol UncheckAllRouting: BaseRouting {
    func navigateBack(animated: Bool, _ completion: (() -> Void)?)
}

class UncheckAllViewController: UIViewController {
    
    var viewModel: UncheckAllViewModeling?
    var router: UncheckAllRouting?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backgroundTapped(_ sender: Any) {
        router?.navigateBack(animated: true, nil)
    }
    
    @IBAction func reuseButtonTapped(_ sender: Any) {
        viewModel?.uncheckAll({
            self.router?.navigateBack(animated: true, nil)
        })
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        router?.navigateBack(animated: true, nil)
    }
    
}
