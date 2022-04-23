import Foundation

struct GetCatalogRequest: NetworkRequest {
    var apiResource   = "refbook"
    let requestType   = HTTPMethod.get
    let webServiceUrl = ShoppingListService.baseUrl.absoluteString
    let contentType   = "application/json"
    let retry: Retry? = Retry(3)
    var headers: Dictionary<String, String>?
    
    init() {
        guard let token = CurrentUserManager.shared.userToken else {
            fatalError("No token was found")
        }
        headers = [:]
        headers?["Authorization"] = "Bearer \(token)"
    }
}
