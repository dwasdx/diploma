import Foundation

enum AuthenticationType: String {
    case login = "Вход"
    case registration = "Регистрация"
}

class ConfirmPhoneNumberViewModel: BaseViewModel {
    var phoneNumber: String
    
    var isAllowedToQuerySMSCode = false {
        didSet {
            didChangeAwaitingForSMSCodeState?()
        }
    }
    
    var didGetSmsCodeError: ((String) -> Void)?
    var didConfirmCode: (() -> Void)?
    var didChangeAwaitingForSMSCodeState: (() -> Void)?
    
    private let type: AuthenticationType
    
    init(_ phoneNumber: String, type: AuthenticationType) {
        self.phoneNumber = phoneNumber
        self.type = type
    }
    
    
    private func processServerError(_ error: ShoppingListServerError.BackendError) {
        switch error.code {
            case 10:
                didGetSmsCodeError?("Неправильный код")
            case 13:
                didGetSmsCodeError?("Неправильный код")
            default:
                didGetError?("Что-то пошло не так")
        }
    }
    
    private func processQueryCodeAgainServerError(_ error: ShoppingListServerError.BackendError) {
        switch error.code {
            case 14:
                checkAuthorizationLimit()
            default:
                didGetError?("Что-то пошло не так")
        }
    }
    
    private func checkAuthorizationLimit() {
        ShoppingListService.shared.checkAuthorizationLimit(phoneNumber: phoneNumber) { [weak self] (result) in
            guard let self = self else {
                return
            }
            switch result {
                case .success(let response):
                    guard let response = response else {
                        return
                    }
                    let secondsDifference = response.next_time_request - Int(Date().timeIntervalSince1970)
                    let message = secondsDifference < 0 ? "Следующий запрос через 24 часа": "Следующий запрос через \(secondsDifference) секунд"
                    self.didGetError?(message)
                
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(secondsDifference)) { [weak self] in
                        self?.isAllowedToQuerySMSCode = true
                }
            case .failure(_):
                    DispatchQueue.main.async { [weak self] in
                        self?.isAllowedToQuerySMSCode = true
                    }
                    
                    self.didGetError?("Что-то пошло не так")
            }
        }
    }
    
}

extension ConfirmPhoneNumberViewModel: ConfirmPhoneNumberViewModeling {
    var tittle: String {
        type.rawValue
    }
    
    var phone: String {
        PhoneNumberManager.shared.formatPhoneNumber(phoneNumber)
    }
    
    func confirmRegistration(with code: String?) {
        guard let code = code else {
            didGetSmsCodeError?("Пожалуйста, введите код")
            return
        }
        isLoading = true
        ShoppingListService.shared.confirmRegistration(withCode: code) { [weak self] (result) in
            self?.isLoading = false
            switch result {
                case .success(let response):
                    guard let response = response else {
                        return
                    }
                    CurrentUserManager.shared.setUser(fromUserResponse: response.user)
                    CurrentUserManager.shared.userToken = response.access_token
                    print("successfull registration")
                    self?.didConfirmCode?()
                case .failure(let error):
                    switch error {
                        case .server(let serverError):
                            self?.processServerError(serverError)
                        case .parsing(_): //TBD
                            break
                        case .network(_):
                            self?.didGetError?("Нет соединения с сервером")
                }
            }
            
        }
    }
    
    func queryCodeAgain() {
        guard let phoneNumber = Int(phoneNumber.decimalString) else {
            return
        }
        isAllowedToQuerySMSCode = false
        
        isLoading = true
        ShoppingListService.shared.login(phone: phoneNumber) { [weak self] (result) in
            self?.isLoading = false
            switch result {
                case .success(_):
                    return
                case .failure(let error):
                    switch error {
                        case .server(let error):
                            self?.processQueryCodeAgainServerError(error)
                        case .parsing(_):
                            DispatchQueue.main.async { [weak self] in
                                self?.isAllowedToQuerySMSCode = true
                        }
                        case .network(_):
                            DispatchQueue.main.async { [weak self] in
                                self?.isAllowedToQuerySMSCode = true
                            }
                            self?.didGetError?("Нет соединения с сервером")
                }
            }
        }
    }
    
}
