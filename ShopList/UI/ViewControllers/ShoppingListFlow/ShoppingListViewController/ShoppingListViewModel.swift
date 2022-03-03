import UIKit
import CoreData

//MARK: General

class ShoppingListViewModel: BaseViewModel {
    
    lazy var queue = DispatchQueue(label: "com.shoppingList.shoppingListViewModelQueue", qos: .userInteractive, autoreleaseFrequency: .inherit, target: nil)
    
    weak var shoppingListService: ShoppingListDataServicable? = {
        if CommandLine.arguments.contains("--mockApi") {
            return MockShoppingListService.shared
        } else {
            return ShoppingListService.shared
        }
    }()
    
    private var shoppingListsFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>
    private var invitationsFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>
    
    var synchronizationChangesSubscriptionToken: SignalSubscriptionToken? = nil
    var synchronizationLoadingChangesToken: SignalSubscriptionToken? = nil
    
    var didCancelModelDelete: ((IndexPath) -> Void)?
    var didFailSynchronization: ((String) -> Void)?
    var updateWithScroll: (() -> Void)?
    
    var shares = [ShareModel]()
    var lists = [ShoppingListModel]()
    
    let syncService: SynchronizationServiceable
    let userManager: CurrentUserManaging
    
    init(
        syncService: SynchronizationServiceable = SynchronizationService.shared,
        userManager: CurrentUserManaging = CurrentUserManager.shared
    ) {
        self.syncService = syncService
        self.userManager = userManager
        
        shoppingListsFetchedResultsController = CoreDataService.shared.createShoppingListsFetchedResultsController()
        invitationsFetchedResultsController = CoreDataService.shared.createInvitationsFetchedResultsController()
        
        super.init()
        
        setupShoppingListsFetchedResultsController()
        setupInvitationsFetchedResultsController()
        
        
        self.synchronizationChangesSubscriptionToken = syncService.sycnhronizationChanges.signal.addListener(listenerBlock: { [weak self] (error) in
            //                self?.isLoading = false
            if let error = error {
                switch error {
                case .server(let serverError):
                    self?.processServerError(serverError)
                case .parsing(_):
                    break //TBD
                case .network(_):
                    self?.didFailSynchronization?("Нет соединения с сервером")
                }
                return
            }
            self?.didChange?()
        })
        self.synchronizationLoadingChangesToken = syncService.loadingChanges.signal.addListener(listenerBlock: { [weak self] (isLoading) in
            self?.isLoading = isLoading
        })
        
        queue.async { [weak self] in
            if let token = self?.userManager.userToken {
                self?.syncService.synchronizeDatabase(token: token, fullUpdate: false)
            }
        }
    }
    
