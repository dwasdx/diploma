import Foundation

struct CurrentUserModel: Equatable {
    
    var id: String
    var name: String
    var phone : String
    var isActivated: Bool
    var email: String?
    var emailApproved : Bool?
    var createdAt: Int
    var updatedAt: Int
    var isDeleted: Bool
    
    init(id: String,
         name: String,
         phone: String,
         isActivated: Bool = false,
         email: String?,
         emailApproved: Bool? = false) {
        self.id = id
        self.name = name
        self.phone = phone
        self.isActivated = isActivated
        self.email = email
        self.emailApproved = emailApproved
        self.createdAt = CurrentTimeManager.shared.getCurrentTime()
        self.updatedAt = CurrentTimeManager.shared.getCurrentTime()
        self.isDeleted = false
    }
    
    init(entity: CurrentUserEntity) {
        self.init(id: entity.id,
                  name: entity.name,
                  phone: entity.phone,
                  isActivated: entity.isActivated,
                  email: entity.email,
                  emailApproved: entity.emailApproved)
    }
    
}


