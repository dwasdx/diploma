import Foundation
import PhoneNumberKit

protocol PhoneNumberManaging {
    var defaultRegionPrefix: String { get }
    
    func formatPhoneNumber(_ rawString: String, withRegion region: String?) -> String
}

extension PhoneNumberManaging {
    func formatPhoneNumber(_ rawString: String, withRegion region: String? = nil) -> String {
        return formatPhoneNumber(rawString, withRegion: region)
    }
}

class PhoneNumberManager {
    
    //phoneNumberKit keeps lot of metadata and is expensive to allocate each time its .init calls
    //this is why I decided to keep this as singletone's prop
    private let phoneNumberKit = PhoneNumberKit()
    
    static let shared = PhoneNumberManager()
    private init() {}
    
    private func _formatPhone(_ rawString: String) -> String {
        if rawString.first == "7" {
            var resultString = ""
            for (charIndex, char) in rawString.enumerated() {
                switch charIndex {
                    case 0:
                        resultString = "+7 "
                    case 1...3, 5...6, 8, 10:
                        resultString.append(char)
                    case 4:
                        resultString.append(contentsOf: " \(char)")
                    case 7, 9:
                        resultString.append(contentsOf: "-\(char)")
                    default:
                        continue
                }
            }
            return resultString
        }
        return rawString
    }
}

extension PhoneNumberManager: PhoneNumberManaging {
    
    var defaultRegionPrefix: String {
        guard let code = phoneNumberKit.countryCode(for: PhoneNumberKit.defaultRegionCode()) else {
            return ""
        }
        return "+" + code.description
    }
    
    func formatPhoneNumber(_ rawString: String, withRegion region: String? = nil) -> String {
        do {
            let phone = try phoneNumberKit.parse(rawString, withRegion: PhoneNumberKit.defaultRegionCode())
            let formattedPhone = phoneNumberKit.format(phone, toType: .international)
            return formattedPhone
        } catch {
            return _formatPhone(rawString)
        }
    }
}
