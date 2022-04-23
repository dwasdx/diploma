import Foundation

class MockShoppingListService {
    
    static let shared = MockShoppingListService()
    private init() {}
    
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
