import Foundation
import CoreData


extension CurrentUserEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CurrentUserEntity> {
        return NSFetchRequest<CurrentUserEntity>(entityName: "CurrentUserEntity")
    }

    @NSManaged public var createdAt: Int64
    @NSManaged public var email: String?
    @NSManaged public var id: String
    @NSManaged public var isActivated: Bool
    @NSManaged public var isdeleted: Bool
    @NSManaged public var name: String
    @NSManaged public var phone: String
    @NSManaged public var updatedAt: Int64
    @NSManaged public var emailApproved: Bool
    
    convenience init(model: CurrentUserModel, context: NSManagedObjectContext) {
        self.init(entity: CoreDataService.shared.entityForName(entityName: "CurrentUserEntity"), insertInto: context)
        self.createdAt = Int64(model.createdAt)
        self.email = model.email
        self.id = model.id
        self.isActivated = model.isActivated
        self.isdeleted = model.isDeleted
        self.name = model.name
        self.phone = model.phone
        self.updatedAt = Int64(model.updatedAt)
        self.emailApproved = model.emailApproved ?? false
    }
}


