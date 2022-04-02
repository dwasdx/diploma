//
//  ProdcutsListViewModel.swift
//  ShoppingList
//
//  Created by Андрей Журавлев on 03.06.2020.
//  Copyright © 2020 Dmitry Lemaykin. All rights reserved.
//

import Foundation
import CoreData

//MARK: ProductTypeEnum

enum ProductType: Int {
    case unchecked, checked
}

//MARK: General

class ProductsListViewModel: BaseViewModel {
    
    private var productsFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>
    
    var synchronizationChangesSubscriptionToken: SignalSubscriptionToken? = nil
    var synchronizationLoadingChangesToken: SignalSubscriptionToken? = nil
    let lockForModels = DispatchQueue(label: "lockForModels")
    
    var products: [ProductType: [ProductModel]] = {
        var res = [ProductType: [ProductModel]]()
        res[.checked] = []
        res[.unchecked] = []
        return res
    }()
    
    var didCancelModelDelete: ((IndexPath) -> Void)?
    var updateWithScroll: (() -> Void)?
    var didFailSynchronization: ((String) -> Void)?
    
    let listId: String
    var listTitle: String {
        didSet {
            didChange?()
        }
    }
    
    var cartHeaderViewHeight: Float = 50
    
    let userManager: CurrentUserManaging
    let syncService: SynchronizationServiceable
    
    init(
        withListModel shoppingListModel: ShoppingListModel,
        userManager: CurrentUserManaging = CurrentUserManager.shared,
        syncService: SynchronizationServiceable = SynchronizationService.shared
    ) {
        
        productsFetchedResultsController = CoreDataService.shared.createProductsFetchedResultsController(listId: shoppingListModel.id)
        self.listId = shoppingListModel.id
        self.listTitle = shoppingListModel.name
        self.userManager = userManager
        self.syncService = syncService
        
        super.init()
        
        setupProductsFetchedResultsController()
        self.synchronizationChangesSubscriptionToken = syncService.sycnhronizationChanges.signal.addListener(listenerBlock: { [weak self] (error) in
            //            self?.isLoading = false
            if let error = error {
                switch error {
                case .server(let serverError):
                    self?.processServerError(serverError)
                case .parsing(_):
                    break //TBD
                case .network(_):
                    break //TBD
                }
            }
        })
        
        self.synchronizationLoadingChangesToken = syncService.loadingChanges.signal.addListener(listenerBlock: { [weak self] (isLoading) in
            self?.isLoading = isLoading
        })
    }
    
    deinit {
        syncService.sycnhronizationChanges.signal.removeListener(synchronizationChangesSubscriptionToken)
        syncService.loadingChanges.signal.removeListener(synchronizationLoadingChangesToken)
    }
    
    private func setupProductsFetchedResultsController() {
        self.productsFetchedResultsController.delegate = self
        do {
            try productsFetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
        guard let initialValues = productsFetchedResultsController.fetchedObjects as? [ProductEntity] else {
            return
        }
        let productModels = initialValues.map {
            ProductModel(productEntity: $0)
        }
        
        products[.checked]? = productModels.filter { $0.isMarked }
        products[.unchecked]? = productModels.filter { !$0.isMarked }
    }
    
    private func checkCell(inIndexPath indexPath: IndexPath) {
        let model = products[.unchecked]?[indexPath.row]
        guard let entity = CoreDataService.shared.getEntity(entity: .product(model), id: model!.id, contextType: .view) as? ProductEntity else {
            return
        }
        entity.isMarked = true
        entity.userMarkedId = CurrentUserManager.shared.userIdentifier
        entity.updatedAt = Int64(CurrentTimeManager.shared.getCurrentTime())
        CoreDataService.saveViewContext()
        
    }
    
    private func uncheckCell(inIndexPath indexPath: IndexPath) {
        let model = products[.checked]?[indexPath.row]
        guard let entity = CoreDataService.shared.getEntity(entity: .product(model), id: model!.id, contextType: .view) as? ProductEntity else {
            return
        }
        entity.isMarked = false
        entity.userMarkedId = nil
        entity.updatedAt = Int64(CurrentTimeManager.shared.getCurrentTime())
        CoreDataService.saveViewContext()
    }
    
    private func processServerError(_ serverError: ShoppingListServerError.BackendError) {
        switch serverError.code {
        case 1:
            break //TBD
        case 3:
            break //TBD
        default:
            print("uncaught error in method \(#function)")
        }
    }
    
    private func syncDataBase(delayed: Bool) {
        guard let token = userManager.userToken else  {
            return
        }
        if delayed {
            syncService.synchronizeDatabaseWithDelay(token: token, fullUpdate: false)
        } else {
            syncService.synchronizeDatabase(token: token, fullUpdate: false)
        }
    }
    
}

//MARK: Extension ProductsListViewModeling

extension ProductsListViewModel: ProductsListViewModeling {
    
    var isEmptyModel: Bool {
        uncheckedCount == 0 && checkedCount == 0
    }
    
    var isEmptyCheckedModel: Bool {
        checkedCount == 0
    }
    
