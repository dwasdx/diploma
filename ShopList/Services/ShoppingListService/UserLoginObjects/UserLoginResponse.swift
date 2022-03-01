import Foundation

struct UserLoginResponse: Codable {
    let user_id: String
    let next_time_request: Int
}
