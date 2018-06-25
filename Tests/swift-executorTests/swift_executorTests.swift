import XCTest
@testable import ExecutorKit

var exp : XCTestExpectation? = nil
var queue : OperationQueue = {
    let queue = OperationQueue()
    queue.name = "com.executorkit.queue"
    return queue
}()

class swift_executorTests: XCTestCase {

    func testAsyncOperationCanChangeState() -> Void {
        
        let op = TestOperation(testValue: "mytestvalue")
        let first = TestClassObserver(testValue: "class")
        let second = TestStructObserver(testValue: "struct")
        let third = TestEnumObserver.startup

        op.add(observer: first)
        op.add(observer: second)
        op.add(observer: third)


        exp = expectation(description: "operationTimeout")
        op.completionBlock = {
            exp?.fulfill()
        }
        queue.addOperation(op)
        
        waitForExpectations(timeout: 60) { (e: Error?) in
           
            if let _ = e {
                XCTAssertFalse(true)
            }
        }
    }
    
    func testThatCanAddObserver() -> Void {
        
        let op = TestOperation(testValue: "mytestvalue")
        let first = TestClassObserver(testValue: "class")
        let second = TestStructObserver(testValue: "struct")
        let third = TestEnumObserver.startup
        
        op.add(observer: first)
        op.add(observer: second)
        op.add(observer: third)


        let _first = op.observers.first as? TestClassObserver
        let _second = op.observers[1] as? TestStructObserver
        let _last = op.observers.last as? TestEnumObserver


        XCTAssertEqual(_first, first)
        XCTAssertEqual(_second, second)
        XCTAssertEqual(_last, third)
    }

    func testThatCanRemoveObserver() -> Void {

        let op = TestOperation(testValue: "mytestvalue")
        let first = TestClassObserver(testValue: "class")
        let second = TestStructObserver(testValue: "struct")
        let third = TestEnumObserver.startup

        op.add(observer: first)
        op.add(observer: second)
        op.add(observer: third)

        let _first = op.observers.first as? TestClassObserver
        let _second = op.observers[1] as? TestStructObserver
        let _last = op.observers.last as? TestEnumObserver


        XCTAssertEqual(_first, first)
        XCTAssertEqual(_second, second)
        XCTAssertEqual(_last, third)

        print(op.observers.count)

        op.remove(observer: first)
        op.remove(observer: second)
        op.remove(observer: third)

        XCTAssertTrue(op.observers.count == 0)
    }
    
    func testThatCanCancel() -> Void {
        
        let op = TestOperation(testValue: "mytestvalue")
        let obs = TestClassObserver(testValue: "class")
        op.add(observer: obs)
        op.cancel()
        XCTAssertTrue(op.isCancelled == true)
    }
    
    func testThatCanUseClosures() -> Void {
        let op = TestOperation(testValue: "mytestvalue")
        op.didBecomeReady = { [weak op] in
            XCTAssert(op?.isReady == true)
        }
        op.didStart = { [weak op] in
            XCTAssert(op?.isExecuting == true)
        }
        op.didFinish = { [weak op] in
            XCTAssert(op?.isFinished == true)
        }

        op.start()
        
    }
    
    func testThatCanCancelWithClosure() -> Void {
        
        let op = TestOperation(testValue: "mytestvalue")
        op.didCancel = { [weak op] in
            XCTAssert(op?.isCancelled == true)
        }
        op.cancel()
    }
    
    static var allTests : [(String, (swift_executorTests) -> () throws -> Void)] {
        return [
            ("testAsyncOperationCanChangeState", testAsyncOperationCanChangeState),
            ("testThatCanAddObserver", testThatCanAddObserver),
            ("testThatCanCancel", testThatCanCancel)
        ]
    }
}

public class TestOperation: AsyncOperation {
    
    init(testValue : String) {
        
        super.init(identifier: testValue)
    }