    var progress: Float {
        if (uncheckedCount + checkedCount) == 0 {
            return 0
        }
        return Float(checkedCount) / (Float(uncheckedCount) + Float(checkedCount))
    }
    
    var progressString: String {
        "\(checkedCount)/\(uncheckedCount + checkedCount)"
    }
    
    var checkedCount: Int {
        lockForModels.sync {
            return products[.checked]?.count ?? 0
        }
    }
    
    var uncheckedCount: Int {
        lockForModels.sync {
            return products[.unchecked]?.count ?? 0
        }
    }
    
    
    var currentUserIsListOwner: Bool {
        if let listEntity = CoreDataService.shared.getEntity(entity: .shoppingList(), id: self.listId, contextType: .view) as? ShoppingListEntity {
            return CurrentUserManager.shared.userIdentifier == listEntity.ownerId
        } else {
            return false
        }
    }
    
    var listDescription: String {
        var description = ""
        guard let list = CoreDataService.shared.getEntity(entity: .shoppingList(), id: listId, contextType: .view) as? ShoppingListEntity else {
            return description
        }
        description = "Список покупок \"\(list.name)\":"
        let products = CoreDataService.shared.getProductsEntities(withListId: listId, contextType: .view)
        let checkedProductsCount = products.filter { $0.isMarked == false }.count
        description = "\(description)\n\nКупить (\(checkedProductsCount)):"
        products.filter { $0.isMarked == false }.forEach { (product) in
            description = "\(description)\n- \(product.name)\(product.value.isEmpty ? "" : " \(product.value)" )"
        }
        let productsCount = products.filter { $0.isMarked == true }.count
        description = "\(description)\n\nВ корзине (\(productsCount)):"
        products.filter { $0.isMarked == true }.forEach { (product) in
            description = "\(description)\n- \(product.name)\(product.value.isEmpty ? "" : " \(product.value)" )"
        }
        
        description += "\n\nДля более удобного использования и совместного изменения списков, скачайте приложение в AppStore:\nhttps://apps.apple.com/ru/app/%D1%81%D0%BF%D0%B8%D1%81%D0%BE%D0%BA-%D0%BF%D0%BE%D0%BA%D1%83%D0%BF%D0%BE%D0%BA-shopping-list/id1530377058"
        return description
    }
    
    func getModel(at indexPath: IndexPath) -> ProductModel? {
        switch indexPath.section {
        case 0:
            var model: ProductModel?
            lockForModels.sync {
                model =  products[.unchecked]?[indexPath.row]
            }
            return model
        case 2:
            var model: ProductModel?
            lockForModels.sync {
                model =  products[.checked]?[indexPath.row]
            }
            return model
        default:
            return nil
        }
    }
    
    
    func markCell(inIndexPath indexPath: IndexPath) {
        if indexPath.section == 0 {
            checkCell(inIndexPath: indexPath)
        } else {
            uncheckCell(inIndexPath: indexPath)
        }
        syncDataBase(delayed: true)
    }
    
    func uncheckAllProducts() {
        guard let checkedModels = products[.checked] else {
            return
        }
        for model in checkedModels {
            guard let entity = CoreDataService.shared.getEntity(entity: .product(model), id: model.id, contextType: .view) as? ProductEntity else {
                return
            }
            entity.isMarked = false
            entity.userMarkedId = nil
            entity.updatedAt = Int64(CurrentTimeManager.shared.getCurrentTime())
            CoreDataService.saveViewContext()
        }
        syncDataBase(delayed: true)
    }
    
    func dropBadge() {
        guard let listEntity = CoreDataService.shared.getEntity(entity: .shoppingList(), id: listId, contextType: .view) as? ShoppingListEntity else {
            return
        }
        if listEntity.hasChange {
            listEntity.hasChange = false
            CoreDataService.saveViewContext()
        }
    }
    
    func sync() {
        syncDataBase(delayed: false)
    }
    
}

extension ProductsListViewModel: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        defer {
            didChange?()
        }
        
        switch controller.fetchRequest.entity?.name {
        
        case "ProductEntity":
            guard let initialValues = (productsFetchedResultsController.fetchedObjects ?? []) as? [ProductEntity] else {
                return
            }
            let productModels = initialValues.map {
                ProductModel(productEntity: $0)
            }
            
            guard let changedProduct = anObject as? ProductEntity else {
                return
            }
            
            // update product counting for list
            let listEntity = CoreDataService.shared.getEntity(entity: .shoppingList(), id: changedProduct.listId, contextType: .view) as! ShoppingListEntity
            
            listEntity.checkedProductsNumber = Int16(productModels.filter { $0.isMarked == true }.count)
            listEntity.productsNumber = Int16(productModels.count)
            if listEntity.isCompleted {
                let newPosition = CoreDataService.shared.positionBeforeFirstCompletedList(in: .view)
                listEntity.positionOnScreen = newPosition
            }
            
            self.products[.checked]?.removeAll()
            self.products[.unchecked]?.removeAll()
            self.products[.checked]? = productModels.filter { $0.isMarked == true }
            self.products[.unchecked]? = productModels.filter { $0.isMarked == false }
            
        case .none, .some(_):
            return
        }
    }
    
}

