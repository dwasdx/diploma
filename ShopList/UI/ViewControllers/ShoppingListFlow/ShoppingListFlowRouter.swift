import Foundation

public protocol ShoppingListFlowRouting: BaseRouting {
    func presentShoppingListViewController(_ completion: (()->Void)?)
    func presentProductsViewController(with listId: String, _ completion: (()->Void)?)
    func presentHomePage(_ completion: (() -> Void)?)
    func dissmiss(_ completion: (() -> Void)?)
}

class ShoppingListFlowRouter: BaseRouter {
    
    weak var mainTabBarRouter: MainTabBarRouting?
    
    init(with mainTabBarRouter: MainTabBarRouting) {
        self.mainTabBarRouter = mainTabBarRouter
        
        super.init()
    }
}

//MARK: ShoppingListFlowRouting

extension ShoppingListFlowRouter: IFlowRouterType {}

extension ShoppingListFlowRouter: ShoppingListFlowRouting {
    
    func presentProductsViewController(with listId: String, _ completion: (() -> Void)?) {
        if let presentedRVC = navigationController.viewControllers.filter({ $0 is ShoppingListViewController}).first {
            navigationController.popToViewController(presentedRVC, animated: true, completion)
        }
        let childRouter = ProductsListFlowRouter(with: self)
        
        guard let shoppingListEntity = CoreDataService.shared.getEntity(entity: .shoppingList(), id: listId, contextType: .view) as? ShoppingListEntity else {
            return
        }
        let shoppingListModel = ShoppingListModel(shoppingListEntity: shoppingListEntity)
        
        childRouter.initialViewController.viewModel = ProductsListViewModel(withListModel: shoppingListModel)
        navigationController.pushViewController(childRouter.initialViewController, animated: true, completion)
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    
    func presentShoppingListViewController(_ completion: (() -> Void)? = nil) {
        if let presentedRVC = navigationController.viewControllers.filter({ $0 is ShoppingListViewController}).first {
            navigationController.popToViewController(presentedRVC, animated: true, completion)
        } else {
            let vc = ShoppingListViewController.initFromItsStoryboard()
            vc.viewModel = ShoppingListViewModel()
            vc.router = self
//            vc.modalPresentationStyle = .fullScreen
            
            navigationController.viewControllers.removeAll()
            if navigationController.viewControllers.count == 0 {
                navigationController.viewControllers.append(vc)
            } else {
                navigationController.pushViewController(vc, animated: true, completion)
            }
        }
    }
    
    func presentHomePage(_ completion: (() -> Void)?) {
        
        if let presentedViewController = navigationController.viewControllers.last?.presentedViewController  {
            presentedViewController.dismiss(animated: false) {
                self.presentHomePage(completion)
            }
        } else {
            guard let shoppingListVC = self.navigationController.viewControllers.first(where: { $0 is ShoppingListViewController }) as? ShoppingListViewController else {
                return
            }
            self.navigationController.popToViewController(shoppingListVC, animated: true, completion)
        }
        
    }
    
    func dissmiss(_ completion: (() -> Void)?) {
        let cleanVC = CleanViewController.initFromItsStoryboard()
        navigationController.setViewControllers([cleanVC], animated: false)
    }
}

//MARK: ShoppingListViewControllerRouting

extension ShoppingListFlowRouter: ShoppingListViewControllerRouting {
    
    func presentCreateShoppingListViewController(_ completion: (() -> Void)?) {
        guard let shoppingListVC = navigationController.viewControllers.first(where: { $0 is ShoppingListViewController }) as? ShoppingListViewController else {
            return
        }
        
        let vc = CreateShoppingListViewController.initFromItsStoryboard()
        vc.viewModel = CreateShoppingListViewModel()
        vc.router = self
        vc.modalPresentationStyle = .custom
        shoppingListVC.present(vc, animated: false, completion: completion)
    }
    
    func presentConfirmDeleteViewController(with model: ShoppingListModel, onIndexPath indexPath: IndexPath, _ completion: (() -> Void)?) {
        guard let shoppingListVC = navigationController.viewControllers.first(where: { $0 is ShoppingListViewController }) as? ShoppingListViewController else {
            return
        }
        
        let vc = DeleteShoppingListConfirmationViewController.initFromItsStoryboard()
        vc.viewModel = DeleteShoppingListViewModel(model: model, indexPath: indexPath, parentViewModel: shoppingListVC.viewModel)
        vc.router = self
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        shoppingListVC.present(vc, animated: true, completion: completion)
    }
    
    func presentProductsListViewController(with model: ShoppingListModel, _ completion: (() -> Void)?) {
        let childRouter = ProductsListFlowRouter(with: self)
        childRouter.initialViewController.viewModel = ProductsListViewModel(withListModel: model)
        navigationController.pushViewController(childRouter.initialViewController, animated: true, completion)
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
    }
}

//MARK: CreateShoppingListViewControllerRouting

extension ShoppingListFlowRouter: CreateShoppingListViewControllerRouting {
}

//MARK: DeleteShoppingListConfirmationRouting

extension ShoppingListFlowRouter: DeleteShoppingListConfirmationRouting {
    func navigateBack(_ completion: (() -> Void)?) {
        guard let shoppingListVC = navigationController.viewControllers.first(where: { $0 is ShoppingListViewController }) as? ShoppingListViewController else {
            return
        }
        shoppingListVC.presentedViewController?.dismiss(animated: true, completion: completion)
    }
}
