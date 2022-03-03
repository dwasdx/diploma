import Foundation

class CreateShoppingListViewModel: BaseViewModel {
    
    let userManager: CurrentUserManaging
    let syncService: SynchronizationServiceable
    
    init(
        userManager: CurrentUserManaging = CurrentUserManager.shared,
        syncService: SynchronizationServiceable = SynchronizationService.shared
    ) {
        self.userManager = userManager
        self.syncService = syncService
    }
}

extension CreateShoppingListViewModel: CreateShoppingListViewModeling {
    
    func createModel(name: String) {
        
        let date = Date()
        let timeInterval = date.timeIntervalSince1970
        let dateInt = Int(timeInterval)
        
        guard let id = CurrentUserManager.shared.currentUser?.value?.id else {
            fatalError("No current user id")
        }
        
        let model = ShoppingListModel(ownerId: id, name: name, createdAt: dateInt, updatedAt: dateInt)
        
        CoreDataService.shared.addEntity(entity: .shoppingList(model), contextType: .view)
        if let token = userManager.userToken {
            syncService.synchronizeDatabaseWithDelay(token: token, fullUpdate: false)
        }
    }
    
}


