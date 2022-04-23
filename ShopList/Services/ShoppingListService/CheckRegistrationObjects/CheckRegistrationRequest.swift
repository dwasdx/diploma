import Foundation

struct CheckRegistrationRequest: NetworkRequest {
    var apiResource   = "users/check-registation"
    let requestType   = HTTPMethod.post
    let webServiceUrl = ShoppingListService.baseUrl.absoluteString
    let contentType   = "application/json"
    let retry: Retry? = Retry(3)
    var headers: Dictionary<String, String>?
    var body: Data?
    
    init(object: CheckRegistrationObject) {
        guard let token = CurrentUserManager.shared.userToken else {
            fatalError("No token was found")
        }
        headers = [:]
        headers?["Authorization"] = "Bearer \(token)"
        self.body = try? JSONEncoder().encode(object)
    }
}
