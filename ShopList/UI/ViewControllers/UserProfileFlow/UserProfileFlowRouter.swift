import UIKit

public protocol UserProfileFlowRouting: BaseRouting {
    func presentUserProfileViewController(_ completion: (()->Void)?)
    func presentHomePage(_ completion: (() -> Void)?)
    func dissmiss(_ completion: (() -> Void)?)
}

class UserProfileFlowRouter: BaseRouter {
    
    weak var mainTabBarRouter: MainTabBarRouting?
    
    init(with mainTabBarRouter: MainTabBarRouting) {
        self.mainTabBarRouter = mainTabBarRouter
        
        super.init()
    }
}

extension UserProfileFlowRouter: UserProfileFlowRouting {
    
    func presentUserProfileViewController(_ completion: (() -> Void)? = nil) {
        if let presentedRVC = navigationController.viewControllers.filter({ $0 is UserProfileViewController}).first {
            navigationController.popToViewController(presentedRVC, animated: true, completion)
        } else {
            let vc = UserProfileViewController.initFromItsStoryboard()
            vc.viewModel = UserProfileViewModel()
            vc.router = self
            
            navigationController.viewControllers.removeAll()
            if navigationController.viewControllers.count == 0 {
                navigationController.viewControllers.append(vc)
            } else {
                navigationController.pushViewController(vc, animated: true, completion)
            }
            
            navigationController.modalPresentationStyle = .overCurrentContext
            //initialViewController.present(navigationController, animated: false, completion: completion)
        }
    }
    
    func presentHomePage(_ completion: (() -> Void)?) {
        
        if let presentedViewController = navigationController.viewControllers.last?.presentedViewController  {
            presentedViewController.dismiss(animated: false) {
                self.presentHomePage(completion)
            }
        } else {
            guard let userProfileVC = self.navigationController.viewControllers.first(where: { $0 is UserProfileViewController }) as? UserProfileViewController else {
                return
            }
            self.navigationController.popToViewController(userProfileVC, animated: true, completion)
        }
        
    }
    
    func dissmiss(_ completion: (() -> Void)?) {
        let cleanVC = CleanViewController.initFromItsStoryboard()
        navigationController.setViewControllers([cleanVC], animated: false)
    }
}

//MARK: UserProfileRouting

extension UserProfileFlowRouter: UserProfileViewControllerRouting {
        
    func presentChangeNameViewController(_ completion: (() -> Void)?) {
        let vc = ChangeNameViewController.initFromItsStoryboard()
        vc.viewModel = ChangeNameViewModel()
        vc.router = self
        vc.modalPresentationStyle = .overFullScreen
        let currentVC = navigationController.viewControllers.last!
        //currentVC.definesPresentationContext = true
        currentVC.present(vc, animated: false, completion: completion)
    }
    
    func presentConfirmLogOutViewController(_ completion: (() -> Void)?) {
        let currentVC = navigationController.viewControllers.last!
        let vc = LogOutConfirmationViewController.initFromItsStoryboard()
        vc.viewModel = LogOutConfirmationViewModel()
        vc.router = self
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        currentVC.present(vc, animated: true, completion: completion)
    }
    
    func presentRateAppViewController(rating: Int, _ completion: (() -> Void)?) {
        let vc = RateAppViewController.initFromItsStoryboard()
        vc.router = self
        vc.viewModel = RateAppViewModel(rating: rating)
        vc.modalPresentationStyle = .overFullScreen
        let currentVC = navigationController.viewControllers.last
        currentVC?.present(vc, animated: false, completion: completion)
    }
}

//MARK: ChangeNameRouting

extension UserProfileFlowRouter: ChangeUserNameRouting {
    
    func dismissChangeNameViewController(_ completion: (() -> Void)?) {
        guard let presentedViewController = navigationController.viewControllers.last?.presentedViewController else {
            return
        }
        if presentedViewController is ChangeNameViewController {
            presentedViewController.dismiss(animated: false, completion: completion )
        }
    }
    
    private func presentApprovedNameViewController() {
        let vc = ApprovedViewController.initFromItsStoryboard()
        vc.viewModel = ApprovedNameViewModel()
        vc.router = self
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        let currentVC = self.navigationController.viewControllers.last!
        currentVC.present(vc, animated: true, completion: nil)
    }
    
    func presentApprovedNameViewController(_ completion: (() -> Void)?) {
        dismissChangeNameViewController {
            self.presentApprovedNameViewController()
        }
    }
}

//MARK: ApprovedViewRouting

extension UserProfileFlowRouter: ApprovedViewRouting {
    func dissmissApprovedViewController(_ completion: (() -> Void)?) {
        guard let presentedViewController = navigationController.viewControllers.last?.presentedViewController else {
            return
        }
        if presentedViewController is ApprovedViewController {
            presentedViewController.dismiss(animated: true, completion: completion)
        }
    }
    
}

//MARK: LogOutConfirmationRouting

extension UserProfileFlowRouter: LogOutConfirmationRouting {
    
    func navigateBack(_ completion: (() -> Void)?) {
        if let presentedViewController = navigationController.viewControllers.last?.presentedViewController {
            let animated = presentedViewController is SwipeableViewController == false
            presentedViewController.dismiss(animated: animated, completion: completion)
            return
        }
        navigationController.popViewController(animated: true, completion)
    }
    
    func presentWelcomeViewController(_ completion: (() -> Void)?) {
        if let presentedVC = navigationController.presentedViewController {
            presentedVC.dismiss(animated: false) {
                self.mainTabBarRouter?.presentWelcomeFlowRouter(nil)
            }
        }
    }
    
}

extension UserProfileFlowRouter: RateAppViewControllerRouting {
    
}
