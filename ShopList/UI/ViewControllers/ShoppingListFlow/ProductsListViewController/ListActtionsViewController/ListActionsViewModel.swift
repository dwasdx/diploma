import Foundation

class ListActionsViewModel: BaseViewModel {
    
    let models: Actions
    let productsListViewModel: ProductsListViewModeling
    
    init(actions: Actions, productListViewModel: ProductsListViewModeling) {
        self.models = actions
        self.productsListViewModel = productListViewModel
    }
}

extension ListActionsViewModel: ListActionsViewModeling {
    var numberOfSections: Int {
        1
    }
    
    func getNumberOfRows(inSection section: Int) -> Int {
        models.count
    }
    
    func getModel(forIndexPath indexPath: IndexPath) -> ListActionsModel {
        models[indexPath.row]
    }
}
