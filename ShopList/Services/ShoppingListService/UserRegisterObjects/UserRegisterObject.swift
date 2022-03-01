import Foundation

struct UserRegisterObject: Codable {
    let username: String
    let phone: Int
    let email: String?
}
