import XCTest
@testable import Router

final class RouterTests: XCTestCase {
    
    func testSimpleRoutes() {
        let router = Router<Int>()
        
        do {
            try router.addRoute(path: "", output: 10)
        }
        catch RouterError.invalidPath { /* OK */ }
        catch { XCTFail() }
        
        
        try! router.addRoute(path: "/", output: 10)
        try! router.addRoute(path: "/toto", output: 20)
        
        XCTAssertNil(try router.route(""))
        XCTAssertEqual(try router.route("/"), 10)
        XCTAssertEqual(try router.route("/toto"), 20)
        XCTAssertNil(try router.route("/1234"))
    }

    static var allTests = [
        ("testExample", testSimpleRoutes),
    ]
}
