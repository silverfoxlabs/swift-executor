//
//  Executor.swift
//  ExecutorKit
//
//  Created by dcilia on 10/25/16.
//
//

import Foundation

public protocol Executor {
    
    associatedtype T
    var observers : [T] { get set }
    func add(observer: T) -> Void
    func remove(observer: T) -> Void
}

class _AnyExecutorBase<Observer> : Executor {
    
    typealias T = Observer
    var observers: [Observer] = []
    
    init() {
        guard type(of: self) != _AnyExecutorBase.self else {
            fatalError()
        }
    }
    
    func add(observer: Observer) {
        fatalError()
    }
    
    func remove(observer: Observer) {
        fatalError()
    }
}

final class _AnyExecutorBox<Base : Executor>: _AnyExecutorBase<Base.T> {
    
    var base : Base
    
    init(_ base: Base) {
        self.base = base
    }
}

final class AnyExecutor<Observer> : Executor {
    
    var observers: [Observer] = []
    
    func add(observer: Observer) {
        fatalError()
    }
    
    func remove(observer: Observer) {
        fatalError()
    }
    
    typealias T = Observer
    
    private let box: _AnyExecutorBase<Observer>
    
    init<Base : Executor>(_ base: Base) where Base.T == Observer {
        box = _AnyExecutorBox(base)
    }
}


//public protocol Executor {
//    
//    var observers : Array<ExecutorObserver> { get set }
//    func execute() -> Void
//    func finish() -> Void
//    mutating func add(observer: ExecutorObserver) -> Void
//}
//
//extension Executor {
//    
//    public mutating func add(observer: ExecutorObserver) -> Void {
//        observers.append(observer)
//    }
//}

