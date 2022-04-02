import Foundation
import UIKit

struct ListActionsModel {
    let title: String
    let image: UIImage
}

typealias Actions = [ListActionsModel]

enum ListActionTittle {
    case share
    case rename
    case addToShoppingList
    case addParticipant
    
    var description: String {
        switch self {
        case .addToShoppingList:
            return "Добавить в список покупок"
        case .rename:
            return "Переименовать список"
        case .share:
            return "Поделиться списком"
        case .addParticipant:
            return "Добавить участников"
        }
    }
}
