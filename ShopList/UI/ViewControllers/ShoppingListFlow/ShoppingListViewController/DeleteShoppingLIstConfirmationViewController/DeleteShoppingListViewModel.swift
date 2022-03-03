import Foundation

protocol DeleteShoppingListViewModeling: BaseViewModeling {
    var parentViewModel: ShoppingListViewModeling! { get }
    func deleteFromParentViewModel()
    func reloadCell()
    var descriptionText: String { get }
}

class DeleteShoppingListViewModel: BaseViewModel {
    var model: ShoppingListModel
    let indexPath: IndexPath
    let parentViewModel: ShoppingListViewModeling!
        
    let isOwner: Bool
    
    init(model: ShoppingListModel, indexPath: IndexPath, parentViewModel: ShoppingListViewModeling?) {
        self.model = model
        self.indexPath = indexPath
        self.parentViewModel = parentViewModel
        self.isOwner = CurrentUserManager.shared.userIdentifier == model.ownerId
    }
    
    
}

extension DeleteShoppingListViewModel: DeleteShoppingListViewModeling {
    
    func deleteFromParentViewModel() {
        parentViewModel.removeModel(inCellWithIndexPath: indexPath)
    }
    
    func reloadCell() {
        parentViewModel.didCancelModelDelete?(indexPath)
    }
    
    var descriptionText: String {
        if isOwner {
            return "Вы действительно хотите удалить список «\(model.name)»?"
        } else {
            return "Вы действительно хотите выйти из списка «\(model.name)»"
        }
    }
}
