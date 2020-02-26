//
//  DateConverter.swift
//  
//
//  Created by fritzgerald muiseroux on 26/02/2020.
//

import Foundation

public enum DateConverter: URLConverter {
    case yearMonthDayGMT
    case custom(regexPattern: String, formatter: DateFormatter)
    
    public var regexPattern: String {
        switch self {
        case .yearMonthDayGMT:
            return #"\d{4}-\d{2}-\d{2}"#
        case let .custom(regexPattern: pattern, formatter: _):
            return pattern
        }
    }
    
    public func toURL(_ value: Any) throws -> String {
        guard let dateValue = value as? Date
            else { throw URLConverterError.formatFailed(value: value, targetType: Date.self) }
        return formatter.string(from: dateValue)
    }
    
    public func fromURL(_ value: String) throws -> Any {
        guard let date = formatter.date(from: value)
            else { throw URLConverterError.parsingFailed(value: value, targetType: Date.self) }
        return date
    }
}

private extension DateConverter {
    enum Constants {
        static let defaultFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            return formatter
        }()
    }
    
    var formatter: DateFormatter {
        switch self {
        case .yearMonthDayGMT:
            return Constants.defaultFormatter
        case let .custom(regexPattern: _, formatter: formatter):
            return formatter
        }
    }
}
