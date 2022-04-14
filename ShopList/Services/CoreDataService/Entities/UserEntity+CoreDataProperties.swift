import Foundation
import CoreData


extension UserEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }

    @NSManaged public var phone: Int64
    @NSManaged public var id: String
    @NSManaged public var phoneString: String
    
    convenience init(object: UserObject, context: NSManagedObjectContext) {
        self.init(entity: CoreDataService.shared.entityForName(entityName: "UserEntity"), insertInto: context)
        self.id = object.id
        self.phone = Int64(object.phone)
        self.phoneString = String(self.phone)
    }
    
    func updateValues(fromObject object: UserObject) {
        self.id = object.id
        self.phone = Int64(object.phone)
        self.phoneString = String(self.phone)
    }
    
}
