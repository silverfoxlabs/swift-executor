//
//  AsyncOperation.swift
//  ExecutorKit
//
//  Created by dcilia on 10/25/16.
//
//

import Foundation

open class AsyncOperation : Operation, Executor {

    public typealias Closure = () -> Void

    public var didBecomeReady : Closure?
    public var didStart : Closure?
    public var didCancel : Closure?
    public var didFinish : Closure?

    public var observers: Array<ExecutorObserver> = []

    private let _stateLock : NSLock = NSLock()
    
    fileprivate enum State : CustomStringConvertible {
        case ready, cancelled, executing, finished
        
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
            }
        }
    }
    
    fileprivate struct KVO {
        static let IsReadyKeyPath : String = "isReady"
        static let IsExecutingKeyPath : String = "isExecuting"
        static let IsFinishedKeyPath : String = "isFinished"
        static let IsCancelled : String = "isCancelled"
    }

    private(set) var identifier : String

    //Overrides
    override open var isAsynchronous: Bool { return true }
    
    fileprivate var _state: State = .ready {
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
                didBecomeReady?()
                observers.forEach { $0.did(becomeReady: self) }
                break
            case .executing:
                didStart?()
                observers.forEach { $0.did(start: self) }
                break
            case .finished:
                didFinish?()
                observers.forEach { $0.did(finish: self) }
                break
            case .cancelled:
                /**
                 In the case of cancellation, it is still
                 important to update the isFinished key path,
                 even if the operation did not completely
                 finish its task.
                 */
                didCancel?()
                observers.forEach { $0.did(cancel: self) }
                didFinish?()
                observers.forEach { $0.did(finish: self) }
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

    }
    
    deinit {
        observers.removeAll()
    }

    open func execute() {
        //no-op
    }

    open override func main() {
        //no-op
    }
    
    override open func cancel() {
        super.cancel()
        _state = .cancelled
    }
    
    override open func start() {
        
        if isCancelled {
            return
        }

        _state = .executing
        execute()
    }
    
    public func finish() {
        _state = .finished
    }

    public func remove<T>(observer: T) where T : ExecutorObserver {
        //Override this function in your subclass for custom behaviour.
    }

    public func remove<T>(observer: T) where T : ExecutorObserver, T : Equatable {
        self.observers.removeAll { (obs) -> Bool in

            guard let _obs = obs as? T else { return false }
            return _obs == observer
        }
    }

    public func removeAllObservers() {
        observers.removeAll()
    }

    public func add<T>(observer: T) where T : ExecutorObserver {
        observers.append(observer)
    }

}
