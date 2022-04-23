import Foundation

struct GetUserResponse: Codable {
    let id: String
    let phone: Int
    let is_activated: Bool
}
