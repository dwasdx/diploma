import Foundation
import CoreData


extension ShareEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ShareEntity> {
        return NSFetchRequest<ShareEntity>(entityName: "ShareEntity")
    }

    @NSManaged public var createdAt: Int64
    @NSManaged public var id: String
    @NSManaged public var isdeleted: Bool
    @NSManaged public var listId: String
    @NSManaged public var status: Int16
    @NSManaged public var toUserId: String
    @NSManaged public var updatedAt: Int64
    @NSManaged public var ownerId: String
    
    var membershipStatus: ListMemberModel.MembershipStatus? {
        ListMemberModel.MembershipStatus(rawValue: Int(self.status))
    }
    
    convenience init(object: ShareObject, context: NSManagedObjectContext) {
        self.init(entity: CoreDataService.shared.entityForName(entityName: "ShareEntity"), insertInto: context)
        
        self.id = object.id
        self.listId = object.list_id
        self.toUserId = object.to_user_id
        self.status = Int16(object.status)
        self.createdAt = Int64(object.created_at)
        self.updatedAt = Int64(object.updated_at)
        self.isdeleted = object.is_deleted
        self.ownerId = object.owner_id
    }
    
    convenience init(model: ShareModel, context: NSManagedObjectContext) {
        self.init(entity: CoreDataService.shared.entityForName(entityName: "ShareEntity"), insertInto: context)
        self.id = model.id
        self.listId = model.listId
        self.toUserId = model.toUserId
        self.status = Int16(model.status)
        self.createdAt = Int64(model.createdAt)
        self.updatedAt = Int64(model.updatedAt)
        self.isdeleted = model.isDeleted
        self.ownerId = model.ownerId
    }
    
    func updateValues(fromObject object: ShareObject) {
        self.id = object.id
        self.listId = object.list_id
        self.toUserId = object.to_user_id
        self.createdAt = Int64(object.created_at)
        self.updatedAt = Int64(object.updated_at)
        self.isdeleted = object.is_deleted
        self.ownerId = object.owner_id
        self.status = Int16(object.status)
    }

}
