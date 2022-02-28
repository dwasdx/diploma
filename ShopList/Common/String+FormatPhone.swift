import Foundation

extension String {
    var decimalString: String {
        var string = self.components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
        if let firstChar = string.first{
            string = firstChar == "8" ? string.replacingCharacters(in: ...string.startIndex, with: "7") : string
            return string
        }
        return ""
    }
}
