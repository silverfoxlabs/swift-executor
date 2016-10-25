//
//  AsyncOperation.swift
//  ExecutorKit
//
//  Created by dcilia on 10/25/16.
//
//

import Foundation

public class AsyncOperation : Operation, Executor {
        
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
    
    fileprivate struct KVO {
        static let IsReadyKeyPath : String = "isReady"
        static let IsExecutingKeyPath : String = "isExecuting"
        static let IsFinishedKeyPath : String = "isFinished"
        static let IsCancelled : String = "isCancelled"
        static let NotReady : String = "notReady"
    }
    
    public var observers: Array<ExecutorObserver> = []
    
    private(set) var identifier : String
    
    //Overrides
    override public var isAsynchronous: Bool { return true }
    
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
                observers.forEach { $0.did(becomeReady: self) }
                break
            case .executing:
                observers.forEach { $0.did(start: self) }
                break
            case .finished:
                observers.forEach { $0.did(finish: self) }
                break
            case .cancelled:
                observers.forEach { $0.did(cancel: self) }
                break
            default:
                break
            }
        }
    }
    
    public override var isReady: Bool {
        return _state == .ready
    }
    
    public override var isCancelled: Bool {
        return _state == .cancelled
    }
    
    public override var isFinished: Bool {
        return _state == .finished
    }
    
    public override var isExecuting: Bool {
        return _state == .executing
    }
    
    init(identifier: String) {

        self.identifier = identifier
        super.init()
        _state = .ready
    }
    
    deinit {
        observers.removeAll()
    }
    
    public func execute() -> Void {}
    
    public override func main() {}
    
    override public func cancel() {
        super.cancel()
        _state = .cancelled
        
    }
    
    override public func start() {
        
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
}
