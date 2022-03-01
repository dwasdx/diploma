import Foundation

struct CheckAuthoriztionLimitRequest: NetworkRequest {
    var apiResource: String = "auth/phone"
    let requestType = HTTPMethod.get
    let webServiceUrl = ShoppingListService.baseUrl.absoluteString
    let contentType   = "application/json"
    let retry: Retry? = Retry(3)
    
    init(phoneNumber: String) {
        apiResource = "\(apiResource)/\(phoneNumber)/checkLimit"
    }
}
