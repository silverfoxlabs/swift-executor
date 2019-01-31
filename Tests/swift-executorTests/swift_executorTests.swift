import XCTest
@testable import ExecutorKit

var exp : XCTestExpectation? = nil
var queue : OperationQueue = {
    let queue = OperationQueue()
    queue.name = "com.executorkit.queue"
    return queue
}()

class swift_executorTests: XCTestCase {

    let operationId = "operation"
    let classObserverId = "class"
    let structObserverId = "struct"
    let timeoutId = "operationTimeout"

    func testAsyncOperationCanChangeState() -> Void {
        
        let op = TestOperation(identifier: operationId)
        let first = TestClassObserver(testValue: classObserverId)
        let second = TestStructObserver(testValue: structObserverId)
        let third = TestEnumObserver.startup

        op.add(observer: first)
        op.add(observer: second)
        op.add(observer: third)

        let expectation = XCTestExpectation(description: timeoutId)

        op.completionBlock = {
            expectation.fulfill()
        }

        op.start()
        wait(for: [expectation], timeout: 10)

    }
    
    
    func testThatCanAddObserver() -> Void {
        
        let op = TestOperation(identifier: operationId)
        let first = TestClassObserver(testValue: classObserverId)
        let second = TestStructObserver(testValue: structObserverId)
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

        let op = TestOperation(identifier: operationId)
        let first = TestClassObserver(testValue: classObserverId)
        let second = TestStructObserver(testValue: structObserverId)
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
        
        let op = TestOperation(identifier: operationId)
        let obs = TestClassObserver(testValue: classObserverId)
        op.add(observer: obs)
        op.cancel()
        XCTAssertTrue(op.isFinished == true)
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


    func did(becomeReady operation: Executor) {

        guard let operation = operation as? AsyncOperation else {
            XCTAssert(true)
            return
        }

        XCTAssert(operation.isCancelled == false)
        XCTAssert(operation.isReady == true)
        XCTAssert(operation.isFinished == false)
        XCTAssert(operation.isExecuting == false)
    }
    
    func did(start operation: Executor) {

        guard let operation = operation as? AsyncOperation else {
            XCTAssert(true)
            return
        }

        XCTAssert(operation.isCancelled == false)
        XCTAssert(operation.isReady == false)
        XCTAssert(operation.isFinished == false)
        XCTAssert(operation.isExecuting == true)
    }
    
    func did(cancel operation: Executor) {

        guard let operation = operation as? AsyncOperation else {
            XCTAssert(true)
            return
        }

        XCTAssert(operation.isCancelled == true)
        XCTAssert(operation.isReady == false)
        XCTAssert(operation.isFinished == false)
        XCTAssert(operation.isExecuting == false)
    }
    
    func did(finish operation: Executor) {

        guard let operation = operation as? AsyncOperation else {
            XCTAssert(true)
            return
        }

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

    func did(becomeReady operation: Executor) {
        guard let _operation = operation as? AsyncOperation else {
            XCTAssert(true)
            return
        }

        XCTAssert(_operation.isCancelled == false)
        XCTAssert(_operation.isReady == true)
        XCTAssert(_operation.isFinished == false)
        XCTAssert(_operation.isExecuting == false)
    }
    func did(finish operation: Executor) {

        guard let _operation = operation as? AsyncOperation else {
            XCTAssert(true)
            return
        }

        XCTAssert(_operation.isCancelled == false)
        XCTAssert(_operation.isReady == false)
        XCTAssert(_operation.isFinished == true)
        XCTAssert(_operation.isExecuting == false)
    }

    func did(start operation: Executor) {

        guard let _operation = operation as? AsyncOperation else {
            XCTAssert(true)
            return
        }

        XCTAssert(_operation.isCancelled == false)
        XCTAssert(_operation.isReady == false)
        XCTAssert(_operation.isFinished == false)
        XCTAssert(_operation.isExecuting == true)
    }
    func did(cancel operation: Executor) {

        guard let _operation = operation as? AsyncOperation else {
            XCTAssert(true)
            return
        }

        XCTAssert(_operation.isCancelled == true)
        XCTAssert(_operation.isReady == false)
        XCTAssert(_operation.isFinished == false)
        XCTAssert(_operation.isExecuting == false)
    }
}


enum TestEnumObserver : Int, ExecutorObserver {
    
    case startup
    
    func did(becomeReady operation: Executor) {
        guard let _operation = operation as? AsyncOperation else {
            XCTAssert(true)
            return
        }
        XCTAssert(_operation.isCancelled == false)
        XCTAssert(_operation.isReady == true)
        XCTAssert(_operation.isFinished == false)
        XCTAssert(_operation.isExecuting == false)
    }
    
    func did(start operation: Executor) {

        guard let _operation = operation as? AsyncOperation else {
            XCTAssert(true)
            return
        }

        XCTAssert(_operation.isCancelled == false)
        XCTAssert(_operation.isReady == false)
        XCTAssert(_operation.isFinished == false)
        XCTAssert(_operation.isExecuting == true)
    }
    
    func did(cancel operation: Executor) {
        guard let _operation = operation as? AsyncOperation else {
            XCTAssert(true)
            return
        }
        XCTAssert(_operation.isCancelled == true)
        XCTAssert(_operation.isReady == false)
        XCTAssert(_operation.isFinished == false)
        XCTAssert(_operation.isExecuting == false)
    }
    
    func did(finish operation: Executor) {
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

