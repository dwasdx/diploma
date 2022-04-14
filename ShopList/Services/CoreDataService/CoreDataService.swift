import Foundation
import CoreData

//MARK: EntitiesEnum

//TODO: add entities for shares and users
enum Entities {
    case shoppingList(_ model: ShoppingListModel? = nil)
    case product(_ model: ProductModel? = nil)
    case currentUser(_ model: CurrentUserModel? = nil)
    case user(_ model: UserObject? = nil)
    case share(_ model: ShareModel? = nil)
    case catalogCategory
    case catalogProduct
}

//MARK: Context

enum Context {
    case view
    case specific(NSManagedObjectContext)
    
    var context: NSManagedObjectContext {
        switch self {
        case .view:
            return CoreDataService.viewContext
        case .specific(let specificContext):
            return specificContext
        }
    }
}

//MARK: ChangesEnum

enum CoreDataChanges<T>: Equatable {
    
    static func == (lhs: CoreDataChanges<T>, rhs: CoreDataChanges<T>) -> Bool {
        return false
    }
    
    case insert(IndexPath, T)
    case update(IndexPath, T)
    case delete(IndexPath, T?)
    case initial([T])
}

//MARK: ServiceProtocol

protocol CoreDataServiceable {
    
    static var shared: CoreDataService { get }
    
    // general methods
    
    func getEntity(entity: Entities, id: String, contextType: Context) -> NSManagedObject?
    func getEntities(entity: Entities, contextType: Context) -> [NSManagedObject]?
    func addEntity(entity: Entities, contextType: Context)
    func removeEntity(entity: Entities, id: String?, contextType: Context)
    func removeEntities(_ entities: [NSManagedObject], in contextType: Context)
        
    // specific entities methods
    
    func getUser(byPhoneNumber phone: String, in contextType: Context) -> UserEntity?
    
    func getPresentedLists(in contextType: Context) -> [ShoppingListEntity]
    func maxPresentedListPosition(in contextType: Context) -> Double
    func positionBeforeFirstCompletedList(in contextType: Context) -> Double
    func listToBePresented(listId: String, listOwnerId: String, context: NSManagedObjectContext) -> Bool
    func getNumberOfActiveShares(for listId: String, context: NSManagedObjectContext) -> Int

    func getProductsEntities(withListId listId: String, contextType: Context) -> [ProductEntity]
    
    func getShareEntites(byListId listId: String, in contextType: Context) -> [ShareEntity]
    func acceptShare(model: ShareModel, in contextType: Context)
    func rejectShare(model: ShareModel, in contextType: Context)
    
    func clearAllCoreData(in contextType: Context)
    
    // Fetched Results Controllers
    
    func createShoppingListsFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult>
    func createProductsFetchedResultsController(listId: String) -> NSFetchedResultsController<NSFetchRequestResult>
    func createInvitationsFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult>
    func createMembersListFetchedResultsController(listId: String) -> NSFetchedResultsController<NSFetchRequestResult>
    func createSharesFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult>
    
    // Stack
    
    static var viewContext: NSManagedObjectContext { get }
    static func saveViewContext()
    
    static func newBackgroundContext() -> NSManagedObjectContext
    static func saveContext(_ context: NSManagedObjectContext)
}

//MARK: General

class CoreDataService: NSObject, CoreDataServiceable {
    
    
    
    // MARK: Singleton
    static let shared = CoreDataService()
    private override init() {
        super.init()
        
    }
    
    // MARK: General methods
    