    private func setupShoppingListsFetchedResultsController() {
        
        self.shoppingListsFetchedResultsController.delegate = self
        do {
            try shoppingListsFetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
        guard let initialValues = shoppingListsFetchedResultsController.fetchedObjects as? [ShoppingListEntity] else {
            return
        }
        
        
        // Calculating number of all products in list and number of checked products
        for list in initialValues {
            let products = CoreDataService.shared.getProductsEntities(withListId: list.id, contextType: .view)
            
            list.checkedProductsNumber = Int16(products.filter { $0.isMarked == true }.count)
            list.productsNumber = Int16(products.count)
        }
        
        lists = initialValues.map {
            ShoppingListModel(shoppingListEntity: $0)
        }
    }
    
    private func setupInvitationsFetchedResultsController() {
        self.invitationsFetchedResultsController.delegate = self
        do {
            try invitationsFetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
        guard let initialValues = invitationsFetchedResultsController.fetchedObjects as? [ShareEntity] else {
            return
        }
        shares = initialValues.map {
            ShareModel(entity: $0)
        }
    }
    
    
    deinit {
        syncService.sycnhronizationChanges.signal.removeListener(synchronizationChangesSubscriptionToken)
        syncService.loadingChanges.signal.removeListener(synchronizationLoadingChangesToken)
    }
    
    private func isListExists(_ list: ShoppingListModel) -> Bool {
        self.lists.contains(where: { $0.id == list.id })
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
    
}

//MARK: Extension ShoppingListViewModeling

extension ShoppingListViewModel: ShoppingListViewModeling {
    
    var isEmptyModel: Bool {
        lists.isEmpty && shares.isEmpty
    }
    
    var isEmptyShares: Bool {
        shares.isEmpty
    }
    
    func getModelForRow(at indexPath: IndexPath) -> ShoppingListModel? {
        guard lists.indices ~= indexPath.row else {
            return nil
        }
        return lists[indexPath.row]
    }
    
    func removeModel(inCellWithIndexPath indexPath: IndexPath) {
        queue.async { [weak self] in
            guard let self = self else {
                return
            }
            let model = self.lists[indexPath.row]
            CoreDataService.shared.removeEntity(entity: .shoppingList(), id: model.id, contextType: .view)
            guard let token = self.userManager.userToken else {
                return
            }
            self.syncService.synchronizeDatabaseWithDelay(token: token, fullUpdate: false)
        }
    }
    
    func moveList(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        guard sourceIndexPath != destinationIndexPath else {
            return
        }
        
        let newPosition: Double
        if destinationIndexPath.row == lists.count - 1 {
            // if moved to the bottom
            newPosition = lists[destinationIndexPath.row].positionOnScreen + 1
        } else if destinationIndexPath.row == 0  {
            // if moved to the top
            newPosition = lists[destinationIndexPath.row].positionOnScreen - 1
        } else if destinationIndexPath.row < sourceIndexPath.row {
            // if moved UP
            newPosition = (lists[destinationIndexPath.row].positionOnScreen + lists[destinationIndexPath.row - 1].positionOnScreen) / 2
        } else {
            // if moved DOWN
            newPosition = (lists[destinationIndexPath.row].positionOnScreen + lists[destinationIndexPath.row + 1].positionOnScreen) / 2
        }
        
        
        let model = lists[sourceIndexPath.row]
        let entityToMove = CoreDataService.shared.getEntity(entity: .shoppingList(), id: model.id, contextType: .view) as? ShoppingListEntity
        entityToMove?.positionOnScreen = newPosition
        CoreDataService.saveViewContext()
    }
    
    func sync() {
        guard let token = userManager.userToken else {
            return
        }
        syncService.synchronizeDatabase(token: token, fullUpdate: false)
    }
    
}

extension ShoppingListViewModel: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        defer {
            didChange?()
        }
        
        switch controller.fetchRequest.entity?.name {
        
        case "ShareEntity":
            switch type {
            
            case .move:
                guard let shareEntity = anObject as? ShareEntity,
                      let indexPath = indexPath,
                      let newIndexPath = newIndexPath else {
                    return
                }
                shares.remove(at: indexPath.row)
                let shareModelForReorder = ShareModel(entity: shareEntity)
                shares.insert(shareModelForReorder, at: newIndexPath.row)
            case .insert:
                //MARK: Special handling for inserts because multiple items for inserts arrive in the wrong order (tracked on first sync after login)
                guard let shareEntity = anObject as? ShareEntity else {
                    return
                }
                let shareModel = ShareModel(entity: shareEntity)
                
                if let index = self.shares.firstIndex(where: { $0.createdAt > shareModel.createdAt }) {
                    shares.insert(shareModel, at: index)
                } else {
                    shares.append(shareModel)
                }
            case .update:
                guard let shareEntity = anObject as? ShareEntity,
                      let index = shares.firstIndex(where: { $0.id == shareEntity.id }) else {
                    return
                }
                let shareModel = ShareModel(entity: shareEntity)
                shares[index] = shareModel
            case .delete:
                guard let shareEntity = anObject as? ShareEntity,
                      let index = shares.firstIndex(where: { $0.id == shareEntity.id }) else {
                    return
                }
                shares.remove(at: index)
            @unknown default:
                print("ERROR")
            }
            
        case "ShoppingListEntity":
            
            switch type {
            case .move:
                guard let shoppingListEntity = anObject as? ShoppingListEntity,
                      let indexPath = indexPath,
                      let newIndexPath = newIndexPath else {
                    return
                }
                lists.remove(at: indexPath.row)
                let listModelForReorder = ShoppingListModel(shoppingListEntity: shoppingListEntity)
                lists.insert(listModelForReorder, at: newIndexPath.row)
                break
            case .insert:
                //MARK: Special handling for inserts because multiple items for inserts arrive in the wrong order (tracked on first sync after login)
                guard let shoppingListEntity = anObject as? ShoppingListEntity else {
                    return
                }
                let shoppingListModel = ShoppingListModel(shoppingListEntity: shoppingListEntity)
                
                if let index = self.lists.firstIndex(where: { $0.positionOnScreen > shoppingListModel.positionOnScreen }) {
                    lists.insert(shoppingListModel, at: index)
                } else {
                    lists.append(shoppingListModel)
                }
                self.updateWithScroll?()
                break
            case .update:
                guard let shoppingListEntity = anObject as? ShoppingListEntity,
                      let index = lists.firstIndex(where: { $0.id == shoppingListEntity.id}) else {
                    return
                }
                let shoppingListModel = ShoppingListModel(shoppingListEntity: shoppingListEntity)
                lists[index] = shoppingListModel
                break
            case .delete:
                guard let shoppingListEntity = anObject as? ShoppingListEntity,
                      let index = lists.firstIndex(where: { $0.id == shoppingListEntity.id }) else {
                    return
                }
                lists.remove(at: index)
                break
            @unknown default:
                print("ERROR")
            }
            
            
        case .none, .some(_):
            return
        }
    }
    
}
