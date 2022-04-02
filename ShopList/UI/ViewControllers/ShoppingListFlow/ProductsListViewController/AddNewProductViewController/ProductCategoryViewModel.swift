import Foundation

struct ProductCategoryViewModel: ProductViewModeling, Hashable {
    var title: String
    var id: Int
    
    init(entity: CatalogCategoryEntity) {
        self.id = Int(entity.id)
        self.title = entity.title
    }
    
    init?(product: ProductViewModel?) {
        guard let product = product,
              let entity = CoreDataService.shared.getEntity(entity: .catalogCategory, id: String(product.categoryId), contextType: .view) as? CatalogCategoryEntity else {
            return nil
        }
        self.id = Int(entity.id)
        self.title = entity.title
    }
}
