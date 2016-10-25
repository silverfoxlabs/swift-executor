//
//  NSLock+Extensions.swift
//  ExecutorKit
//
//  Created by dcilia on 10/25/16.
//
//

import Foundation

extension NSLock {
    
    func criticalScope<T>(closure: (Void) -> T) -> T {
        lock()
        let value = closure()
        unlock()
        return value
    }
}
