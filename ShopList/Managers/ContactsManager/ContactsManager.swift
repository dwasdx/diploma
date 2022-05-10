import Foundation
import Contacts

class ContactsManager {
    
    static let shared = ContactsManager()
    private init() {}
    
    let store = CNContactStore()
    private var contacts = [CNContact]()
    
    func iterateAllContacts(_ contactHandler: @escaping ((CNContact, UnsafeMutablePointer<ObjCBool>) -> Void)) throws {
        let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey as CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keys)
        self.contacts.removeAll()
        try store.enumerateContacts(with: request, usingBlock: { (contact, stop) in
            self.contacts.append(contact)
            contactHandler(contact, stop)
        })
    }
    
    func getContact(byPhoneNumber phone: String) -> ContactModel? {
        if contacts.isEmpty {
            try? iterateAllContacts({ _,_ in })
        }
        for contact in contacts {
            if let phoneNumber = contact.phoneNumbers.first?.value.stringValue, phoneNumber.decimalString == phone.decimalString {
                let name = CNContactFormatter.string(from: contact, style: .fullName) ?? ""
                let contactModel = ContactModel(id: UUID().uuidString, name: name, phoneNumber: phoneNumber.decimalString)
                return contactModel
            }
        }
        return nil
//        contacts.first(where: { $0.phoneNumbers.first?.value.stringValue.decimalString ?? "NA" == phoneNumber.decimalString })
    }
    
    func getFullName(for contact: CNContact) -> String? {
        return CNContactFormatter.string(from: contact, style: .fullName)
    }
    
}
