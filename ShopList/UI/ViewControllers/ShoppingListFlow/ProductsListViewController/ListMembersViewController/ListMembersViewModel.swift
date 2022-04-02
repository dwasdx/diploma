import Foundation
import CoreData

enum MemberType: Hashable {
    case member, notMember
}

class ListMembersViewModel: BaseViewModel {
    
    private enum Constants {
        static let listMembersIndex = 0
        static let awaitingMembersIndex = 1
        
        static let invitedStatus = 0
        static let acceptedStatus = 1
        static let rejectedStatus = 2
    }
    
    var didFailSynchronization: ((String) -> Void)?
    
    private var members: [[ListMemberModel]] = [[], []]
    private var sectionsCategories = [
        ListMemberCategoryModel(title: "Все участники", position: .first),
        ListMemberCategoryModel(title: "Ожидают подтверждения", position: .second),
    ]
    
    private var membersListFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>
    var synchronizationChangesToken: SignalSubscriptionToken?
    var loadingChangesToken: SignalSubscriptionToken?
    
    let listId: String
    
    let userManager: CurrentUserManaging
    let syncService: SynchronizationServiceable
    
    init(
        listId: String,
        userManager: CurrentUserManaging = CurrentUserManager.shared,
        syncService: SynchronizationServiceable = SynchronizationService.shared
    ) {
        self.userManager = userManager
        self.syncService = syncService
        self.listId = listId
        
        membersListFetchedResultsController = CoreDataService.shared.createMembersListFetchedResultsController(listId: listId)
        
        super.init()
        
        setupMembersListFetchedResultsController()

        synchronizationChangesToken = syncService.sycnhronizationChanges.signal.addListener(listenerBlock: { (error) in
            print(error?.localizedDescription ?? "")
        })
        loadingChangesToken = syncService.loadingChanges.signal.addListener(listenerBlock: { [weak self] (isLoading)in
            self?.isLoading = isLoading
        })
    }
    
    deinit {
        
        syncService.loadingChanges.signal.removeListener(self.loadingChangesToken)
        syncService.sycnhronizationChanges.signal.removeListener(self.synchronizationChangesToken)
    }
    
    private func setupMembersListFetchedResultsController() {
        membersListFetchedResultsController.delegate = self
        do {
            try membersListFetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
        guard let initialValues = membersListFetchedResultsController.fetchedObjects as? [ShareEntity] else {
            return
        }
        let shares = initialValues.map {
            ShareModel(entity: $0)
        }
        
        self.members = [[], []]
        shares.forEach { (share) in
            guard share.membershipStatus != .refused else {
                return
            }
            self.changeMemberInArray(share: share, handler: { (memberModel, _, sectionIndex) in
                guard self.members[sectionIndex].contains(where: { $0.id == share.id }) == false else {
                    return
                }
                self.members[sectionIndex].append(memberModel)
            })
        }
    }
    
    private func changeMemberInArray(share: ShareModel, handler: ((ListMemberModel, UserEntity, Int) -> Void)) {
        let sectionIndex = share.membershipStatus == .invited ? Constants.awaitingMembersIndex : Constants.listMembersIndex
        let userId = share.toUserId == CurrentUserManager.shared.userIdentifier ? share.ownerId : share.toUserId
        guard let userEntity = CoreDataService.shared.getEntity(entity: .user(), id: userId, contextType: .view) as? UserEntity else {
            return
        }
        let name = ContactsManager.shared.getContact(byPhoneNumber: userEntity.phone.description)?.name
        guard let member = ListMemberModel(name: name,
                                           status: share.status,
                                           phoneNumber: userEntity.phone.description,
                                           id: share.id) else {
            return
        }
        handler(member, userEntity, sectionIndex)
    }
    
    // there were cases when fetched results controller did not give signal about .initial state
    // this method is just for debugging, but may also be used in production as support
//    private func updateData() {
//        CoreDataService.shared.sharesToOtherUsersFetchedResultsController.fetchedObjects?
//            .filter { ($0 as? ShareEntity)?.listId == self.listId }
//            .forEach { (share) in
//                guard let shareEntity = share as? ShareEntity,
//                      shareEntity.membershipStatus ?? .notInvited != .refused else {
//                    return
//                }
//                let shareModel = ShareModel(entity: shareEntity)
//                self.changeMemberInArray(share: shareModel) { (member, userEntity, sectionIndex) in
//                    self.members[sectionIndex].append(member)
//                }
//
//            }
//    }
    
}

extension ListMembersViewModel: ListMembersViewModeling {
    
