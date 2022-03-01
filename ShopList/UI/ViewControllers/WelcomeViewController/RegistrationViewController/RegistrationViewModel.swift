import Foundation

class RegistrationViewModel: BaseViewModel {
    
    var agreementApproved: Bool = true {
        didSet {
            didChange?()
        }
    }
    var username: String? {
        didSet {
            didChange?()
        }
    }
    var phone: String? {
        didSet {
            didChange?()
        }
    }
    
    var didSuccessfullyRegistered: (() -> Void)?
    var didGetPhoneError: ((String) -> Void)?
    var didGetUserError: ((String) -> Void)?
    
    private func processServerError(_ error: ShoppingListServerError.BackendError) {
        switch error.code {
            case 6:
                didGetPhoneError?("Пользователь с таким номером телефона уже существует")
            default:
                didGetError?("Что-то пошло не так")
        }
    }
}

extension RegistrationViewModel: RegistrationViewModeling {
    
    var isRegistrationAvailable: Bool {
        (username?.isEmpty ?? true == false) && (7...15 ~= phone?.count ?? 0) && (agreementApproved)
    }
    
    var phoneNumberPrefix: String {
        PhoneNumberManager.shared.defaultRegionPrefix
    }
    
    func register() {
        guard let username = username, username.isEmpty == false else {
            didGetUserError?("Пожалуйста, введите Ваше имя")
            return
        }
        guard username.count >= 2 else {
            didGetUserError?("Имя должно состоять как минимум из двух символов")
            return
        }
        guard username.rangeOfCharacter(from: CharacterSet(charactersIn: ";:.,`()'#'@!?$%^&*-_+=№\"~₽/{}[]<>€£•")) == nil else {
            didGetUserError?("Имя не должно содержать специальных символов и знаков препинания")
            return
        }
        guard let phone = phone, phone.isEmpty == false, let phoneNum = Int(phone) else {
            didGetPhoneError?("Пожалуйста, введите номер телефона")
            return
        }
        
        let userRegisterObject = UserRegisterObject(username: username,
                                                    phone: phoneNum,
                                                    email: nil)
        
        isLoading = true
        ShoppingListService.shared.createUser(userRegisterObject) { [weak self] (result) in
            switch result {
                case .success(let response):
//                    CurrentUserManager.shared.setUser(fromUserResponse: userResponse)
                    if let id = response?.id {
                        CurrentUserManager.shared.userIdentifier = id
                    }
                    self?.didSuccessfullyRegistered?()
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
            
            self?.isLoading = false
        }
    }
}
