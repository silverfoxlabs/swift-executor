//
//  NSLock+Extensions.swift
//  ExecutorKit
//
//  Created by dcilia on 10/25/16.
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
