import Foundation

struct CurrentUserObject: Codable {
    let id: String
    let name: String
    let email: String?
    let phone: Int
    let created_at: Int
    let updated_at: Int
    let is_activated: Bool
    let is_deleted: Bool
    
    init(entity: CurrentUserEntity) {
        id = entity.id
        name = entity.name
        email = entity.email
        phone = Int(entity.phone.decimalString) ?? 0
        created_at = Int(entity.createdAt)
        updated_at = Int(entity.updatedAt)
        is_activated = entity.isActivated
        is_deleted = entity.isdeleted
    }
}
