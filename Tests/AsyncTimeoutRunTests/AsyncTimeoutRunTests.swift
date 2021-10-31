import XCTest
@testable import AsyncTimeoutRun

// Тестовые функция:
private func foo(completion: @escaping ()->Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        completion()
    }
}

private func fooInt(completion: @escaping (Int)->Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        completion(1)
    }
}

// Тестовый класс
private final class Test {
    func foo(completion: @escaping ()->Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion()
        }
    }

    func fooInt(completion: @escaping (Int)->Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(1)
        }
    }
}

final class AsyncTimeoutRunTests: XCTestCase {
    private let test = Test()

    func testVoidFuncSuccess() {
        let exp = expectation(description: "")
        async(timeout: 0.6, run: foo) { success in
           XCTAssertTrue(success)
           exp.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testVoidFuncTimeout() {
        let exp = expectation(description: "")
        async(timeout: 0.1, run: foo) { success in
            XCTAssertFalse(success)
            exp.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

    func testVoidFuncCallAfterTimeout() {
        let exp = expectation(description: "")
        var isFailedCall = false
        async(timeout: 0.1, run: foo, waitAfterTimeout: true) { success in
            if success {
                XCTAssertTrue(isFailedCall)
                exp.fulfill()
            } else {
                isFailedCall = true
            }
        }
        waitForExpectations(timeout: 1)
    }
}
