import Foundation

struct AcceptShareRequest: NetworkRequest {
    var apiResource = "share-list"
    let requestType: HTTPMethod = .post
    let webServiceUrl = ShoppingListService.baseUrl.absoluteString
    let contentType = "application/json"
    let retry: Retry? = Retry(3)
    var headers: Dictionary<String, String>?
    
    init(shareId: String) {
        headers = [:]
        guard let token = CurrentUserManager.shared.userToken else {
            fatalError("No token was found")
        }
        headers?["Authorization"] = "Bearer \(token)"
        
        apiResource = "\(apiResource)/\(shareId)/accept"
    }
}
