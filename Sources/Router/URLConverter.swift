//
//  URLConverter.swift
//  
//
//  Created by fritzgerald muiseroux on 26/02/2020.
//

import Foundation

public protocol URLConverter {
    var regexPattern: String { get }
    func toURL(_ value: Any) throws -> String
    func fromURL(_ value: String) throws -> Any
}

public enum URLConverterError: Error {
    case parsingFailed(value: Any, targetType: Any.Type)
    case formatFailed(value: Any, targetType: Any.Type)
    case dataInvalid(message: String)
}
