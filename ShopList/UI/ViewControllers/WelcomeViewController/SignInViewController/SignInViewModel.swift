import Foundation

class SignInViewModel: BaseViewModel {
 
    
    var phoneNumber: String? {
        didSet {
            didChange?()
        }
    }
    
    var didGetPhoneError: ((String) -> Void)?
    
    var didRequestCode: ((String) -> Void)?
    
    func processServerError(_ error: ShoppingListServerError.BackendError) {
        switch error.code {
            case 7:
                didGetPhoneError?("Нет пользователя с таким номером телефона")
            case 14:
            guard let phoneNumber = phoneNumber else {
                return
            }
            didRequestCode?(phoneNumber)
            default:
                didGetError?("Что-то пошло не так")
        }
    }
    
}

extension SignInViewModel: SignInViewModeling {
    
    var isLoginAvailable: Bool {
        if let phoneNumber = phoneNumber {
            if phoneNumber.hasPrefix("7") {
              return 11...15 ~= phoneNumber.count
            } else {
               return  7...15 ~= phoneNumber.count
            }
        }
        return false
    }
    
    var phoneNumberPrefix: String {
        PhoneNumberManager.shared.defaultRegionPrefix
    }
    
    func signIn() {
        
        guard let login = phoneNumber else {
            didGetPhoneError?("Пожалуйста, введите номер телефона")
            return
        }
        
        guard let phone = Int(login) else {
            return
        }
        isLoading = true
        ShoppingListService.shared.login(phone: phone) { [weak self] (result) in
            defer {
                self?.isLoading = false
            }
            switch result {
                case .success(let loginResponse):
                    guard let id = loginResponse?.user_id else {
                        return
                    }
                    CurrentUserManager.shared.userIdentifier = id
                    self?.didRequestCode?(login)
                case .failure(let error):
                    switch error {
                        case .server(let serverError):
                            self?.processServerError(serverError)
                        case .parsing(_): //TBD
                            break
                        case .network(_): //TBD
                            self?.didGetError?("Нет соединения с сервером")
                }
            }
        }
        
    }
    
}
