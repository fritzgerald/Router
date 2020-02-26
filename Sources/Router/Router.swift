
import Foundation

/// Struct that link a pattern to an output
struct Route<Output> {
    /// Name of the route, mostly used for url generation
    var name: String?
    
    /// The definition of the route.
    /// May contain subtitution patterns in order to add parameters to the route
    var path: String
    
    /// A regex pattern that paths should validate in order to conform to this route
    var pattern: String
    
    /// Output attached to this route
    var output: Output
    
    /// A dictionary of parameters and converter defined in the path of this route
    var parameters: [String: URLConverter]
}

public class Router<Output> {
    private var routes: [Route<Output>] = []
    private var converters: [String: URLConverter] = [:]
    
    init() {
        converters["int"] = IntConverter()
        converters["date"] = DateConverter.yearMonthDayGMT
        converters["str"] = StringConverter()
        converters["uuid"] = UUIDConverter()
    }
    
    func addRoute(name: String? = nil, path: String, output: Output) throws {
        try routes.append(createRoute(name: name, path: path, output: output))
    }
    
    func addRoutes(name: String? = nil, paths: [String], output: Output) throws {
        try routes.append(contentsOf: paths.map({ try createRoute(name: name, path: $0, output: output) }))
    }
    
    func route(_ path: String) throws -> Output? {
        var params: [String: Any] = [:]
        let output = try route(path, parameters: &params)
        return output
    }
    
    func route(_ path: String, parameters: inout [String: Any]) throws -> Output? {
        let result = routes.compactMap { route -> (NSTextCheckingResult, Route<Output>)? in
            guard
                let regex = try? NSRegularExpression(pattern: route.pattern, options: [.caseInsensitive]),
                let match = regex.firstMatch(in: path, options: [], range: NSRange(location: 0, length: path.count)),
                match.range.length == path.count
                else { return nil }
            return (match, route)
        }.first
        
        guard case let .some(match, route) = result else { return nil }
        try route.parameters.forEach { (key, converter) in
            let pathRange = match.range(withName: key)
            parameters.updateValue(try converter.fromURL(String(path[pathRange])), forKey: key)
        }
        return route.output
    }
    
    func path(name: String, parameters: [String: Any] = [:]) throws -> String? {
        try routes
            .filter { $0.name == name }
            .compactMap { route -> String? in
                let matches = RouterConstants.substitutionRegex.matches(in: route.path,
                                                                        options: [],
                                                                        range: NSRange(location: 0, length: route.path.count))
                
                guard matches.count > 0 else { return route.path }
                guard matches.count == parameters.count else { return nil }
                
                var outputString = ""
                var previousRange = NSRange(location: 0, length: 0)
                for result in matches {
                    let previousLocation = previousRange.location + previousRange.length
                    outputString.append(contentsOf: route.path[NSRange(location: previousLocation, length: result.range.location - previousLocation)])
                    let typeRange = result.range(at: 1)
                    let nameRange = result.range(at: 2)
                    
                    let type = String(route.path[typeRange])
                    let name = String(route.path[nameRange])
                    guard let paramValue = parameters[name]
                        else { return nil }
                    
                    guard let converter = converters[type]
                        else { throw RouterError.converterNotfound(name: type) }
                    outputString.append(contentsOf: try converter.toURL(paramValue))
                    previousRange = result.range
                }
                
                let lastReplaceIndex = route.path.index(route.path.startIndex, offsetBy: previousRange.location + previousRange.length)
                if lastReplaceIndex < route.path.endIndex {
                    outputString.append(contentsOf: route.path[lastReplaceIndex..<route.path.endIndex])
                }
                return outputString
        }.first
    }
}

public enum RouterError: Swift.Error {
    case invalidPath
    case converterNotfound(name: String)
}

fileprivate enum RouterConstants {
    static let substitutionRegex = try! NSRegularExpression(pattern: #"<(\w+):(\w+)>"#, options: .caseInsensitive)
}

private extension Router {
    func createRoute(name: String?, path: String, output: Output) throws -> Route<Output> {
        guard !path.isEmpty else { throw RouterError.invalidPath }
        
        let matches = RouterConstants.substitutionRegex.matches(in: path,
                                                                options: [],
                                                                range: NSRange(location: 0, length: path.count))
        guard matches.count > 0
            else { return .init(name: name, path: path, pattern:path, output: output, parameters: [:]) }
        
        var outputString = ""
        var parameters = [String: URLConverter]()
        var previousRange = NSRange(location: 0, length: 0)
        try matches.forEach { result in
            let previousLocation = previousRange.location + previousRange.length
            outputString.append(contentsOf: path[NSRange(location: previousLocation, length: result.range.location - previousLocation)])
            let typeRange = result.range(at: 1)
            let nameRange = result.range(at: 2)
            
            let type = String(path[typeRange])
            let name = String(path[nameRange])
            guard let converter = converters[type]
                else { throw RouterError.converterNotfound(name: type) }
            outputString.append(contentsOf: "(?<\(name)>\(converter.regexPattern))")
            parameters.updateValue(converter, forKey: name)
            previousRange = result.range
        }
        
        let lastReplaceIndex = path.index(path.startIndex, offsetBy: previousRange.location + previousRange.length)
        if lastReplaceIndex < path.endIndex {
            outputString.append(contentsOf: path[lastReplaceIndex..<path.endIndex])
        }
        return .init(name: name, path: path, pattern: outputString, output: output, parameters: parameters)
    }
}
