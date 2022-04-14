import Foundation
import CoreData

class MigrationPolicyV5toV6: NSEntityMigrationPolicy {

    override func begin(_ mapping: NSEntityMapping, with manager: NSMigrationManager) throws {
        // Get all current entities and delete them before mapping begins
        let context = manager.sourceContext
        
        let entityNamesToDelete = ["ShoppingListEntity",
                                   "ShareEntity",
                                   "CatalogCategoryEntity",
                                   "CatalogProductEntity"]
        
        for entityName in entityNamesToDelete {
            let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
            let results = try context.fetch(request)
            results.forEach(context.delete)
        }
        
        ShoppingListService.shared.lastGetDataTimeStamp = 0
        
        try super.begin(mapping, with: manager)
    }
    
}
