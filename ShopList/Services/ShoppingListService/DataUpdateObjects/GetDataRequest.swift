import Foundation

struct GetDataRequest: NetworkRequest {
    var apiResource = "shoppingList/updates"
    var requestType = HTTPMethod.get
    var webServiceUrl = ShoppingListService.baseUrl.absoluteString
    let contentType   = "application/json"
    let retry: Retry? = Retry(3)
    var headers: Dictionary<String, String>?
    var urlParameters: Dictionary<String, String>?
    
    init(token: String, fullUpdate: Bool = false) {
        headers = [:]
        headers?["Authorization"] = "Bearer \(token)"
        guard fullUpdate == false else {
            return
        }
        let lastGetDataTimeStamp = ShoppingListService.shared.lastGetDataTimeStamp
        if lastGetDataTimeStamp != 0 {
            urlParameters = [:]
            urlParameters?["date"] = lastGetDataTimeStamp.description
        }
    }
}
