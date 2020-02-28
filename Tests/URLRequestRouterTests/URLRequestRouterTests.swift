//
//  URLRequestRouterTests.swift
//  
//
//  Created by Fritzgerald MUISEROUX on 28/02/2020.
//

import XCTest
@testable import URLRequestRouter

final class URLRequestRouterTests: XCTestCase {
    let router: URLRequestRouter<Int> = {
        let router = URLRequestRouter<Int>()
        
        try! router.addRoute(path: "/") { (_, _) -> Int in
            return 0
        }
        
        try! router.addRoute(path: "/test") { (_, _) -> Int in
            return 2
        }
        
        return router
    }()
    
    func testSimpleRoutes() {
        XCTAssertEqual(try router.eval(URLRequest(url: URL(string: "https://www.somesite.com")!)), 0)
        XCTAssertEqual(try router.eval(URLRequest(url: URL(string: "https://www.somesite.com/")!)),
                       try router.eval(URLRequest(url: URL(string: "https://www.somesite.com")!)))
        XCTAssertEqual(try router.eval(URLRequest(url: URL(string: "https://www.somesite.com/test")!)), 2)
        XCTAssertEqual(try router.eval(URLRequest(url: URL(string: "https://www.somesite.com/test/")!)), 2)
        
        do {
            _ = try router.eval(URLRequest(url: URL(string: "https://www.somesite.com/somepath")!))
        }
        catch URLRequestRouterError.notFound { }
        catch { XCTFail() }
    }
}
