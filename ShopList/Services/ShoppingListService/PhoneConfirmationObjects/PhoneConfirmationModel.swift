import Foundation

struct PhoneConfirmationModel: Codable {
    let user_id: String
    let code: String
    
    init(_ code: String) {
        let idString = CurrentUserManager.shared.userIdentifier
        guard idString != "" else {
            fatalError("current user does not exist")
        }
//        guard  let id = Int(idString) else {
//            fatalError("Wrong type of idString which value is \(idString)")
//        }
        self.user_id = idString
        self.code = code
    }
}
