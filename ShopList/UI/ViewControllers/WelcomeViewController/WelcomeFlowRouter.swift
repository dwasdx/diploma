import UIKit

protocol WelcomeFlowRouterDelegate: AnyObject {
    func dissmissWelcomeFlow()
}

class WelcomeFlowRouter: BaseRouter {
    
    weak var initialViewController: UIViewController?
    weak var delegate: WelcomeFlowRouterDelegate?
    
    init(initialViewController: UIViewController) {
        self.initialViewController = initialViewController
        
        super.init()
        
        navigationController.view.backgroundColor = nil
        navigationController.interactivePopGestureRecognizer?.isEnabled = false
    }
    
}

extension WelcomeFlowRouter: WelcomeViewControllerRouting {
    
    func presentSignInViewController(_ completion: (() -> Void)?) {
        if let presentedRVC = navigationController.viewControllers.filter({ $0 is SignInViewController}).first {
            navigationController.popToViewController(presentedRVC, animated: true)
        } else {
            let vc = SignInViewController.initFromItsStoryboard()
            vc.router = self
            vc.viewModel = SignInViewModel()
            vc.modalPresentationStyle = .custom
            navigationController.modalPresentationStyle = .custom
            
            navigationController.viewControllers.removeAll()
            if navigationController.viewControllers.count == 0 {
                navigationController.viewControllers.append(vc)
            } else {
                navigationController.pushViewController(vc, animated: false)
            }
            
            guard (initialViewController?.presentedViewController != navigationController) else {
                return
            }
            initialViewController?.present(navigationController, animated: false, completion: completion)
        }
    }
    
    func presentRegisterationViewController(_ completion: (() -> Void)?) {
        
        if let presentedRVC = navigationController.viewControllers.filter({ $0 is RegistrationViewController}).first {
            navigationController.popToViewController(presentedRVC, animated: true)
        } else {
            
            let vc = RegistrationViewController.initFromItsStoryboard()
            vc.viewModel = RegistrationViewModel()
            vc.router = self
            vc.modalPresentationStyle = .custom
            navigationController.modalPresentationStyle = .custom
            
            navigationController.viewControllers.removeAll()
            if navigationController.viewControllers.count == 0 {
                navigationController.viewControllers.append(vc)
            } else {
                navigationController.pushViewController(vc, animated: false)
            }
            
            guard (initialViewController?.presentedViewController != navigationController) else {
                return
            }
            initialViewController?.present(navigationController, animated: false, completion: completion)
        }
    }
    
}

extension WelcomeFlowRouter: SignInViewControllerRouting {
    
}

extension WelcomeFlowRouter: RegistrationViewControllerRouting {
    
    func presentConfirmRegistrationViewController(phoneNumber: String, _ completion: (() -> Void)?) {
        if let presentedRVC = navigationController.viewControllers.filter({ $0 is ConfirmPhoneNumberViewController}).first {
            navigationController.popToViewController(presentedRVC, animated: true)
        } else {
            let vc = ConfirmPhoneNumberViewController.initFromItsStoryboard()
            vc.router = self
            vc.modalPresentationStyle = .custom
            vc.viewModel = ConfirmPhoneNumberViewModel(phoneNumber, type: .registration)
            navigationController.modalPresentationStyle = .custom
            
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    func presentConfidentialityAgreementViewController(_ completion: (() -> Void)?) {
        guard let registrationViewController = navigationController.viewControllers.first(where: { $0 is RegistrationViewController }) as? RegistrationViewController else {
            return
        }
        
        let vc = ConfidentialityAgreementViewController.initFromItsStoryboard()
        vc.viewModel = ConfidentialityAgreementViewModel()
        vc.router = self
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        registrationViewController.present(vc, animated: true, completion: completion)
    }
    
}

extension WelcomeFlowRouter: ConfidentialityAgreementRouting {
    func navigateBackToRegistraion(_ completion: (() -> Void)?) {
        guard let registrationVC = navigationController.viewControllers.first(where: { $0 is RegistrationViewController }) as? RegistrationViewController else {
            return
        }
        registrationVC.presentedViewController?.dismiss(animated: true, completion: completion)
    }
    
    
}

extension WelcomeFlowRouter: ConfirmPhoneNumberViewControllerRouting {
    
    func navigateBack(_ completion: (() -> Void)?) {
        if !navigationController.viewControllers.isEmpty {
            navigationController.popViewController(animated: true)
            completion?()
        }
    }
    
    func presentTabBarViewController(_ completion: (() -> Void)?) {
        initialViewController?.presentedViewController?.dismiss(animated: true, completion: {
            self.initialViewController?.dismiss(animated: true, completion: {
                self.delegate?.dissmissWelcomeFlow()
                self.navigationController.viewControllers.removeAll()
            })
        })
    }
}


extension WelcomeFlowRouter: PushNotificationsRouting {
    
    func presentShoppingListsViewController(_ completion: (() -> Void)?) {
        return
    }
    
    func presentProductsViewController(with listId: String, _ completion: (() -> Void)?) {
        return
    }
    
    func presentConfirmPhoneViewController(_ phoneNumber: String, completion: (() -> Void)?) {
        if let presentedVC = navigationController.viewControllers.first(where: { $0 is ConfirmPhoneNumberViewController }) {
            navigationController.popToViewController(presentedVC, animated: true)
        } else {
            let vc = ConfirmPhoneNumberViewController.initFromItsStoryboard()
            vc.router = self
            vc.viewModel = ConfirmPhoneNumberViewModel(phoneNumber, type: .login)
            
            navigationController.modalPresentationStyle = .custom
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    func dismissSignInViewController(_ completion: (() -> Void)?) {
        initialViewController?.dismiss(animated: true) {
            self.navigationController.viewControllers.removeAll()
            completion?()
        }
    }
    
}
