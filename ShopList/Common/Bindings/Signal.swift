import Foundation

public typealias SignalSubscriptionToken = Int

public class Signal<T: Equatable> {
    
    public private(set) var value: T
    
    private var listeners = [SignalSubscriptionToken: Listener<T>]()
    
    fileprivate init(_ emitter: Emitter<T>) {
        self.value = emitter.value
        emitter.emitterBlock = { [weak self] (value) in
            let valueChanged = self?.value != value
            self?.value = value
            self?.listeners.values.forEach {
                if $0.skipRepeats {
                    if valueChanged {
                        $0.block(value)
                    }
                } else {
                    $0.block(value)
                }
            }
        }
    }
    
    /// method is not thread safe!
   
    @discardableResult
    public func addListener(skipCurrent: Bool = false,
                            skipRepeats: Bool = false,
                            listenerBlock: @escaping Listener<T>.ListenerBlock) -> SignalSubscriptionToken {
        let key = (listeners.keys.max() ?? 0) + 1
        listeners[key] = Listener(skipRepeats: skipRepeats, listenerBlock)
        if !skipCurrent {
            listenerBlock(value)
        }
        return key
    }
    
    /// method is not thread safe!
    public func removeListener(_ token: SignalSubscriptionToken?) {
        guard let token = token else {
            return
        }
        listeners[token] = nil
    }
}

public class Emitter<T: Equatable> {
    
    fileprivate var emitterBlock: ((T) -> Void)?
    
    public private(set) lazy var signal: Signal<T> = {
        return Signal(self)
    }()
    
    public var value: T {
        didSet {
            emitterBlock?(value)
        }
    }
    
    public init(_ value: T) {
        self.value = value
    }
}
