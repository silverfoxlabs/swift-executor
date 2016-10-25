//
//  ExecutorObserver.swift
//  ExecutorKit
//
//  Created by dcilia on 10/25/16.
//
//

import Foundation

public protocol ExecutorObserver {
    
    func did<T : Executor>(becomeReady operation: T) -> Void
    func did<T : Executor>(start operation : T) -> Void
    func did<T : Executor>(finish operation : T) -> Void
    func did<T : Executor>(cancel operation: T) -> Void
}
