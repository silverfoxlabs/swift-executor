//
//  ExecutorObserver.swift
//  ExecutorKit
//
//
//

import Foundation

public protocol ExecutorObserver {
    
    func did(becomeReady operation: AsyncOperation) -> Void
    func did(start operation: AsyncOperation) -> Void
    func did(finish operation : AsyncOperation) -> Void
    func did(cancel operation: AsyncOperation) -> Void
}
