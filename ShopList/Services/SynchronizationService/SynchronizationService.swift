import Foundation

protocol SynchronizationServiceable {
    var loadingChanges: Emitter<Bool> { get }
    var sycnhronizationChanges: Emitter<ShoppingListServerError?> { get }
    
    func synchronizeDatabase(token: String, fullUpdate: Bool)
    func synchronizeDatabaseWithDelay(token: String, fullUpdate: Bool)
    func synchronize(token: String, fullUpdate: Bool, completion: @escaping ((ShoppingListServerError?) -> Void))
}

class SynchronizationService {
    
    var loadingChanges: Emitter<Bool> = Emitter(false)
    var sycnhronizationChanges: Emitter<ShoppingListServerError?> = Emitter(nil)
    
    var authenticationChangesToken: SignalSubscriptionToken? = nil
    
    private var isSynchronizationInProgress = false
    
    private var timer: Timer?
    
    private var delayedSynchronization: DispatchWorkItem!
    
    static let shared = SynchronizationService()
    private init() {
        authenticationChangesToken = CurrentUserManager.shared.isLoggedIn.signal.addListener(listenerBlock: { [weak self] (isLoggedIn) in
            if isLoggedIn == true {
                self?.startTimer()
                if CoreDataService.shared.getEntities(entity: .catalogCategory, contextType: .view) == nil {
                    self?.loadCatalog()
                }
                //                self?.synchronizeDatabase()
            } else {
                self?.stopTimer()
            }
        })
    }
    
    deinit {
        CurrentUserManager.shared.isLoggedIn.signal.removeListener(authenticationChangesToken)
    }
    
    private func loadCatalog() {
        ShoppingListService.shared.getCatalog { (error) in
            print(error)
        }
    }
    
    //inspired by https://stackoverflow.com/questions/38695802/timer-scheduledtimer-swift-3-pre-ios-10-compatibility/43993602#43993602
    //written for swift 3, but same thing is for swift 5
    
    private func startTimer() {
        guard timer == nil else {
            return
        }
        timer = Timer.scheduledTimer(timeInterval: 60 * 5, target: self, selector: #selector(syncDatabaseInTimer), userInfo: nil, repeats: true)
    }
    
    private func stopTimer() {
        guard timer != nil else {
            return
        }
        timer?.invalidate()
        timer = nil
    }
    
    func configure() {
        
    }
    
    @objc private func syncDatabaseInTimer() {
        guard let token = CurrentUserManager.shared.userToken else {
            return
        }
        synchronizeDatabaseWithDelay(token: token)
    }
    
}

extension SynchronizationService: SynchronizationServiceable {
    @objc func synchronizeDatabase(token: String, fullUpdate: Bool = false) {
        guard CurrentUserManager.shared.isLoggedIn.value == true else {
            return
        }
        guard isSynchronizationInProgress == false else {
            print("synch in progress")
            return
        }
        loadingChanges.value = true
        isSynchronizationInProgress = true
        ShoppingListService.shared.synchronize(token: token, fullUpdate: fullUpdate) { (error) in
            self.isSynchronizationInProgress = false
            self.loadingChanges.value = false
            self.sycnhronizationChanges.value = error
        }
    }
    
    @objc func synchronizeDatabaseWithDelay(token: String, fullUpdate: Bool = false) {
        
        delayedSynchronization?.cancel()
        delayedSynchronization = DispatchWorkItem { [weak self] in
            
            guard let self = self, CurrentUserManager.shared.isLoggedIn.value == true, self.delayedSynchronization?.isCancelled == false else {
                return
            }
            
            self.loadingChanges.value = true
            self.isSynchronizationInProgress = true
            
            ShoppingListService.shared.synchronize(token: token, fullUpdate: fullUpdate) { (error) in
                self.isSynchronizationInProgress = false
                self.loadingChanges.value = false
                self.sycnhronizationChanges.value = error
            }
        }
        
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 1, execute: delayedSynchronization)
        
    }
    
    func synchronize(token: String, fullUpdate: Bool = false, completion: @escaping ((ShoppingListServerError?) -> Void)) {
        
        guard loadingChanges.value == false else {
            completion(nil)
            return
        }

        loadingChanges.value = true
        self.isSynchronizationInProgress = true
        ShoppingListService.shared.synchronize(token: token, fullUpdate: false) { (error) in
            self.isSynchronizationInProgress = false
            self.loadingChanges.value = false
            completion(error)
        }
    }
    
    func acceptShare(_ id: String) {
        ShoppingListService.shared.acceptShare(shareId: id) { (error) in
            if let error = error {
                print(error)
                //TBD error handling
            }
        }
    }
}
