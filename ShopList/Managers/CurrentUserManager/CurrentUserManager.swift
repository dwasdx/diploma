import Foundation

protocol CurrentUserManaging {
    var currentUser: Emitter<CurrentUserModel?>? { get }
    var userToken: String? { get  set }
    var userIdentifier: String { get set }
    
    func setUser(currentUser: CurrentUserModel)
    func changeName(newName: String)
//    func changePhone(newPhone: String)
//    func approvePhone()
//    func changeEmail(newEmail: String)
//    func approveEmail()
}

class CurrentUserManager: CurrentUserManaging {
    
    var currentUser: Emitter<CurrentUserModel?>?
    
    private var currentUserEntity: CurrentUserEntity? {
        return CoreDataService.shared.getEntities(entity: .currentUser(), contextType: .view)?.first as? CurrentUserEntity
    }
    
    private var userId: String = ""
    
    var userIdentifier: String {
        get {
            currentUser?.value?.id ?? userId
        }
        set {
            userId = newValue
            currentUser?.value?.id = newValue
        }
    }
    
    var isLoggedIn: Emitter<Bool>
    
    var userToken: String? {
        get {
            guard let data = KeychainService.shared.getItem(forKey: "userToken") else {
                return nil
            }
            return String(data: data, encoding: .utf8)
        }
        set {
            guard let token = newValue else {
                isLoggedIn.value = false
                UserDefaults.standard.set(isLoggedIn.value, forKey: "isLoggedIn")
                KeychainService.shared.removeItem(forKey: "userToken")
                return
            }
            KeychainService.shared.setItem(token, forKey: "userToken")
            isLoggedIn.value = token.isEmpty == false
            UserDefaults.standard.set(isLoggedIn.value, forKey: "isLoggedIn")

        }
    }
    
    var userPhoneNumber: String {
        currentUser?.value?.phone ?? ""
    }
    
    static let shared = CurrentUserManager()
    
    private init() {
        self.isLoggedIn = Emitter<Bool>(UserDefaults.standard.bool(forKey: "isLoggedIn"))
        
        guard let currentUserEntity = self.currentUserEntity else {
            return
        }
        let user = CurrentUserModel(entity: currentUserEntity)
        self.currentUser = Emitter(nil)
        self.setUser(currentUser: user)
        
    }
    
    func setUser(currentUser: CurrentUserModel) {
        if self.currentUser != nil {
            self.currentUser?.value = currentUser
        } else {
            self.currentUser = Emitter(currentUser)
        }
        
        let backgroundContext = CoreDataService.newBackgroundContext()
        if let existingUser = self.currentUserEntity {
            CoreDataService.shared.removeEntity(entity: .user(), id: existingUser.id, contextType: .specific(backgroundContext))
        }
        CoreDataService.shared.addEntity(entity: .currentUser(currentUser), contextType: .specific(backgroundContext))
        CoreDataService.saveContext(backgroundContext)
    }
    
    func setUser(fromUserResponse response: UserObject?) {
        guard let response = response, response.isCurrentUserObject == true else {
            return
        }
        let phone = String(response.phone)
        let user = CurrentUserModel(id: response.id,
                                    name: response.name!,
                                    phone: phone,
                                    isActivated: true,
                                    email: response.email)
        setUser(currentUser: user)
    }
    
    func logOut(_ completion: (() -> Void)? = nil) {
        guard let token = userToken else {
            fatalError("Logging out from unauthenticated user")
        }
        SynchronizationService.shared.synchronize(token: token) { [weak self] (error) in
// MAYBE WILL BE DEVELOPED IN FUTURE:
//            if let error = error {
//                print(error) //TBD
//                return
//            }
            self?.currentUser = nil
            self?.userIdentifier = ""
            self?.userToken = nil
            ShoppingListService.shared.lastSentDataTimeStamp = 0
            ShoppingListService.shared.lastGetDataTimeStamp = 0
            UserDefaults.standard.set(0, forKey: "userRating")
            
            let backgroundContext = CoreDataService.newBackgroundContext()
            CoreDataService.shared.clearAllCoreData(in: .specific(backgroundContext))
            CoreDataService.saveContext(backgroundContext)
            completion?()
//            FCMTokenManager.shared.remove {
//                
//            }
        }
        
    }
    
    func changeName(newName: String) {
        guard let currenUserEntity = self.currentUserEntity else {
            return
        }
        currenUserEntity.name = newName
        currenUserEntity.updatedAt = Int64(CurrentTimeManager.shared.getCurrentTime())
        self.currentUser?.value?.name = newName
        self.currentUser?.value?.updatedAt = CurrentTimeManager.shared.getCurrentTime()
        
        CoreDataService.saveViewContext()
    }
    
//    func changePhone(newPhone: String) {
//        guard let currenUserEntity = self.currentUserEntity else {
//            return
//        }
//        currenUserEntity.phone = newPhone
//        self.currentUser?.value?.phone = newPhone
//        self.currentUser?.value?.isActivated = false
//        CoreDataService.shared.saveChanges()
//    }
//
//    func approvePhone() {
//        self.currentUser?.value?.isActivated = true
//    }
//
//    func changeEmail(newEmail: String) {
//        guard let currenUserEntity = self.currentUserEntity else {
//            return
//        }
//        currenUserEntity.email = newEmail
//        self.currentUser?.value?.email = newEmail
//        self.currentUser?.value?.emailApproved = false
//        CoreDataService.shared.saveChanges()
//    }
//
//    func approveEmail() {
//        guard let currenUserEntity = self.currentUserEntity else {
//            return
//        }
//        currenUserEntity.emailApproved = true
//        self.currentUser?.value?.emailApproved = true
//        CoreDataService.shared.saveChanges()
//    }
    
}
