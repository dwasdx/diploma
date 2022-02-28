import Foundation

extension String {
    var isValid: Bool {
       let result = self.map{String($0)}
        if result.first != .space {
            for char in result {
                if char != .space  {
                    return true
                }
            }
        }
        return false
    }
}
