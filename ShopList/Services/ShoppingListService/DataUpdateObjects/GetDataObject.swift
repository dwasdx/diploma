import Foundation

struct GetDataObject: Codable {
    let users: [UserObject]?
    let lists: [ListObject]?
    let items: [ItemObject]?
    let shares: [ShareObject]?
}
