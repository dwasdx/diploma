import Foundation

extension String {
    static let empty = ""
    static let newLine = "\n"
    static let doubleNewLine = "\n\n"
    static let space = " "
    static let commaSpace = .comma + .space
    static let commaNewLine = .comma + .newLine
    static let dotSpace = .dot + .space
    static let semicolonSpace = .semicolon + .space
    static let semicolon = ";"
    static let comma = ","
    static let dot = "."
    static let spacedDash = .space + .dash + .space
    static let dash = "–"
    static let ellipsis = "…"
    static let plus = "+"
    static let minus = "-"
    static let greaterThanSign = ">"
    static let slash = "/"
}
