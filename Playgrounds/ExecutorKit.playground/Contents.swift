//: Playground - noun: a place where people can play
import Foundation

//Examples coming soon.
import ExecutorKit

public class ComputeOperation : Async {

    public enum Action {
        case add
        case subtract
        case multiply
        case divide
    }

    var first : Int = 0
    var second : Int = 0
    var result : Int = 0
    var action : Action = .add

    init(first: Int, second: Int, identifier: String, action: Action = Action.add, status: Closure? = nil) {

        if let _status = status {
            super.init(identifier: identifier, readyStatus: _status)
        } else {
            super.init(identifier: identifier)
        }

        self.first = first
        self.second = second
        self.action = action
    }

    public func execute() {

        print(#function)


        if isReady == false {
            print("You must set the ready to true")
            return
        }


        print(#function)
        switch action {
        case .add:
            do {
                result = first + second
            }
            break
        case .multiply:
            do {
                result = first * second
            }
            break
        case .subtract:
            do {
                result = first - second
            }
            break
        case .divide:
            do {
                result = first / second
            }
            break
        }

        finish()
    }
}

//Working with isReady
public class PomputeOp : ComputeOperation {
    var manuallySetToReady = false

    public override var isReady: Bool {
        return manuallySetToReady
    }
}

//Observer usage
struct ComputeObserver : ExecutorObserver {
    func did(becomeReady operation: Executor) {
        print(#function)
    }

    func did(start operation: Executor) {
        print(#function)
    }

    func did(finish operation: Executor) {
        print(#function)
    }

    func did(cancel operation: Executor) {
        print(#function)
    }
}

var operation = ComputeOperation(first: 5,
                                 second: 2,
                                 identifier: "compute.add")

operation.completionBlock = {
    print("Completion Block")

    let p = Activity(execute: {print("Awesome this works!")})
    p.run(())
}

operation.start()


