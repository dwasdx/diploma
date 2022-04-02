import Foundation

protocol ChangeNameListViewModeling {
    var name: String { get set }
    var parentViewModel: ProductsListViewModeling { get }
    func changeModelInParentViewModel()
}

class ChangeNameListViewModel: BaseViewModel {
    var name: String
    var listEntity: ShoppingListEntity?
    var parentViewModel: ProductsListViewModeling
    
    let syncService: SynchronizationServiceable
    let userManager: CurrentUserManaging
    
    init(
        productsListViewModel: ProductsListViewModeling,
        userManager: CurrentUserManaging = CurrentUserManager.shared,
        syncService: SynchronizationServiceable = SynchronizationService.shared
    ) {
        self.syncService = syncService
        self.userManager = userManager
        parentViewModel = productsListViewModel
        listEntity = CoreDataService.shared.getEntity(entity: .shoppingList(), id: parentViewModel.listId, contextType: .view) as? ShoppingListEntity
        name = listEntity?.name ?? ""
    }
}

extension ChangeNameListViewModel: ChangeNameListViewModeling {
    
    func changeModelInParentViewModel() {
        listEntity?.name = name
        parentViewModel.listTitle = name
        listEntity?.updatedAt = Int64(CurrentTimeManager.shared.getCurrentTime())
        CoreDataService.saveViewContext()
        if let token = userManager.userToken {
            syncService.synchronizeDatabaseWithDelay(token: token, fullUpdate: false)
        }
    }
}
