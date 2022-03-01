import Foundation
import CryptoKit

class KeychainService {
    static let shared = KeychainService()
    private init() {}
    
    func getItem(forKey key: String) -> Data? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword as String,
                                    kSecAttrAccount as String: key,
                                    kSecReturnData as String: kCFBooleanTrue!,
                                    kSecMatchLimit as String: kSecMatchLimitOne]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return data
        } else {
            return nil
        }
    }
    
    func setItem(_ item: String, forKey key: String) {
        if let valueData = item.data(using: .utf8) {
            let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword as String,
                                        kSecAttrAccount as String: key,
                                        kSecValueData as String: valueData]
            
            SecItemDelete(query as CFDictionary) // Delete the query if exists
            let status = SecItemAdd(query as CFDictionary, nil)
            if status != errSecSuccess {
                //TBD
            }
        }
    }
    
    func removeItem(forKey key: String) {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword as String,
                                    kSecAttrAccount as String: key]
        SecItemDelete(query as CFDictionary)
    }
}
