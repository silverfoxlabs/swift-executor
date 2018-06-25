//: Playground - noun: a place where people can play
import Foundation

//Examples coming soon.
import ExecutorKit

public final class ComputeOperation : AsyncOperation {

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

    convenience init(first: Int, second: Int, identifier: String, action: Action = Action.add) {
        self.init(identifier: identifier)
        self.first = first
        self.second = second
        self.action = action
    }

    public override func execute() {

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

//Observer usage
struct ComputeObserver : ExecutorObserver {

    func did<T>(start operation: T) where T : Executor {

        print(#function)
    }

    func did<T>(cancel operation: T) where T : Executor {
        print(#function)
    }

    func did<T>(finish operation: T) where T : Executor {

        print(#function)
        guard let op = operation as? ComputeOperation else {
            return
        }

        print(op.action)
        print(op.result)
    }

    func did<T>(becomeReady operation: T) where T : Executor {

        print(#function)
    }
}

let operation = ComputeOperation(first: 5,
                                 second: 2,
                                 identifier: "compute.add")

operation.didFinish = { [weak operation] in
    print(operation?.result ?? "Null")
}

operation.completionBlock = {
    print("hello!")
}

operation.add(observer: ComputeObserver())
operation.start()
