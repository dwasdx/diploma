import Foundation

struct SendDataRequest: NetworkRequest {
    let apiResource = "shoppingList/updates"
    let requestType: HTTPMethod = .post
    let webServiceUrl = ShoppingListService.baseUrl.absoluteString
    let contentType = "application/json"
    let retry: Retry? = Retry(3)
    var headers: Dictionary<String, String>?
    var urlParameters: Dictionary<String, String>?
    var body: Data?
    
    init(token: String, _ data: SendDataObject) {
        headers = [:]
        headers?["Authorization"] = "Bearer \(token)"
        self.body = try? JSONEncoder().encode(data)
    }
}
