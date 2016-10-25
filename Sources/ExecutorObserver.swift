//
//  ExecutorObserver.swift
//  ExecutorKit
//
//  Created by dcilia on 10/25/16.
//
//

import Foundation

public protocol ExecutorObserver {
    
    func did(becomeReady operation: AsyncOperation) -> Void
    func did(start operation: AsyncOperation) -> Void
    func did(finish operation : AsyncOperation) -> Void
    func did(cancel operation: AsyncOperation) -> Void
}
