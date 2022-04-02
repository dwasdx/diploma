import Foundation

struct ListMemberCategoryModel: Hashable {
    enum Position {
        case first, second
    }
    
    let title: String
    let position: Position
}
