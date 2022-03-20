import UIKit

protocol LogOutConfirmationRouting {
    func navigateBack(_ completion: (() -> Void)?)
    func presentWelcomeViewController(_ completion: (() -> Void)?)
}

class LogOutConfirmationViewController: BaseViewController {
    
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var viewModel: LogOutConfirmationViewModeling? {
        didSet {
            guard let viewModel = viewModel else {
                return
            }
            
            viewModel.didChange = { [weak self] in
                DispatchQueue.main.async {
                    self?.update()
                }
            }
            
            viewModel.didGetError = { [weak self] message in
                DispatchQueue.main.async { [weak self] in
                    self?.showErrorAlert(message: message)
                }
            }
            
            viewModel.didLogoutSuccessfully = { [weak self] in
                DispatchQueue.main.async {
                    self?.router?.presentWelcomeViewController(nil)
                }
            }
        }
    }
    var router: LogOutConfirmationRouting?
    
    private func update() {
        guard isViewLoaded else {
            return
        }
        updateLoadingState()
    }
    
    private func updateLoadingState() {
        let isLoading = viewModel?.isLoading ?? false
        buttonsStackView.isHidden = isLoading
        loadingIndicator.isHidden = isLoading == false
        isLoading ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        router?.navigateBack(nil)
    }
    
    @IBAction func LogOutTapped(_ sender: Any) {
        viewModel?.logOut()
    }
    
}
