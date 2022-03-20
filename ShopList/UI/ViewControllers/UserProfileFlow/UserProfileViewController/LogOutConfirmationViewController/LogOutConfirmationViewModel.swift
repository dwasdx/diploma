import Foundation

protocol LogOutConfirmationViewModeling: BaseViewModeling {
    func logOut()
    var didLogoutSuccessfully: (() -> Void)? { get set }
}

class LogOutConfirmationViewModel: BaseViewModel {
    
    var didLogoutSuccessfully: (() -> Void)?
    
}

extension LogOutConfirmationViewModel: LogOutConfirmationViewModeling {
    
    func logOut() {
        isLoading = true
        CurrentUserManager.shared.logOut { [weak self] in
            self?.didLogoutSuccessfully?()
            self?.isLoading = false
        }
    }
    
}
