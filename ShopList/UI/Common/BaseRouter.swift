import UIKit

public protocol PushNotificationsRouting {
    func presentShoppingListsViewController(_ completion: (() -> Void)?)
    func presentProductsViewController(with listId: String, _ completion: (() -> Void)?)
}

public protocol BaseRouting {
//    
//    func presentRegistrationViewController(_ completion: (() -> Void)?)
//    func presentSignInViewController(_ completion: (() -> Void)?)
//    
//    func presentPleaseRegisterViewController(_ completion: (() -> Void)?)
    
    var navigationController: UINavigationController { get }
}

public class BaseRouter {
    
    public let navigationController: UINavigationController
    
    init() {
        let nvc = UINavigationController()
        nvc.navigationBar.isHidden = true
        nvc.modalPresentationStyle = .fullScreen
        //disable pop swipe from left to right
        nvc.interactivePopGestureRecognizer?.isEnabled = false
        
        self.navigationController = nvc
    }
}

extension BaseRouter: BaseRouting {
    
//    public func presentRegistrationViewController(_ completion: (() -> Void)?) {
//        tabBarRouter.presentRegistrationViewController(completion)
//    }
//
//    public func presentSignInViewController(_ completion: (() -> Void)?) {
//        tabBarRouter.presentSignInViewController(completion)
//    }
    
    public func presentPleaseRegisterViewController(_ completion: (() -> Void)?) {
        if (navigationController.viewControllers.last?.presentedViewController) != nil {
            return
        }
        
//        let vc = PleaseRegisterViewController()
//        vc.router = self
//        vc.viewModel = PleaseRegisterViewModel()
//        vc.modalPresentationStyle = .overCurrentContext
        let vc = BaseViewController()
        
        // Will not work with navigationController?.pushViewController
        // navigationController?.definesPresentationContext = true
        // navigationController?.pushViewController(vc, animated: true)
        let currentVC = navigationController.viewControllers.last!
        currentVC.definesPresentationContext = true
        currentVC.present(vc, animated: true, completion: completion)
    }
}

//extension BaseRouter: PleaseRegisterRouting {
//
//    public func didFinishPleaseRegister(_ completion: (() -> Void)?) {
//        let currentVC = navigationController.viewControllers.last!
//        currentVC.presentedViewController?.dismiss(animated: true, completion: completion)
//    }
//
//}
