import Foundation

struct GetNotificationsResponse: Codable {
    let total: Int
    let items: [NotificationObject]?
}

struct NotificationObject: Codable {
    let id: String
    let message: String
    let created_at: Int
    let type: Int
    let list_id: String
}
