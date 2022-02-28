import Foundation

extension StringProtocol where Index == String.Index {

    func nsRange(of string: String) -> NSRange? {
        guard let range = self.range(of: string) else {
            return nil            
        }
        return NSRange(range, in: self)
    }
}
