//: Playground - noun: a place where people can play
import Foundation

//Examples coming soon.
import ExecutorKit

public class ComputeOperation : AsyncOperation {

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

    init(first: Int, second: Int, identifier: String, action: Action = Action.add) {

        let obs = ComputeObserver()
        super.init(identifier: identifier, observer: obs)

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

//Overriding isReady example
let op = ComputeOperation(first: 3, second: 4, identifier: "test", action: .divide)

op.add(observer: ComputeObserver())

op.start()

//NSLock Extension example:
let lock = NSLock() //create a lock
let value = lock.criticalScope(closure: { return 3 })
print(value)

//Activity.swift Example
let activity = Activity(execute: {(first : String, last: String) -> String in
    return first + " " + last
})

let fullName = activity.run(("Silver", "Fox"))
print(fullName)


let a = Activity(execute: { return "" })
let str = a.run(())

let b = Activity(execute: {(a: Int, b: Int) -> Int in
    return a + b
})
let three = b.run((1,2))

