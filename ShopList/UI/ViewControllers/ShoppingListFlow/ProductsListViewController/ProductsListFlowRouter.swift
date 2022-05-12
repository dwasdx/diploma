//
//  ProductsListFlowRouter.swift
//  ShoppingList
//
//  Created by Андрей Журавлев on 08.06.2020.
//  Copyright © 2020 Dmitry Lemaykin. All rights reserved.
//

import UIKit

protocol IFlowRouterType {}

enum ListActionTittle {
    case share
    case rename
    case addToShoppingList
    case addParticipant
    
    var description: String {
        switch self {
        case .addToShoppingList:
            return "Добавить в список покупок"
        case .rename:
            return "Переименовать список"
        case .share:
            return "Поделиться списком"
        case .addParticipant:
            return "Добавить участников"
        }
    }
}


class ProductsListFlowRouter<T: BaseRouter>: BaseRouter  {
    let parentRouter: T
    let parentNavigationController: UINavigationController
    weak var initialViewController: ProductsListViewController!
    
    init(with parentRouter: T  ) {
        self.parentRouter = parentRouter
        self.parentNavigationController = parentRouter.navigationController
        super.init()
        let vc = ProductsListViewController.initFromItsStoryboard()
        vc.router = self
        self.initialViewController = vc
    }
}

extension ProductsListFlowRouter: ProductsListViewControllerRouting {
    
    func presentAddNewProductViewController(_ completion: (() -> Void)?) {
        let vc = AddNewProductViewController.initFromItsStoryboard()
        vc.router = self
        vc.viewModel = AddNewProductViewModel(initialViewController.viewModel.listId)
        vc.modalPresentationStyle = .custom
        initialViewController.present(vc, animated: false, completion: completion)
    }
    
    func presentConfirmDeleteViewController(with model: ProductModel, onIndexPath indexPath: IndexPath, _ completion: (() -> Void)?) {
        let vc = DeleteProductConfirmationViewController.initFromItsStoryboard()
        vc.viewModel = DeleteProductViewModel(product: model, indexPath: indexPath, didCancelModelDelete: initialViewController.viewModel.didCancelModelDelete)
        vc.router = self
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        initialViewController.present(vc, animated: true, completion: completion)
    }
    
    func presentChangeValueViewController(indexPath: IndexPath, _ completion: (() -> Void)?) {
        let vc = ChangeValueViewController.initFromItsStoryboard()
        vc.router = self
        vc.viewModel = ChangeValueViewModel(parentViewModel: initialViewController.viewModel, indexPath: indexPath)
        vc.modalPresentationStyle = .custom
        initialViewController.present(vc, animated: false, completion: completion)
    }
    
    func presentUncheckAllViewController(confirmHandler: (() -> Void)?, _ completion: (() -> Void)?) {
        let ac = UIAlertController(title: "Внимание",
                                   message: "Вы хотите достать все товары из корзины?",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Достать",
                                   style: .destructive,
                                   handler: { _ in
            confirmHandler?()
        }))
        initialViewController.present(ac, animated: true, completion: completion)
    }
    
    func presentListActionsViewController(productsListViewModel: ProductsListViewModeling, _ completion: (() -> Void)?) {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.view.tintColor = .shoppingListBlue
        ac.addAction(UIAlertAction(title: ListActionTittle.rename.description,
                                   style: .default,
                                   handler: { _ in
            self.presentChangeNameListViewController(productsListViewModel: productsListViewModel, nil)
        }))
        ac.addAction(UIAlertAction(title: ListActionTittle.addParticipant.description,
                                   style: .default,
                                   handler: { _ in
            self.presenListMembersViewController(listId: productsListViewModel.listId, nil)
        }))
        ac.addAction(UIAlertAction(title: ListActionTittle.share.description, style: .default, handler: { _ in
            self.presentShareViewController(nil)
        }))
        ac.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        initialViewController.present(ac, animated: true, completion: completion)
    }
    
}

extension ProductsListFlowRouter: DeleteProductConfirmationViewControllerRouting {
    func presentProductsListViewController(_ completion: (() -> Void)?) {
        if let vc = initialViewController.presentedViewController {
            vc.dismiss(animated: true, completion: completion)
            return
        }
    }
}

extension ProductsListFlowRouter: AddNewProductViewControllerRouting {
    
}

extension ProductsListFlowRouter: ChangeValueViewControllerRouting {
    
}

extension ProductsListFlowRouter: ContactsViewControllerRouting {
    func presentShareAppViewController(shareAppDelegate: AddNewContactDelegate, _ completion: (() -> Void)?) {
        let vc = ShareAppViewController.initFromItsStoryboard()
        vc.delegate = shareAppDelegate
        vc.viewModel = ShareAppViewModel()
        vc.router = self
        vc.modalPresentationStyle = .custom
        vc.modalTransitionStyle = .crossDissolve
        initialViewController.present(vc, animated: true, completion: completion)
    }
    
    func navigateBack(animated: Bool = true, _ completion: (() -> Void)?) {
        guard let topVC = parentNavigationController.topViewController else {
            return
        }
        if let presentedVC = topVC.presentedViewController {
            presentedVC.dismiss(animated: animated, completion: completion)
            return
        }
        parentNavigationController.popViewController(animated: animated, completion)
    }
}

extension ProductsListFlowRouter: ListMembersViewControllerRouting {
    func presentContactsViewController(listId: String, completion: (() -> Void)?) {
        if let presentedVC = parentNavigationController.viewControllers.first(where: { $0 is ContactsViewController }) {
            parentNavigationController.popToViewController(presentedVC, animated: true, completion)
            return
        }
        let vc = ContactsViewController.initFromItsStoryboard()
        vc.router = self
        vc.viewModel = ContactsViewModel(listId: listId)
        parentNavigationController.pushViewController(vc, animated: true, completion)
    }
    
}

extension ProductsListFlowRouter: ShareAppRouting {
    
}

extension ProductsListFlowRouter {
    
    func presentChangeNameListViewController(productsListViewModel: ProductsListViewModeling, _ completion: (() -> Void)?) {
        
        let vc = ChangeNameShoppingListViewController.initFromItsStoryboard()
        vc.viewModel = ChangeNameListViewModel(productsListViewModel: productsListViewModel)
        vc.router = self
        vc.modalPresentationStyle = .custom
        initialViewController.present(vc, animated: false, completion: completion)
    }
    
    func presenListMembersViewController(listId: String, _ completion: (() -> Void)?) {
        let vc = ListMembersViewController.initFromItsStoryboard()
        vc.router = self
        vc.viewModel = ListMembersViewModel(listId: listId)
        parentNavigationController.pushViewController(vc, animated: true, completion)
    }
    
    func presentShareViewController(_ completion: (() -> Void)?) {
        initialViewController?.presentShareViewController(completion)
    }
}

extension ProductsListFlowRouter: ChangeNameShoppingListViewControllerRouting {
    
}
