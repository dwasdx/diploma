import Foundation

struct PhoneConfirmationRequest: NetworkRequest {
    var apiResource: String = "auth/phone/confirm"
    let requestType = HTTPMethod.post
    let webServiceUrl = ShoppingListService.baseUrl.absoluteString
    let contentType   = "application/json"
    let retry: Retry? = Retry(3)
    var headers: Dictionary<String, String>?
    var body: Data?
    
    init(_ codeModel: PhoneConfirmationModel) {
        self.body = try? JSONEncoder().encode(codeModel)
    }
}
