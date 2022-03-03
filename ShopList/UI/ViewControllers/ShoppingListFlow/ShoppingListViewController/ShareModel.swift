import Foundation

class ShareModel: GeneralModel {
    let listId: String
    var listName: String
    let ownerName: String
    let toUserId: String
    let status: Int
    let createdAt: Int
    let updatedAt: Int
    let isDeleted: Bool
    let ownerId: String
    
    var membershipStatus: ListMemberModel.MembershipStatus {
        ListMemberModel.MembershipStatus(rawValue: self.status) ?? .notInvited
    }
    
    init(entity: ShareEntity) {
        self.listId = entity.listId
        
        if let listEntity = CoreDataService.shared.getEntity(entity: .shoppingList(), id: listId, contextType: .view) as? ShoppingListEntity {
            self.listName = listEntity.name
        } else {
            self.listName = "NA"
        }
        
        if let userEntity = CoreDataService.shared.getEntity(entity: .user(), id: entity.ownerId, contextType: .view) as? UserEntity {
            let contact = ContactsManager.shared.getContact(byPhoneNumber: userEntity.phoneString)
            self.ownerName = contact == nil ?
                PhoneNumberManager.shared.formatPhoneNumber(userEntity.phoneString) : contact!.name
        } else {
            self.ownerName = "NA"
        }
        self.toUserId = entity.toUserId
        self.status = Int(entity.status)
        self.createdAt = Int(entity.createdAt)
        self.updatedAt = Int(entity.updatedAt)
        self.isDeleted = entity.isdeleted
        self.ownerId = entity.ownerId
        super.init(id: entity.id)
    }
    
//    override init() {
//        self.ownerId = "123-hardcode-123"
//        self.listId = "123"
//        self.listName = "New List"
//        self.ownerName = "Petya"
//        self.toUserId = "123-hardcode-123"
//        self.status = 0
//        self.createdAt = 21312312
//        self.updatedAt = 12312321
//        self.isDeleted = false
//        super.init()
//    }
    
    init(listId: String, toUserId: String, status: Int) {
        self.listId = listId
        self.toUserId = toUserId
        self.status = status
        if let listEntity = CoreDataService.shared.getEntity(entity: .shoppingList(), id: listId, contextType: .view) as? ShoppingListEntity {
            self.listName = listEntity.name
            self.ownerId = listEntity.ownerId
        } else {
            self.listName = "NA"
            self.ownerId = "NA"
        }
        self.ownerName = CurrentUserManager.shared.currentUser?.value?.name ?? "NA"
        self.createdAt = CurrentTimeManager.shared.getCurrentTime()
        self.updatedAt = self.createdAt
        self.isDeleted = false
        super.init()
    }
}
