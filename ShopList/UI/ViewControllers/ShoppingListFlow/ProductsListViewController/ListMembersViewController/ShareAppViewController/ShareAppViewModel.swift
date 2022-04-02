import Foundation

class ShareAppViewModel: BaseViewModel {
    
    let shareMessage =
    """
    Вас пригласили в приложение \"Список покупок - Shopping List\". Для совместного редактирования списков покупок скачайте приложение:
    в AppStore:
    https://apps.apple.com/ru/app/%D1%81%D0%BF%D0%B8%D1%81%D0%BE%D0%BA-%D0%BF%D0%BE%D0%BA%D1%83%D0%BF%D0%BE%D0%BA-shopping-list/id1530377058
    или в GooglePlay:
    https://play.google.com/store/apps/details?id=com.globus.shoppinglist
    """

}

extension ShareAppViewModel: ShareAppViewModeling {
    
    func getShareMessage() -> String {
        return shareMessage
    }
    
}
