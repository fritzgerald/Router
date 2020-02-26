//
//  UUIDConverter.swift
//  
//
//  Created by fritzgerald muiseroux on 26/02/2020.
//

import Foundation

public struct UUIDConverter: URLConverter {
    public let regexPattern = #"[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}"#
    
    public func toURL(_ value: Any) throws -> String {
        guard let uuidValue = value as? UUID
            else { throw URLConverterError.formatFailed(value: value, targetType: UUID.self)}
        return uuidValue.uuidString
    }
    
    public func fromURL(_ value: String) throws -> Any {
        guard let uuidValue = UUID(uuidString: value)
            else { throw URLConverterError.parsingFailed(value: value, targetType: UUID.self) }
        return uuidValue
    }
}
