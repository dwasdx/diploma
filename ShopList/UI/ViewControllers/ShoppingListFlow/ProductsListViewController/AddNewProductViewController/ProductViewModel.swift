import Foundation

struct ProductViewModel: ProductViewModeling, Hashable {
    var id: Int
    var title: String
    var categoryId: Int
    
    init(entity: CatalogProductEntity) {
        self.id = Int(entity.id)
        self.title = entity.title
        self.categoryId = Int(entity.categoryId)
    }
    
}
