import Foundation
import CoreData


extension ProductEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProductEntity> {
        return NSFetchRequest<ProductEntity>(entityName: "ProductEntity")
    }
    
    private func updateProductsNumberFields(shopppingListEntityId: String, context: NSManagedObjectContext) {
        // update products progress of the shoppingListEntity
        guard let listEntity = CoreDataService.shared.getEntity(entity: .shoppingList(), id: shopppingListEntityId, contextType: .specific(context)) as? ShoppingListEntity else {
            return
        }
        
        let products = CoreDataService.shared.getProductsEntities(withListId: listEntity.id, contextType: .specific(context))
        let checkedProductsNumber = products.filter { $0.isMarked == true }.count
        let productsNumber = products.count
        if listEntity.checkedProductsNumber != checkedProductsNumber || listEntity.productsNumber != productsNumber,
           checkedProductsNumber == productsNumber {
            let newPosition = CoreDataService.shared.positionBeforeFirstCompletedList(in: .specific(context))
            listEntity.positionOnScreen = newPosition
        }
        listEntity.checkedProductsNumber = Int16(checkedProductsNumber)
        listEntity.productsNumber = Int16(productsNumber)
        listEntity.hasChange = true
        
    }
    
    convenience init(model: ProductModel, context: NSManagedObjectContext) {
        self.init(entity: CoreDataService.shared.entityForName(entityName: "ProductEntity"), insertInto: context)
        self.id = model.id
        self.name = model.name
        self.value = model.value
        self.isMarked = model.isMarked
        self.userMarkedId = model.userMarkedId
        self.listId = model.listId
        self.isdeleted = model.isDeleted
        self.createdAt = Int64(model.createdAt)
        self.updatedAt = Int64(model.updatedAt)
        self.categoryName = model.categoryName
    }
    
    convenience init(object: ItemObject, context: NSManagedObjectContext) {
        self.init(entity: CoreDataService.shared.entityForName(entityName: "ProductEntity"), insertInto: context)
        self.id = object.id
        self.name = object.name
        self.value = object.value
        self.isMarked = object.is_marked
        self.userMarkedId = object.user_marked
        self.listId = object.list_id
        self.isdeleted = object.is_deleted
        self.createdAt = Int64(object.created_at)
        self.updatedAt = Int64(object.updated_at)
        
        // update products progress of the shoppingListEntity
        updateProductsNumberFields(shopppingListEntityId: object.list_id, context: context)
    }
    
    func updateValues(fromObject object: ItemObject, context: NSManagedObjectContext) {
        self.id = object.id
        self.name = object.name
        self.value = object.value
        self.isMarked = object.is_marked
        self.userMarkedId = object.user_marked
        self.listId = object.list_id
        self.isdeleted = object.is_deleted
        self.createdAt = Int64(object.created_at)
        self.updatedAt = Int64(object.updated_at)
        
        // update products progress of the shoppingListEntity
        updateProductsNumberFields(shopppingListEntityId: object.list_id, context: context)
    }

    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var value: String
    @NSManaged public var isMarked: Bool
    @NSManaged public var userMarkedId: String?
    @NSManaged public var listId: String
    @NSManaged public var isdeleted: Bool
    @NSManaged public var createdAt: Int64
    @NSManaged public var updatedAt: Int64
    @NSManaged public var categoryName: String?

}
