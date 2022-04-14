import Foundation
import CoreData


extension CatalogCategoryEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CatalogCategoryEntity> {
        return NSFetchRequest<CatalogCategoryEntity>(entityName: "CatalogCategoryEntity")
    }

    @NSManaged public var id: Int32
    @NSManaged public var title: String
    @NSManaged public var createdAt: Int64
    @NSManaged public var updatedAt: Int64
    @NSManaged public var products: NSOrderedSet?
    
    var productsArray: [CatalogProductEntity] {
        (products?.array as? [CatalogProductEntity]) ?? []
    }

}

extension CatalogCategoryEntity {
    
    convenience init(response: CategoryResposne, context: NSManagedObjectContext) {
        self.init(entity: CoreDataService.shared.entityForName(entityName: "CatalogCategoryEntity"), insertInto: context)
        self.id = Int32(response.id)
        self.title = response.title
        self.createdAt = response.created_at
        self.updatedAt = response.updated_at
    }
    
    func updateValues(_ response: CategoryResposne) {
        guard self.id == response.id else {
            return
        }
        self.title = response.title
        self.createdAt = response.created_at
        self.updatedAt = response.updated_at
    }
}

// MARK: Generated accessors for products
extension CatalogCategoryEntity {

    @objc(insertObject:inProductsAtIndex:)
    @NSManaged public func insertIntoProducts(_ value: CatalogProductEntity, at idx: Int)

    @objc(removeObjectFromProductsAtIndex:)
    @NSManaged public func removeFromProducts(at idx: Int)

    @objc(insertProducts:atIndexes:)
    @NSManaged public func insertIntoProducts(_ values: [CatalogProductEntity], at indexes: NSIndexSet)

    @objc(removeProductsAtIndexes:)
    @NSManaged public func removeFromProducts(at indexes: NSIndexSet)

    @objc(replaceObjectInProductsAtIndex:withObject:)
    @NSManaged public func replaceProducts(at idx: Int, with value: CatalogProductEntity)

    @objc(replaceProductsAtIndexes:withProducts:)
    @NSManaged public func replaceProducts(at indexes: NSIndexSet, with values: [CatalogProductEntity])

    @objc(addProductsObject:)
    @NSManaged public func addToProducts(_ value: CatalogProductEntity)

    @objc(removeProductsObject:)
    @NSManaged public func removeFromProducts(_ value: CatalogProductEntity)

    @objc(addProducts:)
    @NSManaged public func addToProducts(_ values: NSOrderedSet)

    @objc(removeProducts:)
    @NSManaged public func removeFromProducts(_ values: NSOrderedSet)

}
