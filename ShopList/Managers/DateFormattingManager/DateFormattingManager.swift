import Foundation

protocol DateFormattingManaging {
    func string(from date: Date, usingFormat format: String) -> String
    func date(from string: String, usingFormat format: String) -> Date?
    
    func string(from date: Date, usingOptions options: ISO8601DateFormatter.Options) -> String
    func date(fromISO6801String string: String, usingOptions options: ISO8601DateFormatter.Options) -> Date?
}

class DateFormattingManager {
    static let shared = DateFormattingManager()
    private init() {}
    
    private let dateFormatter = DateFormatter()
    private let iso6801DateFormatter = ISO8601DateFormatter()
}

extension DateFormattingManager: DateFormattingManaging {
    func string(from date: Date, usingFormat format: String) -> String {
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    func date(from string: String, usingFormat format: String) -> Date? {
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: string)
    }
    
    func string(from date: Date, usingOptions options: ISO8601DateFormatter.Options) -> String {
        iso6801DateFormatter.formatOptions = options
        return iso6801DateFormatter.string(from: date)
    }
    
    func date(fromISO6801String string: String, usingOptions options: ISO8601DateFormatter.Options) -> Date? {
        iso6801DateFormatter.formatOptions = options
        return iso6801DateFormatter.date(from: string)
    }
}
