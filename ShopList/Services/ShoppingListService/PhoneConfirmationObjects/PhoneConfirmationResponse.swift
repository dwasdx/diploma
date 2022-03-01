import Foundation

struct PhoneConfirmationResponse: Codable {
    let user_id: String //to be removed
    let access_token: String
    let expires_at: Int
    let user: UserObject
}
