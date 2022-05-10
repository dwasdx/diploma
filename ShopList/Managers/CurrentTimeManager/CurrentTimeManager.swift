import Foundation

class CurrentTimeManager {
    
    static let shared = CurrentTimeManager()
    private init() {}
    
    
    func getCurrentTime() -> Int {
        let date = Date()
        let timeInterval = date.timeIntervalSince1970
        let dateInt = Int(timeInterval)
        return dateInt
    }
}