    func entityForName(entityName: String) -> NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: entityName, in: CoreDataService.viewContext)!
    }
    
    func getEntity(entity: Entities, id: String, contextType: Context) -> NSManagedObject? {
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
        
        let context = contextType.context
        
        switch entity {
        case .shoppingList(_):
            fetchRequest = ShoppingListEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate.init(format: "id == %@",  id)
        case .product(_):
            fetchRequest = ProductEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate.init(format: "id == %@",  id)
        case .currentUser(_):
            fetchRequest = CurrentUserEntity.fetchRequest()
        case .user(_):
            fetchRequest = UserEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate.init(format: "id == %@",  id)
        case .share(_):
            fetchRequest = ShareEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate.init(format: "id == %@",  id)
        case .catalogCategory:
            fetchRequest = CatalogCategoryEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate.init(format: "id == %@",  id)
        case .catalogProduct:
            fetchRequest = CatalogProductEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate.init(format: "id == %@",  id)
        }
        fetchRequest.returnsObjectsAsFaults = false
        
        
        do {
            let objects = try context.fetch(fetchRequest)
            if objects.isEmpty {
                return nil
            }
            return objects[0] as? NSManagedObject
        } catch {
            let fetchError = error as NSError
            print("Unable to Delete Note")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
        return nil
    }
    
    func getEntities(entity: Entities, contextType: Context) -> [NSManagedObject]? {
        
        let context = contextType.context
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
        
        switch entity {
        case .shoppingList(_):
            fetchRequest = ShoppingListEntity.fetchRequest()
            
        case .product(_):
            fetchRequest = ProductEntity.fetchRequest()
        case .currentUser(_):
            fetchRequest = CurrentUserEntity.fetchRequest()
        case .user(_):
            fetchRequest = UserEntity.fetchRequest()
        case .share(_):
            fetchRequest = ShareEntity.fetchRequest()
        case .catalogCategory:
            fetchRequest = CatalogCategoryEntity.fetchRequest()
        case .catalogProduct:
            fetchRequest = CatalogProductEntity.fetchRequest()
        }
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let objects = try context.fetch(fetchRequest)
            if objects.isEmpty {
                return nil
            }
            return objects as? [NSManagedObject]
        } catch {
            print(error)
            print(error.localizedDescription)
        }
        return nil
    }
    
    func addEntity(entity: Entities, contextType: Context) {
        
        let context = contextType.context
        
        switch entity {
        case .shoppingList(model: let model):
            guard let model = model else {
                return
            }
            _ = ShoppingListEntity(model: model, context: context)
        case .product(model: let model):
            guard let model = model else {
                return
            }
            _ = ProductEntity(model: model, context: context)
        case .currentUser(model: let model):
            guard let model = model else {
                return
            }
            _ = CurrentUserEntity(model: model, context: context)
        case .user(let model):
            guard let model = model else {
                return
            }
            _ = UserEntity(object: model, context: context)
        case .share(let model):
            guard let model = model else {
                return
            }
            _ = ShareEntity(model: model, context: context)
        case .catalogCategory:
            return
        case .catalogProduct:
            return
        }
        
        CoreDataService.saveContext(context)
    }
    
    func removeEntity(entity: Entities, id: String?, contextType: Context) {
        
        let context = contextType.context
        
        switch entity {
        case .shoppingList(_):
            guard let id = id else {
                return
            }
            
            guard let shoppingListEntity = getEntity(entity: .shoppingList(), id: id, contextType: contextType) as? ShoppingListEntity else {
                return
            }
            let currentUserId = CurrentUserManager.shared.userIdentifier
            if shoppingListEntity.ownerId == currentUserId {
                shoppingListEntity.isdeleted = true
                shoppingListEntity.updatedAt = Int64(CurrentTimeManager.shared.getCurrentTime())
                let productsEntities = getProductsEntities(withListId: shoppingListEntity.id, contextType: contextType)
                for productEntity in productsEntities {
                    productEntity.isdeleted = true
                    productEntity.updatedAt = Int64(CurrentTimeManager.shared.getCurrentTime())
                }
                let sharesEntities = getShareEntites(byListId: shoppingListEntity.id, in: .specific(context))
                sharesEntities.forEach({ (shareEntity) in
                    shareEntity.isdeleted = true
                    shareEntity.updatedAt = Int64(CurrentTimeManager.shared.getCurrentTime())
                })
            } else if let shareEntity = getShareEntites(byListId: shoppingListEntity.id, in: .specific(context))
                        .first(where: { $0.toUserId == currentUserId && $0.status == 1 }) {
                shareEntity.status = 2
                shareEntity.isdeleted = true
                shareEntity.updatedAt = Int64(CurrentTimeManager.shared.getCurrentTime())
                shoppingListEntity.toBePresented = false
            }
            
        case .product(_):
            guard let id = id else {
                return
            }
            
            guard let productEntity = getEntity(entity: .product(), id: id, contextType: contextType) as? ProductEntity else {
                return
            }
            productEntity.updatedAt = Int64(CurrentTimeManager.shared.getCurrentTime())
            productEntity.isdeleted = true
        case .currentUser(_):
            let currentUsers = getEntities(entity: .currentUser(), contextType: contextType)
            currentUsers?.forEach(context.delete)
        case .user(_):
            guard let id = id else {
                return
            }
            guard let userEntity = getEntity(entity: .user(), id: id, contextType: contextType) as? UserEntity else {
                return
            }
            context.delete(userEntity as NSManagedObject)
        case .share(_):
            guard let id = id else {
                return
            }
            guard let shareEntity = getEntity(entity: .share(), id: id, contextType: contextType) as? ShareEntity else {
                return
            }
            shareEntity.updatedAt = Int64(CurrentTimeManager.shared.getCurrentTime())
            shareEntity.isdeleted = true
        case .catalogCategory, .catalogProduct:
            return
        }
        
        CoreDataService.saveContext(context)
    }
    
    func removeEntities(_ entities: [NSManagedObject], in contextType: Context) {
        let context = contextType.context
        entities.forEach(context.delete)
        CoreDataService.saveContext(context)
    }
    
    // MARK: User
    
    func getUser(byPhoneNumber phone: String, in contextType: Context) -> UserEntity? {
        
        let context = contextType.context
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "phoneString == %@", phone.decimalString)
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let objects = try context.fetch(fetchRequest)
            if objects.isEmpty {
                return nil
            }
            return objects.first as? UserEntity
        } catch {
            let fetchError = error as NSError
            print("Unable to Delete Note")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
        return nil
    }
    
    // MARK: Lists
    
    func getPresentedLists(in contextType: Context) -> [ShoppingListEntity] {
        
        let context = contextType.context
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ShoppingListEntity.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "positionOnScreen", ascending: true)
        ]
        do {
            let objects = try context.fetch(fetchRequest)
            if objects.isEmpty {
                return []
            }
            guard let entities = objects as? [ShoppingListEntity] else {
                return []
            }
            return entities.filter { $0.toBePresented }
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        return []
    }
    
    func maxPresentedListPosition(in contextType: Context) -> Double {
        let lists = getPresentedLists(in: contextType)
        let maxIndex = lists.reduce(-1) { (result, entity) -> Double in
            entity.positionOnScreen > result ? entity.positionOnScreen : result
        }
        return maxIndex
    }
    
    func positionBeforeFirstCompletedList(in contextType: Context) -> Double {
        let lists = getPresentedLists(in: contextType)
        if lists.isEmpty {
            return 0
        }
        var minPosition: Double = lists.last!.positionOnScreen
        var minIndex: Int = lists.endIndex
        for (index, entity) in lists.enumerated().reversed() {
            guard entity.isCompleted else {
                break
            }
            minIndex = index
            minPosition = entity.positionOnScreen
        }
        
        if minIndex == lists.endIndex {
            minPosition = lists.last!.positionOnScreen + 1
        } else if minIndex == lists.startIndex {
            minPosition = minPosition / 2
        } else {
            minPosition = (lists[minIndex - 1].positionOnScreen + lists[minIndex].positionOnScreen) / 2
        }
        return minPosition
    }
    
    func listToBePresented(listId: String, listOwnerId: String, context: NSManagedObjectContext) -> Bool {
        let userIdentifier = CurrentUserManager.shared.userIdentifier
        if listOwnerId == userIdentifier {
            return true
        }
        let allShares = CoreDataService.shared.getShareEntites(byListId: listId, in: .specific(context))
        if allShares.contains(where: {
            ($0.toUserId == userIdentifier || $0.ownerId == userIdentifier) && $0.isdeleted == false && $0.status == 1
        }) {
            return true
        }
        return false
    }
    
    func getNumberOfActiveShares(for listId: String, context: NSManagedObjectContext) -> Int {
        let userIdentifier = CurrentUserManager.shared.userIdentifier
        let allShares = CoreDataService.shared.getShareEntites(byListId: listId, in: .specific(context))
        let activeShares = allShares.filter({
            ($0.toUserId == userIdentifier || $0.ownerId == userIdentifier) && $0.isdeleted == false && $0.status == 1
        })
        
        return activeShares.count
    }
    
    // MARK: Products
    
    func getProductsEntities(withListId listId: String, contextType: Context) -> [ProductEntity] {

        let context = contextType.context
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
        fetchRequest = ProductEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate.init(format: "listId == %@",  listId)
        
        do {
            let objects = try context.fetch(fetchRequest)
            return objects as? [ProductEntity] ?? []
        } catch {
            let fetchError = error as NSError
            print("Unable to Delete Note")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        return []
    }
    
    // MARK: Shares
    
    func getShareEntites(byListId listId: String, in contextType: Context) -> [ShareEntity] {
        
        let context = contextType.context
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ShareEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "listId == %@", listId)
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let objects = try context.fetch(fetchRequest)
            return objects as? [ShareEntity] ?? []
        } catch {
            let fetchError = error as NSError
            print("Unable to Delete Note")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        return []
    }
    
    func acceptShare(model: ShareModel, in contextType: Context) {
        
        let context = contextType.context
        
        guard let shareEntity = getEntity(entity: .share(), id: model.id, contextType: contextType) as? ShareEntity else {
            return
        }
        shareEntity.status = 1
        shareEntity.updatedAt = Int64(CurrentTimeManager.shared.getCurrentTime())
    
        guard let shoppingListEntity = getEntity(entity: .shoppingList(), id: model.listId, contextType: contextType) as? ShoppingListEntity else {
            return
        }
        shoppingListEntity.toBePresented = true
        shoppingListEntity.positionOnScreen = maxPresentedListPosition(in: contextType) + 1
        CoreDataService.saveContext(context)
    }
    
    func rejectShare(model: ShareModel, in contextType: Context) {
        
        let context = contextType.context
        
        guard let shareEntity = getEntity(entity: .share(), id: model.id, contextType: contextType) as? ShareEntity else {
            return
        }
        shareEntity.status = 2
        shareEntity.updatedAt = Int64(CurrentTimeManager.shared.getCurrentTime())
        
        guard let shoppingListEntity = getEntity(entity: .shoppingList(), id: model.listId, contextType: contextType) as? ShoppingListEntity else {
            return
        }
        //shoppingListEntity.isdeleted = true
        shoppingListEntity.toBePresented = false
        CoreDataService.saveContext(context)
    }
    
    // MARK: General methods
    
    public func clearAllCoreData(in contextType: Context) {
        let entities = CoreDataService.persistentContainer.managedObjectModel.entities
        entities.compactMap({ $0.name }).forEach({
            clearDeepObjectEntity($0, in: contextType)
        })
    }
    
    private func clearDeepObjectEntity(_ entity: String, in contextType: Context) {
        
        let context = contextType.context
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            Self.saveContext(context)
        } catch {
            print(error, error.localizedDescription)
        }
    }
    
    // MARK: - FetchedResultsControllers
    
    func createShoppingListsFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ShoppingListEntity")
        
        fetchRequest.returnsObjectsAsFaults = false
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "positionOnScreen", ascending: true)
        ]
        
        let nsPredicate = NSPredicate(format: "(toBePresented == %@) AND (isdeleted == %@)",
                                      NSNumber(value: true),  NSNumber(value: false))
        fetchRequest.predicate  = nsPredicate
        
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataService.viewContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    
    
    func createProductsFetchedResultsController(listId: String) -> NSFetchedResultsController<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ProductEntity")
        
        fetchRequest.returnsObjectsAsFaults = false
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]
        
        let nsPredicate = NSPredicate(format: "(listId == %@) AND (isdeleted == %@)", listId, NSNumber(value: false))
        fetchRequest.predicate  = nsPredicate
        
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataService.viewContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    func createInvitationsFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ShareEntity")
        
        fetchRequest.returnsObjectsAsFaults = false
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        
        let currentUser = CurrentUserManager.shared.currentUser?.value
        let nsPredicate = NSPredicate(format: "(status == %@) AND (toUserId == %@)", NSNumber(integerLiteral: 0), currentUser?.id ?? "")
        fetchRequest.predicate = nsPredicate
        
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataService.viewContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    func createMembersListFetchedResultsController(listId: String) -> NSFetchedResultsController<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ShareEntity")
        
        fetchRequest.returnsObjectsAsFaults = false
        
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let currentUser = CurrentUserManager.shared.currentUser?.value
        
        let predicate = NSPredicate(format: "(toUserId != %@) AND (status != 2) AND (listId == %@) AND (isdeleted == %@) ", currentUser?.id ?? "", listId, NSNumber(value: false))
        fetchRequest.predicate = predicate
        
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataService.viewContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    func createSharesFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ShareEntity")
        fetchRequest.returnsObjectsAsFaults = false
        
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataService.viewContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    // MARK: - Core Data stack
    
    static var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "ShoppListCoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    static var viewContext = CoreDataService.persistentContainer.viewContext
    static func newBackgroundContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = viewContext
        return context
    }
    
    static func saveContext(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
                if let parentContext = context.parent {
                    saveContext(parentContext)
                }
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    static func saveViewContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
