import Foundation

protocol ProductViewModeling {
    var title: String { get }
}

class AddNewProductViewModel: BaseViewModel {
    
    var names: String? {
        didSet {
            self.didChange?()
        }
    }
    var value: String? {
        didSet {
            self.didChange?()
        }
    }
    
    var sections = [ProductCategoryViewModel]()
    var items = [[ProductViewModel]]()
    
    var itemsFiltered = [[ProductViewModel]]()
    var sectionsFiltered = [ProductCategoryViewModel]()
    
    var listId: String
    
    var choosenProductSection: Int?
    
    var isFiltering = false {
        didSet {
            didChange?()
        }
    }
    var filter: String? {
        didSet {
            applyFilter()
        }
    }
    
    var didChangeFilter: (()->Void)?
    var didAddSuccessfully: (()->Void)?
    
    let userManager: CurrentUserManaging
    let syncService: SynchronizationServiceable
    
    init(
        _ listId: String,
        userManager: CurrentUserManaging = CurrentUserManager.shared,
        syncService: SynchronizationServiceable = SynchronizationService.shared
    ) {
        self.userManager = userManager
        self.syncService = syncService
        self.listId = listId
        super.init()

        if let sectionEntities = CoreDataService.shared.getEntities(entity: .catalogCategory, contextType: .view) as? [CatalogCategoryEntity] {
            self.sections = sectionEntities.map(ProductCategoryViewModel.init)
            self.items = sectionEntities.map { _ in [] }
        }
        for (index, category) in self.sections.enumerated() {
            guard let categoryEntity = CoreDataService.shared.getEntity(entity: .catalogCategory, id: String(category.id), contextType: .view) as? CatalogCategoryEntity else {
                continue
            }
            self.items[index] = categoryEntity.productsArray.map(ProductViewModel.init)
        }
        self.didChange?()
        
    }
    
    private func applyFilter() { // TODO: delay and background
        guard let filterName = filter else {
            return
        }
        itemsFiltered = items.compactMap({ (products) -> [ProductViewModel]? in
            let filteredProducts = products.filter { $0.title.lowercased().contains(filterName.lowercased()) }
            if filteredProducts.isEmpty {
                return nil
            }
            return filteredProducts
        })
        sectionsFiltered = itemsFiltered.compactMap {
            ProductCategoryViewModel(product: $0.first)
        }
        
        didChangeFilter?()
    }
}

extension AddNewProductViewModel: AddNewProductViewModeling {
    
    var isEmptyFilter: Bool {
        itemsFiltered.isEmpty
    }
    
    var numberOfSections: Int {
        sectionsFiltered.count
    }
    
    var numberOfModels: Int {
        itemsFiltered.reduce(0) { (lastResult, products) -> Int in
            lastResult + products.count
        }
    }
    
    func addNewProduct(_ completion: ((Error?) -> Void)?) {
        let date = CurrentTimeManager.shared.getCurrentTime()
        guard let names = names else {
            didGetError?("")
            return
        }
        
        let productNames: [String] =  names.components(separatedBy: [","])
        for productName in productNames {
            var name = productName.trimmingCharacters(in: [" "])
            name = name.prefix(1).uppercased() + name.lowercased().dropFirst()
            
            guard !name.isEmpty else {
                continue
            }
            
            var model = ProductModel(name: name, listId: listId, value: value ?? "", date: date)
            if let sectionIndex = choosenProductSection {
                model.categoryName = self.sectionsFiltered[sectionIndex].title
            }
            CoreDataService.shared.addEntity(entity: .product(model), contextType: .view)
        }
        
        if let token = userManager.userToken {
            syncService.synchronizeDatabaseWithDelay(token: token, fullUpdate: false)
        }
        didAddSuccessfully?()
    }
    
    func getNumberOfRows(in section: Int) -> Int {
        itemsFiltered[section].count
    }
    
    func getProductViewModel(_ indexPath: IndexPath) -> ProductViewModeling? {
        itemsFiltered[indexPath.section][indexPath.row]
    }
    
    func getProductCategoryViewModel(_ section: Int) -> ProductCategoryViewModel? {
        guard sectionsFiltered.indices ~= section else { // <= ?
            return nil
        }
        return sectionsFiltered[section]
    }

}
