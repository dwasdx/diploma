import Foundation

protocol ShoppingListCatalogServiceable {
    
}

extension ShoppingListService: ShoppingListCatalogServiceable {
    
    func getCatalog(_ completion: @escaping ((ShoppingListServerError) -> Void)) {
        let request = GetCatalogRequest()
        makeRequestAndParseResponce(request) { (result: Result<GetCatalogResponse?, ShoppingListServerError>) in
            switch result {
                case .success(let response):
                    guard let response = response else {
                        return
                    }
                    self.processFetchedCatalogItems(response)
                case .failure(let error):
                    completion(error)
            }
        }
    }
    
    private func processFetchedCatalogItems(_ response: GetCatalogResponse) {
        var categories = [Int: CatalogCategoryEntity]()
        let backgroundContext = CoreDataService.newBackgroundContext()
        response.categories.forEach { (category) in
            guard let categoryEntity = CoreDataService.shared.getEntity(entity: .catalogCategory, id: String(category.id), contextType: .specific(backgroundContext)) as? CatalogCategoryEntity else {
                categories[category.id] = CatalogCategoryEntity(response: category, context: backgroundContext)
                return
            }
            categoryEntity.updateValues(category)
        }
        //CoreDataService.saveContext(backgroundContext)
        
        response.products.forEach { (product) in
            guard
                
                let productEntity = CoreDataService.shared.getEntity(entity: .catalogProduct, id: String(product.id), contextType: .specific(backgroundContext)) as? CatalogProductEntity else {
                let productEntity = CatalogProductEntity(response: product, context: backgroundContext)
                categories[product.category_id]?.addToProducts(productEntity)
                return
            }
            productEntity.updateValues(product)
            categories[product.category_id]?.addToProducts(productEntity)
        }
        CoreDataService.saveContext(backgroundContext)
    }
}
