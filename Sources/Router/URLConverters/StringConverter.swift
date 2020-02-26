//
//  StringConverter.swift
//  
//
//  Created by fritzgerald muiseroux on 26/02/2020.
//

import Foundation

public struct StringConverter: URLConverter {
    public let regexPattern = ".*"
    
    public func toURL(_ value: Any) throws -> String {
        guard let stringValue = value as? String
            else { throw URLConverterError.formatFailed(value: value, targetType: String.self) }
        guard stringValue.trimmingCharacters(in: .whitespacesAndNewlines).count > 0
            else { throw URLConverterError.dataInvalid(message: "Failed to convert value must be a non empty string") }
        
        return stringValue
    }
    
    public func fromURL(_ value: String) throws -> Any {
        guard value.trimmingCharacters(in: .whitespacesAndNewlines).count > 0
            else { throw URLConverterError.dataInvalid(message: "Failed to parse value must be a non empty string") }
        return value
    }
}
