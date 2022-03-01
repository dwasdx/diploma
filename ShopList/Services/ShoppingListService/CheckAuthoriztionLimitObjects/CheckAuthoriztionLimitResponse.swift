import Foundation

struct CheckAuthoriztionLimitResponse: Codable {
    let is_allow: Bool
    let next_time_request: Int
    let type_limit: String
    
    var nextRequestDate: Date {
        Date(timeIntervalSince1970: TimeInterval(next_time_request))
    }
}
