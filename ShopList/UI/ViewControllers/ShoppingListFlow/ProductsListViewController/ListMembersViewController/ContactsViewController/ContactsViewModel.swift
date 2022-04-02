import Foundation

enum ContactType: Hashable {
    case contact
}

class ContactsViewModel: BaseViewModel {
            
    private var sectionsAdded = [Character]() {
        didSet {
            sectionsAdded.sort()
        }
    }
    private var contactsAdded = [Character: [ListMemberModel]]()
    private let contactsLock = NSLock()
    
    private var sectionsFiltered = [Character]() {
        didSet {
            sectionsFiltered.sort()
        }
    }
    private var contactsFiltered = [Character: [ListMemberModel]]()
    
    var isFiltering = false
    
    private var contacts = [ListMemberModel]()
    
    var filter: String? {
        didSet {
            guard filter != nil else {
                return
            }
            if filter!.isEmpty == true {
                sectionsFiltered.removeAll()
                contactsFiltered.removeAll()
            }
            applyFilter()
        }
    }
    
    var didRecieveDeniedAccessToContacts: ((String) -> Void)?
    var didRecieveCheckContactsError: ((String) -> Void)?
    
    var listId: String
    
    let userManager: CurrentUserManaging
    let syncService: SynchronizationServiceable
    
    init(
        listId: String,
        userManager: CurrentUserManaging = CurrentUserManager.shared,
        syncService: SynchronizationServiceable = SynchronizationService.shared
    ) {
        self.listId = listId
        self.userManager = userManager
        self.syncService = syncService
        super.init()
    }
    
    private func applyFilter() {
        guard let filterName = filter else {
            return
        }
        var dictionary = [Character: [ListMemberModel]]()
        for (key, value) in contactsAdded {
            let filteredContacts = value.filter { $0.name.lowercased().contains(filterName.lowercased()) }
            if filteredContacts.isEmpty == false {
                dictionary[key] = filteredContacts
            }
        }
        contactsFiltered = dictionary
        
        sectionsFiltered = Array<Character>(dictionary.keys)
        didChange?()
    }
    
    private func checkContacts(_ phoneNumbers: [Int]) {
        ShoppingListService.shared.checkUsersRegistrationStatus(phoneNumbers) { [weak self] (result) in
            guard let self = self else {
                return
            }
            self.contactsLock.lock()
            defer {
                self.contactsLock.unlock()
            }
            switch result {
                case .success(let response):
                    for (key, contacts) in self.contactsAdded {
                        let checkedContacts = contacts.map { (contact) -> ListMemberModel in
                            let phoneNumber = contact.phoneNumber.decimalString
                            var contact = contact
                            if let isContactInApp = response?[phoneNumber] {
                                contact.isInApp = isContactInApp
                            }
                            return contact
                        }
                        self.contactsAdded[key] = checkedContacts
                    }
                    self.didChange?()
                case .failure(let error):
                    self.didRecieveDeniedAccessToContacts?(error.message)
            }
        }
    }
    
    private func syncDataBase() {
        if let token = userManager.userToken {
            syncService.synchronizeDatabaseWithDelay(token: token, fullUpdate: false)
        }
    }
}

extension ContactsViewModel: ContactsViewModeling {
    var items: [[ListMemberModel]] {
        if isFiltering {
            return sectionsFiltered.compactMap { (char) -> [ListMemberModel]? in
                contactsFiltered[char]
            }
        } else {
            return sectionsAdded.compactMap { (char) -> [ListMemberModel]? in
                contactsAdded[char]
            }
        }
    }
    
    var sections: [Character] {
        isFiltering ? sectionsFiltered : sectionsAdded
    }
    
    var isEmptyModel: Bool {
        isFiltering ? contactsFiltered.isEmpty : contactsAdded.isEmpty
    }
    
    func getMemberViewModel(_ indexPath: IndexPath) -> ListMemberModel? {
        isFiltering ? contactsFiltered[sectionsFiltered[indexPath.section]]?[indexPath.row] : contactsAdded[sectionsAdded[indexPath.section]]?[indexPath.row]
    }
    
    func getSectionTitle(for section: Int) -> Character? {
        isFiltering ? sectionsFiltered[section] : sectionsAdded[section]
    }
    
    func addMemberToList(on indexPath: IndexPath, _ completion: (() -> Void)) {
        guard let contact = getMemberViewModel(indexPath) else {
            return
        }
        if !contact.isInApp {
            completion()
        }
    }
    
