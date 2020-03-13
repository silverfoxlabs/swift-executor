//
//  NSLock+Extensions.swift
//  ExecutorKit
//
//
//

import Foundation

public extension NSLock {
    
    func criticalScope<T>(closure: () -> T) -> T {
        lock()
        let value = closure()
        unlock()
        return value
    }
}
