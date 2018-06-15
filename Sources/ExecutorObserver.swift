//
//  ExecutorObserver.swift
//  ExecutorKit
//
//  Created by dcilia on 10/25/16.
//
//

import Foundation

public protocol ExecutorObserver {
    
    func did<T>(becomeReady operation: T) -> Void
    func did<T>(start operation: T) -> Void
    func did<T>(finish operation : T) -> Void
    func did<T>(cancel operation: T) -> Void
}

public extension ExecutorObserver {

    func did<T>(becomeReady operation: T) -> Void {}
    func did<T>(start operation: T) -> Void {}
    func did<T>(finish operation : T) -> Void {}
    func did<T>(cancel operation: T) -> Void {}
}
