import Foundation

struct ListObject: Codable {
    let id: String
    let owner_id: String
    let name: String
    let created_at: Int
    let updated_at: Int
    let is_deleted: Bool
    let is_template: Bool
    
    init(entity: ShoppingListEntity) {
        self.id = entity.id
        self.owner_id = entity.ownerId
        self.name = entity.name
        self.created_at = Int(entity.createdAt)
        self.updated_at = Int(entity.updatedAt)
        self.is_deleted = entity.isdeleted
        self.is_template = false
    }
}
