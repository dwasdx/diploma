import Foundation

public enum ShoppingListServerError: Error {
    case server(_ error: BackendError)
    case parsing(_ message: String)
    case network(_ error: Error)
    
    var message: String {
        switch self {
            case .server(let error):
                return error.message
            case .parsing(let message):
                return message
            case .network(let error):
                return error.localizedDescription
        }
    }
    
    public var localizedDescription: String {
        message
    }
    
    public struct BackendError: Error, Codable {
        let code: Int
        let message: String
    }
}

extension ShoppingListServerError: Equatable {
    public static func == (lhs: ShoppingListServerError, rhs: ShoppingListServerError) -> Bool {
        switch lhs {
            case .server(_):
                switch rhs {
                    case .server(_):
                        return true
                    case .network(_), .parsing(_):
                        return false
            }
            case .parsing(_):
                switch rhs {
                    case .parsing(_):
                        return true
                    case .server(_), .network(_):
                        return false
            }
            case .network(_):
                switch rhs {
                    case .network(_):
                        return true
                    case .server(_), .parsing(_):
                        return false
            }
        }
    }
    
    
}

struct ShoppingListServerResponse<T: Codable>: Codable {
    
    let data: T?
    let error: ShoppingListServerError.BackendError?
    
    static func parse(data: Data) -> Result<T?, ShoppingListServerError> {
        do {
            let decodedValue = try JSONDecoder().decode(Self.self, from: data)
            if let error = decodedValue.error {
                return .failure(.server(error))
            } else {
                return .success(decodedValue.data)
            }
        } catch let error {
            return .failure(.parsing("Parsing error: \(error.localizedDescription)"))
        }
    }
}