    var isEmptyModel: Bool {
        members[Constants.listMembersIndex].isEmpty && members[Constants.awaitingMembersIndex].isEmpty
    }
    
    var sections: [MemberType] {
        var sections = [MemberType]()
        if members[Constants.listMembersIndex].isEmpty == false {
            sections.append(.member)
        }
        if members[Constants.awaitingMembersIndex].isEmpty == false {
            sections.append(.notMember)
        }
        return sections
    }
    
    var items: [[ListMemberModel]] {
        var array = [[ListMemberModel]]()
        if members[Constants.listMembersIndex].isEmpty == false {
            array.append(members[Constants.listMembersIndex])
        }
        if members[Constants.awaitingMembersIndex].isEmpty == false {
            array.append(members[Constants.awaitingMembersIndex])
        }
        return array
    }
    
    func addNewMember(_ member: ListMemberModel) {
        switch member.status {
        case .member:
            self.members[Constants.listMembersIndex].append(member)
        case .invited:
            self.members[Constants.awaitingMembersIndex].append(member)
        case .notInvited, .refused:
            break
        }
    }
    
    func removeFromList(memberOnIndexPath indexPath: IndexPath) {
        let sectionIndex = members[0].isEmpty ? 1 : indexPath.section
        guard members.indices ~= sectionIndex,
              members[sectionIndex].indices ~= indexPath.row else {
            return
        }
        let memberModel = members[sectionIndex][indexPath.row]
        guard let shareEntity = CoreDataService.shared.getEntity(entity: .share(), id: memberModel.shareId, contextType: .view) as? ShareEntity else {
            return
        }
        shareEntity.isdeleted = true
        shareEntity.updatedAt = Int64(CurrentTimeManager.shared.getCurrentTime())
        CoreDataService.saveViewContext()
        if let token = userManager.userToken {
            syncService.synchronizeDatabase(token: token, fullUpdate: false)
        }
    }
    
    func getCategoryModel(forSection section: Int) -> ListMemberCategoryModel? {
        let sectionsArray = sections
        if sectionsArray.count == 0 {
            return nil
        } else if sectionsArray.count == sectionsCategories.count {
            return sectionsCategories[section]
        } else if sectionsArray[0] == .member {
            return sectionsCategories[0]
        } else if sectionsArray[0] == .notMember {
            return sectionsCategories[1]
        }
        return nil
    }
    
    func sync() {
        if let token = userManager.userToken {
            syncService.synchronizeDatabase(token: token, fullUpdate: false)
        }
    }
    
}


extension ListMembersViewModel: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        defer {
            didChange?()
        }
        
        switch controller.fetchRequest.entity?.name {
        
        case "ShareEntity":
            switch type {
            
            case .move, .insert, .update, .delete:
                guard let initialValues = membersListFetchedResultsController.fetchedObjects as? [ShareEntity] else {
                    return
                }
                let shares = initialValues.map {
                    ShareModel(entity: $0)
                }
                
                self.members = [[], []]
                shares.forEach { (share) in
                    guard share.membershipStatus != .refused else {
                        return
                    }
                    self.changeMemberInArray(share: share, handler: { (memberModel, _, sectionIndex) in
                        guard self.members[sectionIndex].contains(where: { $0.id == share.id }) == false else {
                            return
                        }
                        self.members[sectionIndex].append(memberModel)
                    })
                }
                break
                
            @unknown default:
                print("ERROR")
            }
            
        case .none, .some(_):
            return
        }
    }
    
}

