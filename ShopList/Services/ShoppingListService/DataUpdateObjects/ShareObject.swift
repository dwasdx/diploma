import Foundation

struct ShareObject: Codable {
    let id: String
    let list_id: String
    let to_user_id: String
    let status: Int
    let created_at: Int
    let updated_at: Int
    let is_deleted: Bool
    let owner_id: String
    
    init(entity: ShareEntity) {
        self.id = entity.id
        self.list_id = entity.listId
        self.to_user_id = entity.toUserId
        self.status = Int(entity.status)
        self.created_at = Int(entity.createdAt)
        self.updated_at = Int(entity.updatedAt)
        self.is_deleted = entity.isdeleted
        self.owner_id = entity.ownerId
    }
}
