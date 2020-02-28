//
//  URLRequestRouter.swift
//  
//
//  Created by Fritzgerald MUISEROUX on 28/02/2020.
//

import Foundation
import Router

public final class URLRequestRouter<T> {
    public typealias URLRequestHandler = (URLRequest, [String: Any]) throws -> T
    private let router = Router<URLRequestHandler>()
}

public enum URLRequestRouterError: Error {
    case barRequest
    case notFound
}

public extension URLRequestRouter {
    func addRoute(name: String? = nil, path: String, output: @escaping URLRequestHandler) throws {
        try router.addRoute(name: name, path: path, output: output)
    }
    
    func addRoutes(name: String? = nil, paths: [String], output: @escaping URLRequestHandler) throws {
        try router.addRoutes(name: name, paths: paths, output: output)
    }
    
    func path(name: String, parameters: [String: Any] = [:]) -> String? {
        return router.path(name: name, parameters: parameters)
    }
    
    func eval(_ request: URLRequest) throws -> T {
        guard let path = request.url?.path
            else { throw URLRequestRouterError.barRequest }
        var parameters: [String: Any] = [:]
        guard let matchRoute = try router.route(path.isEmpty ? "/" : path, parameters: &parameters)
            else { throw URLRequestRouterError.notFound }
        return try matchRoute(request, parameters)
    }
}
