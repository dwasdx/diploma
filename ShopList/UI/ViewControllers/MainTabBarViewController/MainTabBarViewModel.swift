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
        
        NotificationCenter.default.addObserver(self, selector: #selector(userDidTapNotification(_:)), name: .userDidTapNotification, object: nil)
    }
    
    @objc private func userDidTapNotification(_ notification: NSNotification?) {
        guard let object = notification?.object as? PushNotificationCenter.UserTappedNotificationObject else {
            return
        }
        switch object.type {
            case 1...3, 7, 8:
                presentShoppingListViewController?()
            case 4...6:
                guard let token = userManager.userToken else {
                    return
                }
                syncService.synchronize(token: token, fullUpdate: false) { (error) in
                    if let error = error {
                        print("Sync error: \(error.localizedDescription)")
                        return
                    }
                    self.presentProductsListViewController?(object.listId)
                }
            default:
                break
        }
    }
}

extension MainTabBarViewModel: MainTabBarViewModeling {
    
}

