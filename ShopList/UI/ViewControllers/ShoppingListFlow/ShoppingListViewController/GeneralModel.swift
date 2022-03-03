import Foundation

class GeneralModel: Hashable {
    
    var id: String
    
    init() {
        self.id = UUID().uuidString.lowercased()
    }
    
    init(id: String) {
        self.id = id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension GeneralModel: Equatable {
    
    static func == (lhs: GeneralModel, rhs: GeneralModel) -> Bool {
        lhs.id == rhs.id
    }
    
}
