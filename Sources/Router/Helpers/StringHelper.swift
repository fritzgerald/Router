//
//  StringHelper.swift
//  
//
//  Created by fritzgerald muiseroux on 26/02/2020.
//

import Foundation

extension String {
    subscript(range: NSRange) -> Substring {
        let rangeIndex = index(startIndex, offsetBy: range.location)..<index(startIndex, offsetBy: range.location + range.length)
        return self[rangeIndex]
    }
    
    func replacing(range: NSRange, with replacement: String) -> String {
        let rangeIndex = index(startIndex, offsetBy: range.location)..<index(startIndex, offsetBy: range.location + range.length)
        return replacingCharacters(in: rangeIndex, with: replacement)
    }
    
    mutating func replacingSubRange(range: NSRange, with replacement: String) {
        let rangeIndex = index(startIndex, offsetBy: range.location)..<index(startIndex, offsetBy: range.location + range.length)
        replaceSubrange(rangeIndex, with: replacement)
    }
}
