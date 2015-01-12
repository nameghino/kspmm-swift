//
//  String+SwiftShouldHaveThis.swift
//  kspmm
//
//  Created by Nicolas Ameghino on 1/12/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

import Foundation

extension String {
    var fullRange: NSRange {
        get {
            return NSMakeRange(0, self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        }
    }
    
    func substring(start: Int, end: Int) -> String {
        let start = advance(self.startIndex, start)
        let end = advance(self.startIndex, end)
        let subrange = Range<String.Index>(start:start, end:end)
        return self.substringWithRange(subrange)
    }
    
    func substring(range: NSRange) -> String {
        return substring(range.location, end: range.location+range.length)
    }
    
    func substring(range: Range<Int>) -> String {
        return substring(range.startIndex, end: range.endIndex)
    }
    
    subscript(range: Range<Int>) -> String {
        return self.substring(range)
    }
    
    subscript(pos: Int) -> Character {
        return self[advance(self.startIndex, pos)]
    }
}
