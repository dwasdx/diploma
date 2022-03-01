import Foundation

struct UserObject: Codable, Equatable {
    var id: String
    let name: String?
    let email: String?
    let phone: Int
    let created_at: Int?
    let updated_at: Int?
    let is_activated: Bool?
    let is_deleted: Bool?
    
    init(id: String, name: String?, email: String?, phone: Int, created_at: Int?, updated_at: Int?, is_activated: Bool?, is_deleted: Bool?) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.created_at = created_at
        self.updated_at = updated_at
        self.is_activated = is_activated
        self.is_deleted = is_deleted
    }
    
    init(fromGetUserResponse response: GetUserResponse) {
        self.id = response.id
        self.phone = response.phone
        self.name = nil
        self.email = nil
        self.created_at = nil
        self.updated_at = nil
        self.is_deleted = nil
        self.is_activated = nil
    }
}

extension UserObject {
    var isCurrentUserObject: Bool {
        name != nil && created_at != nil && updated_at != nil && is_activated != nil && is_deleted != nil
    }
}
