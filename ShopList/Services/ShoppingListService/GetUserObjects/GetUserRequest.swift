import Foundation

struct GetUserRequest: NetworkRequest {
    var apiResource   = "user/by-phone"
    let requestType   = HTTPMethod.get
    let webServiceUrl = ShoppingListService.baseUrl.absoluteString
    let contentType   = "application/json"
    let retry: Retry? = Retry(3)
    var headers: Dictionary<String, String>?
    
    init(phoneNumber: String) {
        guard let token = CurrentUserManager.shared.userToken else {
            fatalError("No token was found")
        }
        headers = [:]
        headers?["Authorization"] = "Bearer \(token)"
        apiResource = "\(apiResource)/\(phoneNumber)"
    }
}
