import Foundation

class ChangeValueViewModel: BaseViewModel {
    
    var model: ProductModel?
    let indexPath: IndexPath
    var sections = [ProductCategoryViewModel]()
    var items = [[ProductViewModel]]()
    
    var choosenProductCategory: Int?
    var itemsFiltered = [[ProductViewModel]]()
    var sectionsFiltered = [ProductCategoryViewModel]()
    
    var didChangeFilter: (() -> Void)?
    
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
    
    let userManager: CurrentUserManaging
    let syncService: SynchronizationServiceable
    
    init(parentViewModel: ProductsListViewModeling,
         indexPath: IndexPath,
         userManager: CurrentUserManaging = CurrentUserManager.shared,
         syncService: SynchronizationServiceable = SynchronizationService.shared) {
        self.model = parentViewModel.getModel(at: indexPath)
        self.indexPath = indexPath
        self.userManager = userManager
        self.syncService = syncService
        super.init()
        initialize()
    }
    
    private func initialize() {
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
    
    private func applyFilter() {
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

extension ChangeValueViewModel: ChangeValueViewModeling {
    var numberOfSections: Int {
        sectionsFiltered.count
    }
    
    var value: String? {
        get {
            return model?.value
        }
        set {
            guard let value = newValue else {
                return
            }
            model?.value = value
        }
    }
    
    var name: String? {
        get {
            model?.name
        }
        set {
            guard let name = newValue else {
                return
            }
            filter = name
            model?.name = name
        }
    }
    
    func getNumberOfRows(in section: Int) -> Int {
        itemsFiltered[section].count
    }
    
    func getProductViewModel(_ indexPath: IndexPath) -> ProductViewModeling? {
        itemsFiltered[indexPath.section][indexPath.row]
    }
    
    func getCategoryViewModel(_ section: Int) -> ProductCategoryViewModel? {
        guard sectionsFiltered.indices ~= section else {
            return nil
        }
        return sectionsFiltered[section]
    }
    
    func changeValue() {
        guard let model = model else {
            return
        }
        
        let entity = CoreDataService.shared.getEntity(entity: .product(model), id: model.id, contextType: .view) as? ProductEntity
        entity?.name = model.name
        entity?.value = model.value
        if let sectionIndex = choosenProductCategory {
            entity?.categoryName = self.sectionsFiltered[sectionIndex].title
        }
        entity?.updatedAt = Int64(CurrentTimeManager.shared.getCurrentTime())
        
        CoreDataService.saveViewContext()
        if let token = userManager.userToken {
            syncService.synchronizeDatabaseWithDelay(token: token, fullUpdate: false)
        }
    }
}
