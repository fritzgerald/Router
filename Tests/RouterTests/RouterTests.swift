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
    
    func testSubtitutionsPatterns() {
        let router = Router<(Int, Int) -> Int>()
        try! router.addRoute(path: "add(<int:lhs>, <int:rhs>)") { (lhs, rhs) -> Int in
            lhs + rhs
        }
        try! router.addRoute(path: "sub(<int:lhs>, <int:rhs>)") { (lhs, rhs) -> Int in
            lhs - rhs
        }
        
        let invoker: ([String: Any], (Int, Int) -> Int) throws -> Int = { (parameters, route) in
            guard let lhs = parameters["lhs"] as? Int,
                let rhs = parameters["rhs"] as? Int
                else { throw RouterError.invalidPath }
            return route(lhs, rhs)
        }
        
        XCTAssertEqual(try router.invoke("add(2, 3)", transform: invoker), 5)
        XCTAssertEqual(try router.invoke("add(-2, 3)", transform: invoker),
                       try router.invoke("sub(3, 2)", transform: invoker))
    }
    
    func testReverseRouting() {
        let router = Router<(Int, Int) -> Int>()
        try! router.addRoute(name: "add", path: "add(<int:lhs>, <int:rhs>)") { (lhs, rhs) -> Int in
            lhs + rhs
        }
        try! router.addRoute(name: "sub", path: "sub(<int:lhs>, <int:rhs>)") { (lhs, rhs) -> Int in
            lhs - rhs
        }
        
        XCTAssertEqual(router.path(name: "add", parameters: ["lhs": 2, "rhs": 3]), "add(2, 3)")
        XCTAssertEqual(router.path(name: "add", parameters: ["lhs": -2, "rhs": 3]), "add(-2, 3)")
        XCTAssertEqual(router.path(name: "add", parameters: ["rhs": 2, "lhs": 3]), "add(3, 2)")
        XCTAssertEqual(router.path(name: "sub", parameters: ["rhs": 2, "lhs": 3]), "sub(3, 2)")
        XCTAssertNil(router.path(name: "sub", parameters: ["rhs": 2]))
    }

    static var allTests = [
        ("testSimpleRoutes", testSimpleRoutes),
        ("testSubtitutionsPatterns", testSubtitutionsPatterns)
    ]
}
