//
//  ExecutorObserver.swift
//  ExecutorKit
//
//  Created by dcilia on 10/25/16.
//
//

import Foundation

public protocol ExecutorObserver {

    func did(becomeReady operation: Executor) -> Void
    func did(start operation: Executor) -> Void
    func did(finish operation : Executor) -> Void
    func did(cancel operation: Executor) -> Void

}
