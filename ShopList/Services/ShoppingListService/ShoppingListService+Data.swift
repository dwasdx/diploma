import Foundation
import CoreData
import WidgetKit

protocol ShoppingListDataServicable: AnyObject {
    var lastSentDataTimeStamp: Int { get set }
    var lastGetDataTimeStamp: Int { get set }
    
    func synchronize(token: String, fullUpdate: Bool, _ completion: ((ShoppingListServerError?) -> Void)?)
    func getAllData(token: String, completion: @escaping (Result<GetDataObject?, ShoppingListServerError>) -> Void)
    func acceptShare(shareId: String, _ completion: @escaping ((ShoppingListServerError?) -> Void))
}

extension ShoppingListService: ShoppingListDataServicable {
    
    static let syncQueue = DispatchQueue(label: "SyncQueue")
    
    var lastSentDataTimeStamp: Int {
        get {
            UserDefaults.standard.integer(forKey: "lastSentDataTimeStamp")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "lastSentDataTimeStamp")
        }
    }
    
    var lastGetDataTimeStamp: Int {
        get {
            UserDefaults.standard.integer(forKey: "lastGetDataTimeStamp")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "lastGetDataTimeStamp")
        }
    }
    
    private func fetchData(token: String, fullUpdate: Bool = false, _ completion: @escaping (Result<GetDataObject?, ShoppingListServerError>) -> Void) {
        guard CurrentUserManager.shared.isLoggedIn.value else {
            return
        }
        let request = GetDataRequest(token: token, fullUpdate: fullUpdate)
        makeRequestAndParseResponce(request, completion: completion)
    }
    
    private func sentData(token: String, _ completion: ((ShoppingListServerError?) -> Void)?) {
        let backgroundContext = CoreDataService.newBackgroundContext()
        guard CurrentUserManager.shared.isLoggedIn.value else {
            return
        }
        var objectsToBeDeleted = [NSManagedObject]()
        var listsEntities = (CoreDataService.shared.getEntities(entity: .shoppingList(), contextType: .specific(backgroundContext)) as? [ShoppingListEntity])?.filter { (listEntity) -> Bool in
            if listEntity.isdeleted {
                objectsToBeDeleted.append(listEntity)
            }
            return listEntity.updatedAt > lastSentDataTimeStamp && listEntity.ownerId == CurrentUserManager.shared.userIdentifier
        }
        
        var itemsEntities = (CoreDataService.shared.getEntities(entity: .product(), contextType: .specific(backgroundContext)) as? [ProductEntity])?.filter { (itemEntity) -> Bool in
            if itemEntity.isdeleted {
                objectsToBeDeleted.append(itemEntity)
            }
            return itemEntity.updatedAt > lastSentDataTimeStamp
        }
        var sharesEntities = (CoreDataService.shared.getEntities(entity: .share(), contextType: .specific(backgroundContext)) as? [ShareEntity])?.filter { (shareEntity) -> Bool in
            if shareEntity.isdeleted {
                objectsToBeDeleted.append(shareEntity)
            }
            
            return shareEntity.updatedAt > lastSentDataTimeStamp
        }
        // sometimes needed for debugging
//        var listsEntities = (CoreDataService.shared.getEntities(entity: .shoppingList()) as? [ShoppingListEntity])?.filter {
//            $0.ownerId == CurrentUserManager.shared.userIdentifier
//        }
//        var itemsEntities = (CoreDataService.shared.getEntities(entity: .product()) as? [ProductEntity])?.filter {_ in
//            true
//        }
//        var sharesEntities = (CoreDataService.shared.getEntities(entity: .share()) as? [ShareEntity])?.filter {_ in
//            true
//        }
        listsEntities = listsEntities?.isEmpty ?? true ? nil : listsEntities
        itemsEntities = itemsEntities?.isEmpty ?? true ? nil : itemsEntities
        sharesEntities = sharesEntities?.isEmpty ?? true ? nil : sharesEntities
        
        let currentUserEntity = [CoreDataService.shared.getEntities(entity: .currentUser(), contextType: .specific(backgroundContext))?.first] as? [CurrentUserEntity]
        
        let users = currentUserEntity?.map(CurrentUserObject.init)
//        let users = [CurrentUserObject]()
        let items = itemsEntities?.map(ItemObject.init)
        let shares = sharesEntities?.map(ShareObject.init)
        var allLists: [ListObject] = []
        
        if let lists = listsEntities?.map(ListObject.init) {
            allLists.append(contentsOf: lists)
        }
        
        let request = SendDataRequest(token: token,
                                      SendDataObject(users: users,
                                                     lists: allLists,
                                                     items: items,
                                                     shares: shares))
        makeRequest(request) { (error) in
            if error == nil {
                self.lastSentDataTimeStamp = CurrentTimeManager.shared.getCurrentTime() - 2
                CoreDataService.shared.removeEntities(objectsToBeDeleted, in: .specific(backgroundContext))
                completion?(nil)
            }
            completion?(error)
        }
    }
    
    func synchronize(token: String, fullUpdate: Bool, _ completion: ((ShoppingListServerError?) -> Void)?) {
        ShoppingListService.syncQueue.sync {
            fetchData(token: token, fullUpdate: false) { (result) in
                switch result {
                case .success(let data):
                    self.lastGetDataTimeStamp = CurrentTimeManager.shared.getCurrentTime()
                    self.processFetchedObjects(data)
                    self.sentData(token: token, completion)
                case .failure(let error):
                    completion?(error)
                }
            }
        }
    }
    func acceptShare(shareId: String, _ completion: @escaping ((ShoppingListServerError?) -> Void)) {
        let request = AcceptShareRequest(shareId: shareId)
        makeRequestAndParseResponce(request) { (result: Result<AcceptShareResponse?, ShoppingListServerError>) in
            switch result {
                case .success(let resposne):
                    let backgroundContext = CoreDataService.newBackgroundContext()
                    resposne?.items?.forEach { (item) in
                        guard let entity = CoreDataService.shared.getEntity(entity: .product(), id: item.id, contextType: .specific(backgroundContext)) as? ProductEntity else {
                            if item.is_deleted == false {
                                _ = ProductEntity(object: item, context: backgroundContext)
                            }
                            return
                        }
                        if item.updated_at > entity.updatedAt {
                            entity.updateValues(fromObject: item, context: backgroundContext)
                        }
                    }
                case .failure(let error):
                    completion(error)
            }
        }
    }
    
    // initially for fetching data from server for widget
    func getAllData(token: String, completion: @escaping (Result<GetDataObject?, ShoppingListServerError>) -> Void) {
        let request = GetDataRequest(token: token, fullUpdate: true)
        makeRequestAndParseResponce(request, completion: completion)
    }
    
    private func processFetchedObjects(_ object: GetDataObject?) {
        guard let object = object else {
            return
        }
        
        let backgroundContext = CoreDataService.newBackgroundContext()
        
        object.users?.forEach { (user) in
            if user.isCurrentUserObject == false {
                guard let entity = CoreDataService.shared.getEntity(entity: .user(), id: user.id, contextType: .specific(backgroundContext)) as? UserEntity else  {
                    _ = UserEntity(object: user, context: backgroundContext)
                    return
                }
                entity.updateValues(fromObject: user)
            }
            
        }
        
        object.shares?.forEach { (share) in
            guard let entity = CoreDataService.shared.getEntity(entity: .share(), id: share.id, contextType: .specific(backgroundContext)) as? ShareEntity else {
                if share.is_deleted == false {
                    _ = ShareEntity(object: share, context: backgroundContext)
                }
                return
            }
            
            //MARK: Found a bug? (not sure)
            //MARK: When the other user(member) left the list, the update stamp does not change, but "(entity.status != 2 && share.status == 2)" solves the problem
            if share.updated_at > entity.updatedAt ||
                (entity.status != 2 && share.status == 2) ||
                (!entity.isdeleted && share.is_deleted) {
                guard entity.isdeleted == false else {
                    return
                }
                entity.updateValues(fromObject: share)
            }
        }
        object.items?.forEach { (item) in
            guard let entity = CoreDataService.shared.getEntity(entity: .product(), id: item.id, contextType: .specific(backgroundContext)) as? ProductEntity else {
                if item.is_deleted == false {
                    _ = ProductEntity(object: item, context: backgroundContext)
                }
                return
            }
            if item.updated_at > entity.updatedAt {
                entity.updateValues(fromObject: item, context: backgroundContext)
            }
        }
        object.lists?.forEach { (list) in
            
            let products = CoreDataService.shared.getProductsEntities(withListId: list.id, contextType: .specific(backgroundContext))
            let checkedProductsNumber = products.filter { $0.isMarked == true }.count
            let productsNumber = products.count
          
            
            if list.is_template {
            } else {
            guard let entity = CoreDataService.shared.getEntity(entity: .shoppingList(), id: list.id, contextType: .specific(backgroundContext)) as? ShoppingListEntity else {
                
                if list.is_deleted == false {
                    _ = ShoppingListEntity(object: list, checkedProductsNumber: checkedProductsNumber, productsNumber: productsNumber, in: backgroundContext)
                }
                return
            }
            if list.updated_at > entity.updatedAt {
                entity.updateValues(fromObject: list, checkedProductsNumber: checkedProductsNumber, productsNumber: productsNumber, in: backgroundContext)
                }
            }
        }
        
        
        //MARK: Removing rejected lists from the screen
        let lists = CoreDataService.shared.getPresentedLists(in: .specific(backgroundContext))
        for list in lists {
            
            let updatedToBePresented = CoreDataService.shared.listToBePresented(listId: list.id, listOwnerId: list.ownerId, context: backgroundContext)
            if list.toBePresented != updatedToBePresented {
                list.toBePresented = updatedToBePresented
            }
        }
        
        CoreDataService.saveContext(backgroundContext)
    }
    
}
