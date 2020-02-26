//
//  IntConverter.swift
//  
//
//  Created by fritzgerald muiseroux on 26/02/2020.
//

import Foundation

public struct IntConverter: URLConverter {
    private enum Constants {
        static let regexPattern = #"[-+]?\d+"#
        static let regex = try! NSRegularExpression(pattern: regexPattern, options: [])
    }
    
    public let regexPattern = Constants.regexPattern
    
    public func toURL(_ value: Any) throws -> String {
        guard let intValue = value as? Int
            else { throw URLConverterError.formatFailed(value: value, targetType: Int.self)}
        return String(intValue)
    }
    
    public func fromURL(_ value: String) throws -> Any {
        guard let result = Constants.regex.firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)),
            
            value.index(value.startIndex, offsetBy: result.range.lowerBound) == value.startIndex,
            value.index(value.startIndex, offsetBy: result.range.upperBound)  == value.endIndex,
            let intValue = Int(value) else {
                throw URLConverterError.parsingFailed(value: value, targetType: Int.self)
        }
        return intValue
    }
}
