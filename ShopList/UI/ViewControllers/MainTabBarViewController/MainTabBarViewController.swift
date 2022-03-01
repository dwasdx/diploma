import UIKit

public protocol MainTabBarRouting: AnyObject, BaseRouting, PushNotificationsRouting {
    
    func reset()
    func presentWelcomeFlowRouter(_ completion: (() -> Void)?)
    
//    var notificationsFlowRouter: NotificationsFlowRouting! { get }
    var shoppingListFlowRouter: ShoppingListFlowRouting! { get }
    var userProfileFlowRouter: UserProfileFlowRouting! { get }
//    var templateListFlowRouter: TemplateListFlowRouting! { get }
}

protocol MainTabBarViewModeling: BaseViewModeling {
    var hasUnreadNotifications: Bool { get }
    var presentShoppingListViewController: (() -> Void)? { get set }
    var presentProductsListViewController: ((_ listId: String) -> Void)? { get set }
}

class MainTabBarViewController: UITabBarController {
    
    lazy var router: MainTabBarRouting = {
        MainTabBarRouter(with: self)
    }()
    
    var viewModel: MainTabBarViewModeling = MainTabBarViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.didChange = { [weak self] in
            DispatchQueue.main.async {
//                self?.update()
            }
        }
        viewModel.presentShoppingListViewController = { [weak self] in
            DispatchQueue.main.async { [weak self] in
                self?.router.presentShoppingListsViewController(nil)
            }
        }
        viewModel.presentProductsListViewController = { [weak self] listId in
            DispatchQueue.main.async { [weak self] in
                self?.router.presentProductsViewController(with: listId, nil)
            }
        }
        
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if CurrentUserManager.shared.isLoggedIn.value {
            router.reset()
        } else {
            router.presentWelcomeFlowRouter(nil)
        }
    }
    
    func setup() {
        let shoppingListNVC = router.shoppingListFlowRouter.navigationController
        shoppingListNVC.tabBarItem.title = "Списки покупок"
        shoppingListNVC.tabBarItem.image = UIImage(named: "shopping-bag.tabbar.grey")?.withRenderingMode(.alwaysTemplate)
        
        let profileNVC = router.userProfileFlowRouter.navigationController
        profileNVC.tabBarItem.title = "Профиль"
        profileNVC.tabBarItem.image = UIImage(named: "user.tabbar.grey")?.withRenderingMode(.alwaysTemplate)
        
        tabBar.tintColor = .shoppingListOrange
//        shoppingListNVC.additionalSafeAreaInsets = UIEdgeInsets(top: 0,
//                                                                left: 0,
//                                                                bottom: abs(topContainerBottomContentDistance),
//                                                                right: 0)
        viewControllers = [
            shoppingListNVC,
//            router.templateListFlowRouter.navigationController,
            
//            router.notificationsFlowRouter.navigationController
        ]
        
    }
    
//    private func update() {
//        updateNotificationsButton()
//    }
//
//    private func updateNotificationsButton() {
//
//        //Сhecking that the notificationsViewController is not represented
//        if selectedIndex != 2 && viewModel.hasUnreadNotifications {
////            notificationsImageView.image = UIImage(named: "bell.notifications.grey")
//        }
//
//    }
    
}

