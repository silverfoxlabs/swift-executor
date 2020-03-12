//: Playground - noun: a place where people can play

import Foundation
import ExecutorKit

/**
Subclassing AsyncOperation use case:

 The "isSetup" property here highlights the custom implementation of how one might
 mark the operation as "ready".  Note this is optional.
 */
final class Foo: AsyncOperation {
    
    var result: Int = Int.max
    private var nums: [Int]
    private let id = "com.executorKit.foo"
    var isSetup = false

    //Custom initializer
    init(nums: [Int]) {
        self.nums = nums
        super.init(identifier: id)
    }

    //The custom implementation of "ready" state.
    override func ready() {
        if isSetup {
            super.ready()
        }
    }
    
    override func execute() {
        
        var sum = 0
        
        for i in 0..<nums.endIndex {
            sum += i
        }
        
        result = sum
        
        finish()
    }
}

struct FooObserver: ExecutorObserver, CustomStringConvertible {
    
    func did(start operation: AsyncOperation) {
        print(operation)
        print(#function)
    }
    
    func did(cancel operation: AsyncOperation) {
        print(operation)
        print(#function)
    }
    
    func did(finish operation: AsyncOperation) {
        print(operation)
        print(#function)
    }
    
    func did(becomeReady operation: AsyncOperation) {
        print(operation)
        print(#function)
    }

    var description: String {
        return "FooObserver"
    }
}


var op1 = Foo(nums: [2,4,5,6,7])
let obs = FooObserver()

op1.add(observer: obs)
op1.isSetup = true
op1.completionBlock = {
    print(op1.result)
}
op1.start()



//Example using the run closure
//note that we must use the 2nd initializer to set the ready state
var op2 = AsyncOperation(identifier: "com.executorKit.foo") //won't run, use other initializer
op2.run = {
    print("Hello World!")
}

op2.add(observer: obs)
op2.completionBlock = { print("Completion Block") }
op2.start()


var op3 = AsyncOperation(identifier: "com.executorKit.bar",readyToExecute: true)

op3.run = {
    print("Hello World")
}
op3.add(observer: obs)

op3.didStart = {
    print("did start")
}

op3.didFinish = {

    //do something here
}

//Use the "start" or add to an OperationQueue
var q = OperationQueue()
q.name = "myqueue"
q.addOperation(op3)

