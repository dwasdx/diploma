import Foundation

public class Listener<T: Equatable> {
    
    let skipRepeats: Bool
    
    public typealias ListenerBlock = (T) -> Void
    let block: ListenerBlock
    
    init(skipRepeats: Bool = true, _ block: @escaping ListenerBlock) {
        self.skipRepeats = skipRepeats
        self.block = block
    }
}
