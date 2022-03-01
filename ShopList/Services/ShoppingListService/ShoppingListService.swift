import Foundation

class ShoppingListService {
    #if PROD
    static let baseUrl = URL(string: "https://shoppinglist.globus-ltd.com/api/v1/")!
    #else
    //static let baseUrl = URL(string: "https://shoppinglist.globus-ltd.com/api/v1/")!
    static let baseUrl = URL(string: "https://shoppinglist.dev.globus-ltd.com/api/v1/")!
    #endif
    
    static let shared = ShoppingListService()
    private init() {}
    
    func makeRequestAndParseResponce<T: Codable>(_ request: NetworkRequest, completion: @escaping (Result<T?, ShoppingListServerError>) -> Void) {
        
        NetworkClient.shared.callApi(request) { apiResponse in
            let httpStatusResult = self.checkHttpStatusCode(apiResponse)
            switch httpStatusResult {
                case .success(let data):
                    let backendResponse: Result<T?, ShoppingListServerError> = self.parseApiResponce(data)
                    completion(backendResponse)
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
    
    // For cases when responce is not needed to be parsed
    func makeRequest(_ request: NetworkRequest, completion: @escaping ((ShoppingListServerError?) -> Void)) {
        NetworkClient.shared.callApi(request) { apiResponse in
            let httpStatusResult = self.checkHttpStatusCode(apiResponse)
            switch httpStatusResult {
                case .success(_):
                    completion(nil)
                case .failure(let error):
                    completion(error)
            }
        }
    }
    
    func checkHttpStatusCode(_ apiResponse: Result<NetworkResponse,Error>) -> Result<Data?,ShoppingListServerError> {
        switch apiResponse {
            case .success((let urlResponce, let data)):
                guard let urlResponce = urlResponce as? HTTPURLResponse else {
                    return .failure(.server(ShoppingListServerError.BackendError(code: -1, message: "something happened")))
                }
                
                switch urlResponce.statusCode {
                    case 200...299:
                        return .success(data)
                    case 400...499, 500...599:
                        do {
                            guard let data = data else {
                                return .failure(.server(ShoppingListServerError.BackendError(code: -4, message: "no data arraived")))
                            }
                            let serverResponse = try JSONDecoder().decode(ShoppingListServerResponse<UserLoginResponse>.self, from: data)
                            guard let errorResponse = serverResponse.error else {
                                return .failure(.server(ShoppingListServerError.BackendError(code: -5, message: "no error arrived, but there is error code in resposne")))
                            }
                            return .failure(.server(ShoppingListServerError.BackendError(code: errorResponse.code, message: errorResponse.message)))
                        } catch {
                            
                        }
                        
                        return .failure(.server(ShoppingListServerError.BackendError(code: -2, message: "something ahppened")))
                    
                    default:
                        return .failure(.server(ShoppingListServerError.BackendError(code: -3, message: "f[dsfjsdaf")))
            }
            
            case .failure(let error):
                return .failure(.network(error))
        }
    }
    
    func parseApiResponce<T: Codable>(_ data: Data?) -> Result<T?, ShoppingListServerError> {
        guard let data = data else {
            return .failure(.parsing("Response does not have data"))
        }
        
        let parsingResult = ShoppingListServerResponse<T>.parse(data: data)
        switch parsingResult {
            case .success(let parsedObject):
                return .success(parsedObject)
            case .failure(let error):
                return .failure(.parsing(error.localizedDescription))
        }
    }
}
