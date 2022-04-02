import Foundation

class UncheckAllViewModel: BaseViewModel {
    
    var parentViewModel: ProductsListViewModeling
    
    init(parentViewModel: ProductsListViewModeling) {
        self.parentViewModel = parentViewModel
    }
    
}

extension UncheckAllViewModel: UncheckAllViewModeling{
    
    func uncheckAll(_ completion: (() -> Void)?) {
        parentViewModel.uncheckAllProducts()
        completion?()
    }
    
}
