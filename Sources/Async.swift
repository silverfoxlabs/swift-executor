//
//  AsyncOperation.swift
//  ExecutorKit
//
//  Created by dcilia on 10/25/16.
//
//

import Foundation

open class Async : Operation, Executor {
    
    public typealias ReadyStatus = () -> Bool
    public typealias Closure = () -> Void

    public var readyStatus : ReadyStatus = { return true } {
        didSet {
            checkReadyStatus()
        }
    }
    public var didBecomeReady : Closure = {}
    public var didStart : Closure = {}
    public var didFinish : Closure = {}
    public var didCancel : Closure = {}

    public var observers: Array<ExecutorObserver> = []

    private let _stateLock : NSLock = NSLock()
    
    fileprivate enum State : CustomStringConvertible {

        case initialized, ready, cancelled, executing, finished

        var description: String { return self.path }

        var path : String {
            switch self {
            case .initialized:
                return "isInitialized"
            case .ready:
                return "isReady"
            case .cancelled:
                return "isCancelled"
            case .finished:
                return "isFinished"
            case .executing:
                return "isExecuting"
            }
        }
    }

    private(set) var identifier : String

    //Overrides
    override open var isAsynchronous: Bool { return true }
    
    fileprivate var _state: State = .initialized {
        willSet {
            
            let _ = _stateLock.criticalScope {
                
                self.willChangeValue(forKey: newValue.path)
                self.willChangeValue(forKey: self._state.path)
            }
        }
        didSet {
            
            let _ = _stateLock.criticalScope {
                
                self.didChangeValue(forKey: oldValue.path)
                self.didChangeValue(forKey: self._state.path)
                
            }
            
            switch _state {
            case .ready:
                observers.forEach { $0.did(becomeReady: self) }
                break
            case .executing:
                observers.forEach { $0.did(start: self) }
                break
            case .finished:
                observers.forEach { $0.did(finish: self) }
                break
            case .cancelled:
                /**
                 In the case of cancellation, it is still
                 important to update the isFinished key path,
                 even if the operation did not completely
                 finish its task.
                 */
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
        checkReadyStatus()
    }

    public init(identifier: String, readyStatus : @escaping ReadyStatus) {

        self.identifier = identifier
        super.init()
        
        self.readyStatus = readyStatus
    }

    private func checkReadyStatus() -> Void {

        if self.readyStatus() == true {
            self._state = .ready
            return
        }
    }

    deinit {
        observers.removeAll()
    }

    open override func main() {
        start()
    }

    override open func start() {
        
        if isCancelled || isReady == false {
            return
        }

        _state = .executing
        execute()
    }

    public func execute() {
        finish()
    }

    public func finish() {
        _state = .finished
    }

    override open func cancel() {
        super.cancel()
        _state = .cancelled
        _state = .finished
    }

}

public extension Async {

    func remove<T : ExecutorObserver>(observer : T) where T : Equatable {

        observers.removeAll { (obs: ExecutorObserver) -> Bool in

            guard let _obs = obs as? T else { return false }
            return observer == _obs
        }
    }

    func removeAllObservers() -> Void {
        observers.removeAll()
    }

    func add(observer: ExecutorObserver) -> Void {
        observers.append(observer)
    }
    
}


