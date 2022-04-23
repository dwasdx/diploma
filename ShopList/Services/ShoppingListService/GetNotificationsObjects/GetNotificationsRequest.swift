import Foundation

struct GetNotificationsRequest: NetworkRequest {
    var apiResource = "notifications"
    var requestType = HTTPMethod.get
    var webServiceUrl = ShoppingListService.baseUrl.absoluteString
    let contentType   = "application/json"
    let retry: Retry? = Retry(3)
    var headers: Dictionary<String, String>?
    
    init(page: Int) {
        headers = [:]
        guard let token = CurrentUserManager.shared.userToken else {
            fatalError("No token was found")
        }
        headers?["Authorization"] = "Bearer \(token)"
        apiResource = "\(apiResource)/page/\(page)"
    }
}
