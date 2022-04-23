import Foundation

struct SendDataObject: Codable {
    let users: [CurrentUserObject]?
    let lists: [ListObject]?
    let items: [ItemObject]?
    let shares: [ShareObject]?
}
