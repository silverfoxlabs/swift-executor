//
//  ExecutorObserver.swift
//  ExecutorKit
//
//  Created by dcilia on 10/25/16.
//
//

import Foundation

public protocol ExecutorObserver {
    
    associatedtype T
    
    func did(becomeReady operation: T) -> Void
    func did(start operation : T) -> Void
    func did(finish operation: T) -> Void
    func did(cancel operation: T) -> Void
}

public class _AnyExecutorObserverBase<U> : ExecutorObserver, Equatable {
    
    public static func ==(lhs: _AnyExecutorObserverBase<U>, rhs: _AnyExecutorObserverBase<U>) -> Bool {
        return lhs === rhs
    }
    
    public func did(becomeReady operation: U) {
        fatalError()
    }
    
    public func did(cancel operation: U) {
        fatalError()
    }
    
    public func did(finish operation: U) {
        fatalError()
    }
    
    public func did(start operation: U) {
        fatalError()
    }
    
    public typealias T = U
    
    init() {
        guard type(of: self) != _AnyExecutorObserverBase.self else {
            fatalError()
        }
    }
}

final class _AnyExecutorObserverBox<Base : ExecutorObserver> : _AnyExecutorObserverBase<Base.T> {
    
    var base : Base
    public init(_ base: Base) { self.base = base }
}

public final class AnyExecutorObserver<T> : ExecutorObserver, Equatable {
    public static func ==(lhs: AnyExecutorObserver<T>, rhs: AnyExecutorObserver<T>) -> Bool {
        return lhs === rhs
    }
    
    public func did(becomeReady operation: T) {
        fatalError()
    }
    
    public func did(start operation: T) {
        fatalError()
    }
    
    public func did(finish operation: T) {
        fatalError()
    }
    
    public func did(cancel operation: T) {
        fatalError()
    }
    
    private let box: _AnyExecutorObserverBase<T>
    init<Base : ExecutorObserver>(_ base: Base) where Base.T == T {
        box = _AnyExecutorObserverBox(base)
        
    }
}