    public override func execute() {
        print(#function)
        XCTAssert(isCancelled == false)
        XCTAssert(isReady == false)
        XCTAssert(isFinished == false)
        XCTAssert(isExecuting == true)

        finish()
    }

    override public func finish() {
        super.finish()
        print(#function)
        XCTAssert(isCancelled == false)
        XCTAssert(isReady == false)
        XCTAssert(isFinished == true)
        XCTAssert(isExecuting == false)
    }
    
}

class TestClassObserver: ExecutorObserver {
    
    let name : String
    
    init(testValue : String) {
        name = testValue
    }


    func did(becomeReady operation: AsyncOperation) {
        XCTAssert(operation.isCancelled == false)
        XCTAssert(operation.isReady == true)
        XCTAssert(operation.isFinished == false)
        XCTAssert(operation.isExecuting == false)
    }
    
    func did(start operation: AsyncOperation) {
        XCTAssert(operation.isCancelled == false)
        XCTAssert(operation.isReady == false)
        XCTAssert(operation.isFinished == false)
        XCTAssert(operation.isExecuting == true)
    }
    
    func did(cancel operation: AsyncOperation) {
        XCTAssert(operation.isCancelled == true)
        XCTAssert(operation.isReady == false)
        XCTAssert(operation.isFinished == false)
        XCTAssert(operation.isExecuting == false)
    }
    
    func did(finish operation: AsyncOperation) {
        XCTAssert(operation.isCancelled == false)
        XCTAssert(operation.isReady == false)
        XCTAssert(operation.isFinished == true)
        XCTAssert(operation.isExecuting == false)
    }
}

struct TestStructObserver : ExecutorObserver {
    
    let name : String
    
    init(testValue : String) {
        name = testValue
    }

    func did<T>(becomeReady operation: T) where T : Executor {

        guard let _operation = operation as? AsyncOperation else {
            XCTAssert(true)
            return
        }

        XCTAssert(_operation.isCancelled == false)
        XCTAssert(_operation.isReady == true)
        XCTAssert(_operation.isFinished == false)
        XCTAssert(_operation.isExecuting == false)
    }

    func did<T>(start operation: T) where T : Executor {

        guard let _operation = operation as? AsyncOperation else {
            XCTAssert(true)
            return
        }

        XCTAssert(_operation.isCancelled == false)
        XCTAssert(_operation.isReady == false)
        XCTAssert(_operation.isFinished == false)
        XCTAssert(_operation.isExecuting == true)
    }

    func did<T>(cancel operation: T) where T : Executor {

        guard let _operation = operation as? AsyncOperation else {
            XCTAssert(true)
            return
        }

        XCTAssert(_operation.isCancelled == true)
        XCTAssert(_operation.isReady == false)
        XCTAssert(_operation.isFinished == false)
        XCTAssert(_operation.isExecuting == false)
    }

    func did<T>(finish operation: T) where T : Executor {

        guard let _operation = operation as? AsyncOperation else {
            XCTAssert(true)
            return
        }

        XCTAssert(_operation.isCancelled == false)
        XCTAssert(_operation.isReady == false)
        XCTAssert(_operation.isFinished == true)
        XCTAssert(_operation.isExecuting == false)
    }
}


enum TestEnumObserver : Int, ExecutorObserver {
    
    case startup
    
    func did<T : Executor>(becomeReady operation: T) {
        guard let _operation = operation as? AsyncOperation else {
            XCTAssert(true)
            return
        }
        XCTAssert(_operation.isCancelled == false)
        XCTAssert(_operation.isReady == true)
        XCTAssert(_operation.isFinished == false)
        XCTAssert(_operation.isExecuting == false)
    }
    
    func did<T : Executor>(start operation: T) {

        guard let _operation = operation as? AsyncOperation else {
            XCTAssert(true)
            return
        }

        XCTAssert(_operation.isCancelled == false)
        XCTAssert(_operation.isReady == false)
        XCTAssert(_operation.isFinished == false)
        XCTAssert(_operation.isExecuting == true)
    }
    
    func did<T : Executor>(cancel operation: T) {
        guard let _operation = operation as? AsyncOperation else {
            XCTAssert(true)
            return
        }
        XCTAssert(_operation.isCancelled == true)
        XCTAssert(_operation.isReady == false)
        XCTAssert(_operation.isFinished == false)
        XCTAssert(_operation.isExecuting == false)
    }
    
    func did<T: Executor>(finish operation: T) {
        guard let _operation = operation as? AsyncOperation else {
            XCTAssert(true)
            return
        }
        XCTAssert(_operation.isCancelled == false)
        XCTAssert(_operation.isReady == false)
        XCTAssert(_operation.isFinished == true)
        XCTAssert(_operation.isExecuting == false)
    }
}

extension TestStructObserver : Equatable {}
extension TestClassObserver : Equatable {}
extension TestEnumObserver : Equatable {}

func ==(lhs: TestClassObserver, rhs: TestClassObserver) -> Bool {
    
    return lhs === rhs
}

func ==(lhs: TestStructObserver, rhs: TestStructObserver) -> Bool {
    
    return lhs.name == rhs.name
}

func ==(lhs: TestEnumObserver, rhs: TestEnumObserver) -> Bool {
    
    return lhs.rawValue == rhs.rawValue
}

