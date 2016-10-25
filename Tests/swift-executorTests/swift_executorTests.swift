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
        
        var op = TestOperation(testValue: "mytestvalue")
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
        
        var op = TestOperation(testValue: "mytestvalue")
        let first = TestClassObserver(testValue: "class")
        let second = TestStructObserver(testValue: "struct")
        let third = TestEnumObserver.startup
        
        op.add(observer: first)
        op.add(observer: second)
        op.add(observer: third)
        
        XCTAssertEqual(op.observers.first! as! TestClassObserver, first)
        XCTAssertEqual(op.observers[1] as! TestStructObserver, second)
        XCTAssertEqual(op.observers.last! as! TestEnumObserver, third)
    }
    
    static var allTests : [(String, (swift_executorTests) -> () throws -> Void)] {
        return [
            ("testAsyncOperationCanChangeState", testAsyncOperationCanChangeState),
        ]
    }
}

public class TestOperation: AsyncOperation {
    
    init(testValue : String) {
        
        super.init(identifier: testValue)
    }
    
    override public func execute() {
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

enum TestEnumObserver : Int, ExecutorObserver {
    
    case startup
    
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

func ==(lhs: TestClassObserver, rhs: TestClassObserver) -> Bool {
    
    return lhs === rhs
}

func ==(lhs: TestStructObserver, rhs: TestStructObserver) -> Bool {
    
    return lhs.name == rhs.name
}

func ==(lhs: TestEnumObserver, rhs: TestEnumObserver) -> Bool {
    
    return lhs.rawValue == rhs.rawValue
}

extension TestClassObserver : Equatable {}
extension TestStructObserver : Equatable {}
extension TestEnumObserver : Equatable {}

