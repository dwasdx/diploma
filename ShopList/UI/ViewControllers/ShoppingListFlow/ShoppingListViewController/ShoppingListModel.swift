import Foundation

class ShoppingListModel: GeneralModel {
    let ownerId: String
    var name: String
    let isDeleted: Bool
    let createdAt: Int
    let updatedAt: Int
    let toBePresented: Bool
    var isSharedList: Bool
    var productsNumber: Int = 0
    var checkedProductsNumber: Int = 0
    var positionOnScreen: Double
    var hasChange: Bool = false
    
    var allowedToBePresented: Bool {
        let userIdentifier = CurrentUserManager.shared.userIdentifier
        if ownerId == userIdentifier {
            return true
        }
        
        let allShares = CoreDataService.shared.getShareEntites(byListId: id, in: .view)
        
        if allShares.contains(where: {
                $0.toUserId == userIdentifier && $0.isdeleted == false && $0.status == 1
            }) {
            return true
        }
                
        return false
    }
    
    private var _isSharedList: Bool {
        let shares = CoreDataService.shared.getShareEntites(byListId: id, in: .view)
        return shares.contains(where: { $0.isdeleted == false && $0.status == 1 })
    }
    
    init(ownerId: String, name: String, createdAt: Int, updatedAt: Int) {
        self.ownerId = ownerId
        self.name = name
        self.isDeleted = false
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.toBePresented = true
        self.isSharedList = false
        self.productsNumber = 0
        self.checkedProductsNumber = 0
        self.positionOnScreen = CoreDataService.shared.positionBeforeFirstCompletedList(in: .view)
        super.init()
    }
    
    init(ownerId: String, name: String, createdAt: Int, updatedAt: Int, productsNumber: Int) {
        self.ownerId = ownerId
        self.name = name
        self.isDeleted = false
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.toBePresented = true
        self.isSharedList = false
        self.productsNumber = productsNumber
        self.checkedProductsNumber = 0
        self.positionOnScreen = CoreDataService.shared.positionBeforeFirstCompletedList(in: .view)
        super.init()
    }
    
    init(shoppingListEntity: ShoppingListEntity) {
        self.ownerId = shoppingListEntity.ownerId
        self.name = shoppingListEntity.name
        self.isDeleted = shoppingListEntity.isDeleted
        self.createdAt = Int(shoppingListEntity.createdAt)
        self.updatedAt = Int(shoppingListEntity.updatedAt)
        self.toBePresented = shoppingListEntity.toBePresented
        self.isSharedList = shoppingListEntity.isSharedList
        self.productsNumber = Int(shoppingListEntity.productsNumber)
        self.checkedProductsNumber = Int(shoppingListEntity.checkedProductsNumber)
        self.positionOnScreen = shoppingListEntity.positionOnScreen
        super.init(id: shoppingListEntity.id)
        self.isSharedList = _isSharedList
        self.hasChange = false
    }
    
//    init(fromServerResponse response: ListObject) {
//        self.ownerId = response.owner_id
//        self.name = response.name
//        self.isDeleted = response.is_deleted
//        self.createdAt = response.created_at
//        self.updatedAt = response.updated_at
//        self.toBePresented = true
//        self.isSharedList = false
//        self.productsNumber = 0
//        self.checkedProductsNumber = 0
//        self.positionOnScreen = CoreDataService.shared.maxPresentedListPosition(in: .view) + 1
//        super.init(id: response.id)
//        self.isSharedList = _isSharedList
//    }
    
    override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(name)
        hasher.combine(isSharedList)
        hasher.combine(productsNumber)
        hasher.combine(checkedProductsNumber)
//        hasher.combine(positionOnScreen)
        hasher.combine(hasChange)
        hasher.combine(updatedAt)
    }
}

//let ownerId: String
//var name: String
//let isDeleted: Bool
//let createdAt: Int
//let updatedAt: Int
//let toBePresented: Bool
//var isSharedList: Bool
//var productsNumber: Int = 0
//var checkedProductsNumber: Int = 0
//var positionOnScreen: Int = 0
//var hasChange: Bool = false
