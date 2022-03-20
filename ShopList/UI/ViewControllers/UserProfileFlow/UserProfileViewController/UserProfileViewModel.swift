import Foundation

//MARK: General

class UserProfileViewModel: BaseViewModel {
    
    private var currentUser: Emitter<CurrentUserModel?>? = CurrentUserManager.shared.currentUser
    
    var currentUserSubscriptionToken: SignalSubscriptionToken? = nil
    var isRatingUpdated = false
    var currentRating: Int {
        get {
            UserDefaults.standard.integer(forKey: "userRating")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "userRating")
        }
    }

    
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

extension UserProfileViewModel: UserProfileViewModeling {
    
    var phoneNumber: String {
        guard let phoneNumber = currentUser?.value?.phone else {
            return "Не указан"
        }
        return PhoneNumberManager.shared.formatPhoneNumber(phoneNumber)
    }
    
    var userName: String {
        currentUser?.value?.name ?? "Не указано"
    }
    
    var shareMessage: String {
        """
    Вас пригласили в приложение \"Список покупок - Shopping List\". Для совместного редактирования списков покупок скачайте приложение:
    в AppStore:
    https://itunes.apple.com/app/id1530377058
    или в GooglePlay:
    https://play.google.com/store/apps/details?id=com.globus.shoppinglist
    """
    }
    
}
