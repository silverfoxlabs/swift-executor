//
//  AsyncOperation.swift
//  ExecutorKit
//
//  Created by dcilia on 10/25/16.
//
//

import Foundation


/// Concurrent operation
open class AsyncOperation : Operation, Executor {

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


    /**
     When you add an operation to an operation queue, the queue ignores the value of the isAsynchronous property and always calls the start() method from a separate thread. Therefore, if you always run operations by adding them to an operation queue, there is no reason to make them asynchronous.
     */
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

            print(#function)
            
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
                _state = .finished
                break
            case .initialized:
                //no-op
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


    public init(identifier: String, observer: ExecutorObserver? = nil) {

        if let obs = observer {
            observers.append(obs)
        }

        self.identifier = identifier
        super.init()

        _state = .ready

        print(#function)
        print("Observers = \(observers)")
    }


    deinit {
        print(#function)
        observers.removeAll()
    }

    open override func main() {
        print(#function)
        start()
    }

    override open func start() {

        print(#function)
        
        if isCancelled || isReady == false {
            return
        }

        _state = .executing
        execute()
    }

    open func execute() {
        print(#function)
        finish()
    }

    open func finish() {
        print(#function)
        _state = .finished
    }

    override open func cancel() {
        super.cancel()
        _state = .cancelled
        _state = .finished
    }

}

public extension AsyncOperation {

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


