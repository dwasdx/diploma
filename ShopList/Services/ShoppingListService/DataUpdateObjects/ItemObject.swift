import Foundation

struct ItemObject: Codable {
    let id: String
    let name: String
    let value: String
    let is_marked: Bool
    let user_marked: String?
    let list_id: String
    let created_at: Int
    let updated_at: Int
    let is_deleted: Bool
    
    init(entity: ProductEntity) {
        self.id = entity.id
        self.name = entity.name
        self.value = entity.value
        self.is_marked = entity.isMarked
        self.user_marked = entity.userMarkedId
        self.list_id = entity.listId
        self.created_at = Int(entity.createdAt)
        self.updated_at = Int(entity.updatedAt)
        self.is_deleted = entity.isdeleted
    }
}
