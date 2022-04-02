import Foundation

protocol DeleteProductViewModeling {
    func deleteProduct()
    func reloadCell()
    var description: String { get }
}

class DeleteProductViewModel {
    var product: ProductModel
    let indexPath: IndexPath
    private var didCancelModelDelete: ((IndexPath) -> Void)?
    
    let userManager: CurrentUserManaging
    let syncService: SynchronizationServiceable
    
    init(product: ProductModel,
         indexPath: IndexPath,
         didCancelModelDelete: ((IndexPath) -> Void)?,
         userManager: CurrentUserManaging = CurrentUserManager.shared,
         syncService: SynchronizationServiceable = SynchronizationService.shared) {
        self.product = product
        self.indexPath = indexPath
        self.userManager = userManager
        self.syncService = syncService
        self.didCancelModelDelete = didCancelModelDelete
    }
}

extension DeleteProductViewModel: DeleteProductViewModeling {
    func deleteProduct() {
        CoreDataService.shared.removeEntity(entity: .product(product), id: product.id, contextType: .view)
        if let token = userManager.userToken {
            syncService.synchronizeDatabaseWithDelay(token: token, fullUpdate: false)
        }
    }
    
    func reloadCell() {
        didCancelModelDelete?(indexPath)
    }
    
    var description: String {
        return product.name
    }
    
    
}
