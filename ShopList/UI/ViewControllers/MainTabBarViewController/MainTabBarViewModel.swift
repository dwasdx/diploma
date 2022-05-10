import Foundation

class MainTabBarViewModel: BaseViewModel {
    
    var hasUnreadNotifications = false {
        didSet {
            didChange?()
        }
    }
    var presentShoppingListViewController: (() -> Void)?
    var presentProductsListViewController: ((_ listId: String) -> Void)?
    
    private var unreadNotificationStateChangesToken: SignalSubscriptionToken?
    
    let userManager: CurrentUserManaging
    let syncService: SynchronizationServiceable
    
    init(
        userManager: CurrentUserManaging = CurrentUserManager.shared,
        syncService: SynchronizationServiceable = SynchronizationService.shared
    ) {
        self.userManager = userManager
        self.syncService = syncService
        super.init()
        
    }
}

extension MainTabBarViewModel: MainTabBarViewModeling {
    
}

