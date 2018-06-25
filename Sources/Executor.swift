//
//  Executor.swift
//  ExecutorKit
//
//  Created by dcilia on 10/25/16.
//
//

import Foundation

public protocol Executor {

    var observers : Array<ExecutorObserver> { get set }

    func execute() -> Void
    func finish() -> Void

    func add<T : ExecutorObserver>(observer: T) -> Void
    func remove<T : ExecutorObserver>(observer: T) -> Void
    func removeAllObservers() -> Void
}

public extension Executor {

    func execute() -> Void {
        fatalError("execute() must be implemented.")
    }
    func finish() -> Void {
        fatalError("finish() must be implemented.")
    }
}
