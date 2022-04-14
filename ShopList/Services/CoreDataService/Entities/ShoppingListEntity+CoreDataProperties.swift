import Foundation
import CoreData


extension ShoppingListEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ShoppingListEntity> {
        return NSFetchRequest<ShoppingListEntity>(entityName: "ShoppingListEntity")
    }
    
    convenience init(id: String, ownerId: String, name: String, isDeleted: Bool, createdAt: Int, updatedAt: Int, context: NSManagedObjectContext) {
        self.init(entity: CoreDataService.shared.entityForName(entityName: "ShoppingListEntity"), insertInto: context)
        self.init()
        self.id = id
        self.ownerId = ownerId
        self.name = name
        self.isdeleted = isDeleted
        self.createdAt = Int64(createdAt)
        self.updatedAt = Int64(updatedAt)
        self.hasChange = false
    }
    
    convenience init(model: ShoppingListModel, context: NSManagedObjectContext) {
        self.init(entity: CoreDataService.shared.entityForName(entityName: "ShoppingListEntity"), insertInto: context)
        self.productsNumber = Int16(model.productsNumber)
        self.id = model.id
        self.ownerId = model.ownerId
        self.name = model.name
        self.isdeleted = model.isDeleted
        self.createdAt = Int64(model.createdAt)
        self.updatedAt = Int64(model.updatedAt)
        self.toBePresented = model.toBePresented
        self.hasChange = model.hasChange
        self.positionOnScreen = model.positionOnScreen
    }
    
    convenience init(object: ListObject, checkedProductsNumber: Int, productsNumber: Int, in context: NSManagedObjectContext) {
        self.init(entity: CoreDataService.shared.entityForName(entityName: "ShoppingListEntity"), insertInto: context)
        self.id = object.id
        self.ownerId = object.owner_id
        self.name = object.name
        self.isdeleted = object.is_deleted
        self.createdAt = Int64(object.created_at)
        self.updatedAt = Int64(object.updated_at)
        self.toBePresented = CoreDataService.shared.listToBePresented(listId: object.id, listOwnerId: object.owner_id, context: context)
        self.checkedProductsNumber = Int16(checkedProductsNumber)
        self.productsNumber = Int16(productsNumber)
        self.hasChange = false
        self.positionOnScreen = toBePresented ? CoreDataService.shared.positionBeforeFirstCompletedList(in: .specific(context)) : -1
    }
    
    func updateValues(fromObject object: ListObject, checkedProductsNumber: Int, productsNumber: Int, in context: NSManagedObjectContext) {
        self.id = object.id
        self.ownerId = object.owner_id
        self.name = object.name
        self.isdeleted = object.is_deleted
        self.createdAt = Int64(object.created_at)
        self.updatedAt = Int64(object.updated_at)
        self.toBePresented = CoreDataService.shared.listToBePresented(listId: object.id, listOwnerId: object.owner_id, context: context)
        self.checkedProductsNumber = Int16(checkedProductsNumber)
        self.productsNumber = Int16(productsNumber)
        self.hasChange = true
    }

    @NSManaged public var createdAt: Int64
    @NSManaged public var id: String
    @NSManaged public var isdeleted: Bool
    @NSManaged public var name: String
    @NSManaged public var ownerId: String
    @NSManaged public var updatedAt: Int64
    @NSManaged public var toBePresented: Bool
    @NSManaged public var acceptedSharesCount: Int16
    @NSManaged public var productsNumber: Int16
    @NSManaged public var checkedProductsNumber: Int16
    @NSManaged public var positionOnScreen: Double
    @NSManaged public var hasChange: Bool
    
    var isSharedList: Bool {
        acceptedSharesCount > 0
    }
    
    var isCompleted: Bool {
        checkedProductsNumber == productsNumber && productsNumber > 0
    }
    
}
