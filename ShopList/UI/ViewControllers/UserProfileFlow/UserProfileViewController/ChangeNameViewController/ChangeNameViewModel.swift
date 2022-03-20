import Foundation

//MARK: General

class ChangeNameViewModel: BaseViewModel {
    
    var didGetNameError: ((String) -> Void)?
    
    var newName: String? {
        didSet {
            didChange?()
        }
    }
    
    var currentUser: Emitter<CurrentUserModel?>? = CurrentUserManager.shared.currentUser
    var currentUserSubscriptionToken: SignalSubscriptionToken? = nil
    
    override init() {
        super.init()
        self.currentUserSubscriptionToken = self.currentUser?.signal.addListener { [weak self] (currentUser) in
            print(self?.currentUser?.value as Any)
            print(currentUser as Any)
            self?.didChange?()
        }
    }
    
    deinit {
        self.currentUser?.signal.removeListener(currentUserSubscriptionToken)
    }
    
}

extension ChangeNameViewModel: ChangeNameViewModeling {
    
    var isAllowedToChangeName: Bool {
        newName?.count ?? 0 >= 2
    }
    
    func updateUserName(_ completion: ((Error?) -> Void)?) {
        guard let newName = newName, newName != "" else {
            didGetNameError?("Пожалуйста, введите Ваше имя")
            return
        }
        
        guard newName.count >= 2 else {
            didGetNameError?("Имя должно состоять как минимум из двух символов")
            return
        }
        
        guard newName.rangeOfCharacter(from: CharacterSet(charactersIn: ";:.,`()'#'@!?$%^&*-_+=№\"~₽/{}[]<>€£•")) == nil else {
            didGetNameError?("Имя не должно содержать специальных символов и знаков препинания")
            return
        }
        
        CurrentUserManager.shared.changeName(newName: newName)
        completion?(nil)
    }
    
}
