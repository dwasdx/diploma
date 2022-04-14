import Foundation
import CoreData


extension CatalogProductEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CatalogProductEntity> {
        return NSFetchRequest<CatalogProductEntity>(entityName: "CatalogProductEntity")
    }

    @NSManaged public var id: Int32
    @NSManaged public var title: String
    @NSManaged public var categoryId: Int32
    @NSManaged public var createdAt: Int64
    @NSManaged public var updatedAt: Int64
    @NSManaged public var category: CatalogCategoryEntity?

}

extension CatalogProductEntity {
    
    convenience init(response: ProductResposne, context: NSManagedObjectContext) {
        self.init(entity: CoreDataService.shared.entityForName(entityName: "CatalogProductEntity"), insertInto: context)
        self.id = Int32(response.id)
        self.categoryId = Int32(response.category_id)
        self.title = response.title
        self.createdAt = response.created_at
        self.updatedAt = response.updated_at
    }
    
    func updateValues(_ response: ProductResposne) {
        guard self.id == response.id else {
            return
        }
        self.title = response.title
        self.categoryId = Int32(response.category_id)
        self.createdAt = response.created_at
        self.updatedAt = response.updated_at
    }
}
