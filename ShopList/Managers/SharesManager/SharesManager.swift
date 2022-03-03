import Foundation
import CoreData

// MARK: Shares manager monitors changes and modifies the fields of the corresponding lists

class SharesManager: NSObject {
    
    static let shared = SharesManager()
    private override init() {
    }
    
    let sharesFetchedResultsController = CoreDataService.shared.createSharesFetchedResultsController()
    
    func configure() {
        setupSharesFetchedResultsController()
    }
    
    private func setupSharesFetchedResultsController() {
        sharesFetchedResultsController.delegate = self
        do {
            try sharesFetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
    }
    
}

extension SharesManager: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        
        case .insert, .update:
            
            guard let shareEntity = anObject as? ShareEntity else {
                return
            }
            
            let context = controller.managedObjectContext
            
            guard let listEntity = CoreDataService.shared.getEntity(entity: .shoppingList(), id: shareEntity.listId, contextType: .specific(context)) as? ShoppingListEntity else {
                return
            }
            
            // MARK: The list is displayed on the screen if you are the master of the list or if there is an accepted share object
            listEntity.toBePresented = CoreDataService.shared.listToBePresented(
                listId: listEntity.id,
                listOwnerId: listEntity.ownerId,
                context: context)
            
            // MARK: Accepted shares count defines the type of icon (for shared lists - the icon is blue)
            listEntity.acceptedSharesCount = Int16(CoreDataService.shared.getNumberOfActiveShares(for: shareEntity.listId, context: context))
            
            break
            
        case .delete, .move:
            return
            
        @unknown default:
            print("ERROR")
        }
        
    }
    
}
