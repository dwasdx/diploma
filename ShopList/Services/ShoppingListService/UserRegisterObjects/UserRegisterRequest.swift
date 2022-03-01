import Foundation

struct UserRegisterRequest: NetworkRequest {
    var apiResource   = "user/create"
    let requestType   = HTTPMethod.post
    let webServiceUrl = ShoppingListService.baseUrl.absoluteString
    let contentType   = "application/json"
    let retry: Retry? = Retry(3)
    var headers: Dictionary<String, String>?
    var body: Data?
    
    init(_ user: UserRegisterObject) {
        self.body = try? JSONEncoder().encode(user)
    }
}
