//
//  AsyncOperation.swift
//  ExecutorKit
//
//  Created by dcilia on 10/25/16.
//
//

import Foundation

fileprivate struct KVO {
    static let IsReadyKeyPath : String = "isReady"
    static let IsExecutingKeyPath : String = "isExecuting"
    static let IsFinishedKeyPath : String = "isFinished"
    static let IsCancelled : String = "isCancelled"
    static let NotReady : String = "notReady"
}

open class AsyncOperation<Observer : ExecutorObserver> : Operation, Executor where Observer.T == AsyncOperation {
    
    public typealias T = Observer
    
    private let _stateLock : NSLock = NSLock()
    
    fileprivate enum State : CustomStringConvertible {
        case ready, cancelled, executing, finished, notReady
        
        fileprivate var description: String {
            switch self {
            case .ready:
                return KVO.IsReadyKeyPath
            case .executing:
                return KVO.IsExecutingKeyPath
            case .finished:
                return KVO.IsFinishedKeyPath
            case .cancelled:
                return KVO.IsCancelled
            case .notReady:
                return KVO.NotReady
            }
        }
    }
    
    public var observers: [T] = []
    
    private(set) var identifier : String
    
    //Overrides
    override open var isAsynchronous: Bool { return true }
    
    fileprivate var _state: State = .notReady {
        willSet {
            
            let _ = _stateLock.criticalScope {
                
                self.willChangeValue(forKey: newValue.description)
                self.willChangeValue(forKey: self._state.description)
            }
        }
        didSet {
            
            let _ = _stateLock.criticalScope {
                
                self.didChangeValue(forKey: oldValue.description)
                self.didChangeValue(forKey: self._state.description)
                
            }
            
            switch _state {
            case .ready:
                didBecomeReady?(self)
                observers.forEach { $0.did(becomeReady: self) }
                break
            case .executing:
                didStart?(self)
                observers.forEach { $0.did(start: self) }
                break
            case .finished:
                didFinish?(self)
                observers.forEach { $0.did(finish: self) }
                break
            case .cancelled:
                didCancel?(self)
                observers.forEach { $0.did(cancel: self) }
                break
            default:
                break
            }
        }
    }
    
    open override var isReady: Bool {
        return _state == .ready
    }
    
    open override var isCancelled: Bool {
        return _state == .cancelled
    }
    
    open override var isFinished: Bool {
        return _state == .finished
    }
    
    open override var isExecuting: Bool {
        return _state == .executing
    }
    
    public init(identifier: String) {

        self.identifier = identifier
        super.init()
        _state = .ready
    }
    
    var didBecomeReady : ((_ operation : AsyncOperation) -> Void)?
    var didStart : ((_ operation : AsyncOperation) -> Void)?
    var didFinish : ((_ operation : AsyncOperation) -> Void)?
    var didCancel : ((_ operation : AsyncOperation) -> Void)?
    
    
    deinit {
        observers.removeAll()
    }
    
    open func execute() -> Void {}
    
    open override func main() {}
    
    override open func cancel() {
        super.cancel()
        _state = .cancelled
        
    }
    
    override open func start() {
        
        if isCancelled {
            _state = .finished
            return
        }
        
        _state = .executing
        execute()
    }
    
    public func finish() {
        _state = .finished
        completionBlock?()
    }
    
    public func add(observer: T) {
        observers.append(observer)
    }
    
    public func remove(observer: T) {
        
        let lhs = AnyExecutorObserver(observer)
        
        for (index, item) in observers.enumerated() {
            
            let rhs = AnyExecutorObserver(item)
            
            if lhs === rhs {
                observers.remove(at: index)
            }
        }
    }
}

