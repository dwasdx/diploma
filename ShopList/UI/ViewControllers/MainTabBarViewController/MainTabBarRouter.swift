import UIKit

class MainTabBarRouter: BaseRouter {
    
    weak var mainTabBarViewController: MainTabBarViewController?
    
//    var notificationsFlowRouter: NotificationsFlowRouting!
    var shoppingListFlowRouter: ShoppingListFlowRouting!
    var userProfileFlowRouter: UserProfileFlowRouting!
//    var templateListFlowRouter: TemplateListFlowRouting!
    
    init(with mainTabBarViewController: MainTabBarViewController) {
        self.mainTabBarViewController = mainTabBarViewController
        
        super.init()
        
//        self.notificationsFlowRouter = NotificationsFlowRouter(with: self)
        self.shoppingListFlowRouter = ShoppingListFlowRouter(with: self)
        self.userProfileFlowRouter = UserProfileFlowRouter(with: self)
//        self.templateListFlowRouter = TemplateListFlowRouter(with: self)
    }
    
}

extension MainTabBarRouter: PushNotificationsRouting {
    
    private func presentHomePage(_ completion: (() -> Void)?) {
        switch mainTabBarViewController?.selectedIndex {
        case 0:
            shoppingListFlowRouter.presentHomePage(completion)
        case 1:
            userProfileFlowRouter.presentHomePage(completion)
        default:
            return
        }
    }
    
    func presentShoppingListsViewController(_ completion: (() -> Void)?) {
        presentHomePage() {
            // 0 - index of shoppping lists view controller
            self.mainTabBarViewController?.selectedIndex = 0
            self.shoppingListFlowRouter.presentShoppingListViewController(completion)
        }
    }
    
    func presentProductsViewController(with listId: String, _ completion: (() -> Void)?) {
        presentHomePage() {
            // 0 - index of shoppping lists view controller
            self.mainTabBarViewController?.selectedIndex = 0
            self.shoppingListFlowRouter.presentProductsViewController(with: listId, completion)
        }
    }
    
    
}

extension MainTabBarRouter: MainTabBarRouting {

    func presentWelcomeFlowRouter(_ completion: (() -> Void)?) {

        let welcomeVC = WelcomeViewController.initFromItsStoryboard()
        let router = WelcomeFlowRouter(initialViewController: welcomeVC)
        router.delegate = self
        welcomeVC.router = router
        welcomeVC.modalPresentationStyle = .overFullScreen
        mainTabBarViewController?.present(welcomeVC, animated: false) {
//            self.notificationsFlowRouter.dissmiss(nil)
            self.shoppingListFlowRouter.dissmiss(nil)
//            self.templateListFlowRouter.dissmiss(nil)
            self.userProfileFlowRouter.dissmiss(nil)
        }

    }
    
    func reset() {
//        notificationsFlowRouter.presentNotificationsViewController(nil)
        userProfileFlowRouter.presentUserProfileViewController(nil)
//        templateListFlowRouter.presentTemplateListViewController(nil)
        shoppingListFlowRouter.presentShoppingListViewController(nil)
        mainTabBarViewController?.selectedIndex = 0
    }
    
}

extension MainTabBarRouter: WelcomeFlowRouterDelegate {
    func dissmissWelcomeFlow() {
        reset()
    }
}

