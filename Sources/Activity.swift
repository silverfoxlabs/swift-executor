//
//  Activity.swift
//  ExecutorKit
//
//  Created by  dcilia on 6/26/18.
//

import Foundation


/// Wraps a generic closure
public struct Activity<T,U> {

    public typealias ClosureType = (T) -> U

    public private(set) var run : ClosureType

    public init(execute: @escaping ClosureType) {

        self.run = execute
    }
}