    func createNewUser(indexPath: IndexPath) {
        guard var contact = getMemberViewModel(indexPath) else {
            return
        }
        if let userEntity = CoreDataService.shared.getUser(byPhoneNumber: contact.phoneNumber, in: .view) {
            let share = ShareModel(listId: self.listId, toUserId: userEntity.id, status: 0)
            CoreDataService.shared.addEntity(entity: .share(share), contextType: .view)
            syncDataBase()
            self.changeContact(&contact, indexPath: indexPath)
        } else {
            ShoppingListService.shared.getUser(byPhoneNumber: contact.phoneNumber.decimalString) { [weak self] (result) in
                guard let self = self else {
                    return
                }
                switch result {
                    case .success(let response):
                        guard let response = response else {
                            return
                        }
                        let userObject = UserObject(fromGetUserResponse: response)
                        CoreDataService.shared.addEntity(entity: .user(userObject), contextType: .view)
                        let share = ShareModel(listId: self.listId, toUserId: response.id, status: 0)
                        CoreDataService.shared.addEntity(entity: .share(share), contextType: .view)
                        self.syncDataBase()
                        self.changeContact(&contact, indexPath: indexPath)
                    case .failure(let error):
                        print(error)
                }
        }
    }
    }
    
    private func changeContact(_ contact: inout ListMemberModel, indexPath: IndexPath) {
        let letter = self.isFiltering ? self.sectionsFiltered[indexPath.section] : self.sectionsAdded[indexPath.section]
        guard let indexAdded = self.contactsAdded[letter]?.firstIndex(where: { $0.id == contact.id }) else {
            return
        }
        contact.status = .invited
        self.contactsAdded[letter]?[indexAdded] = contact
        if let indexFiltering = self.contactsFiltered[letter]?.firstIndex(where: { $0.id == contact.id }) {
            self.contactsFiltered[letter]?[indexFiltering] = contact
        }
        self.didChange?()
    }
    
    private func addFetchedContact(_ contact: ListMemberModel, toSection section: Character) {
        contacts.append(contact)
        if self.contactsAdded.keys.contains(section) {
            self.contactsAdded[section]?.append(contact)
        } else {
            self.contactsAdded[section] = [contact]
            self.sectionsAdded.append(section)
        }
    }
    
    func fetchContacts() {
        //background is recommended according to Apple documentation
        DispatchQueue(label: "com.shoppinglist.contactsfetch", qos: .utility, attributes: [], autoreleaseFrequency: .workItem, target: nil).async { [weak self] in
            
            let shares = CoreDataService.shared.getShareEntites(byListId: self?.listId ?? "", in: .view)
            var phoneNumbers = [Int]()
            do {
                try ContactsManager.shared.iterateAllContacts { (contact, stop) in
                    guard let self = self else {
                        return
                    }
                    guard contact.phoneNumbers.first?.value.stringValue.decimalString != CurrentUserManager.shared.userPhoneNumber else {
                        return
                    }
                    let name = ContactsManager.shared.getFullName(for: contact) ?? ""
                    let phone = contact.phoneNumbers.first?.value.stringValue ?? ""
                    if let phoneNumber = Int(phone.decimalString) {
                        phoneNumbers.append(phoneNumber)
                    }
                    if let userEntity = CoreDataService.shared.getUser(byPhoneNumber: phone, in: .view),
                        let share = shares.first(where: { ($0.toUserId == userEntity.id || $0.ownerId == userEntity.id) && $0.listId == self.listId }) {
                        let currentStatus = ListMemberModel.MembershipStatus(rawValue: Int(share.status)) ?? .notInvited
                        let status = share.isdeleted ? ListMemberModel.MembershipStatus.notInvited : currentStatus
                        let member = ListMemberModel(id: userEntity.id, name: name, status: status, phoneNumber: phone)
                        guard let letter = member.name.first?.uppercased().first else {
                            self.addFetchedContact(member, toSection: "#")
                            return
                        }
                        self.addFetchedContact(member, toSection: letter)
                    } else {
                        let member = ListMemberModel(id: NSUUID().uuidString.lowercased(),
                                                     name: name,
                                                     status: .notInvited,
                                                     phoneNumber: phone)
                        guard let letter = member.name.first?.uppercased().first else {
                            self.addFetchedContact(member, toSection: "#")
                            return
                        }
                        self.addFetchedContact(member, toSection: letter)
                    }
                }
                guard let self = self else {
                    return
                }
                phoneNumbers.chunked(into: 1000).forEach(self.checkContacts(_:))
                
                self.didChange?()
            } catch {
                self?.didRecieveDeniedAccessToContacts?("Доступ к контактам запрещен. Перейдите в настройки -> Конфиденциальность -> Контакты и разрешите приложению Shopping List доступ к контактам")
            }
        }
        
    }
}
