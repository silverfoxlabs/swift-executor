//
//  Executor.swift
//  ExecutorKit
//
//  Created by dcilia on 10/25/16.
//
//

import Foundation

public protocol Executor : class {

    var observers : Array<ExecutorObserver> { get set }

    func execute() -> Void
    func finish() -> Void

    func add(observer: ExecutorObserver) -> Void
    func remove<T : ExecutorObserver>(observer: T) -> Void
    func removeAllObservers() -> Void
}

public extension Executor {

    public func add(observer: ExecutorObserver) -> Void {
        observers.append(observer)
    }

    public func remove<T>(observer: T) -> Void {}

    public func remove<T>(observer: T) -> Void where T : Equatable {
        self.observers.removeAll { (obs) -> Bool in

            guard let _obs = obs as? T else { return false }
            return _obs == observer
        }
    }

    public func removeAllObservers() -> Void {
        observers.removeAll()
    }
}
