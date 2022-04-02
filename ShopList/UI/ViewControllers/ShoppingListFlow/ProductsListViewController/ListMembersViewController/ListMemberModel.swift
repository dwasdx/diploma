import Foundation

protocol ListMemberModeling {
    var name: String { get }
}

struct ListMemberModel: ListMemberModeling, Hashable {
    
    enum MembershipStatus: Int {
        case notInvited = -1 //not in server
        case invited = 0
        case member = 1
        case refused = 2
    }
    
    let id: String
    let name: String
    let phoneNumber: String
    var status: MembershipStatus
    var isInApp: Bool = false
    
    var shareId: String {
        id
    }
    
    init(id: String, name: String, status: MembershipStatus, phoneNumber: String) {
        self.id = id
        self.name = name
        self.status = status
        self.phoneNumber = phoneNumber
    }
    
    init?(name: String?, status: Int, phoneNumber: String, id: String = UUID().uuidString.lowercased()) {
        self.id = id
        if let name = name {
            self.name = name
        } else {
            self.name = PhoneNumberManager.shared.formatPhoneNumber(phoneNumber)
        }
        guard let status = MembershipStatus(rawValue: status) else {
            return nil
        }
        self.status = status
        self.phoneNumber = phoneNumber
    }
    
    init(fromContact contact: ContactModel) {
        self.id = UUID().uuidString.lowercased()
        self.name = contact.name
        self.status = .invited
        self.phoneNumber = contact.phoneNumber
    }
}
