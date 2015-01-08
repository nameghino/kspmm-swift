//
//  KSPMod.swift
//  kspmm
//
//  Created by Nicolas Ameghino on 1/8/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

import Cocoa
import Foundation

class KSPMod {
    let archive: ZipArchive
    let name: String
    
    init(url: NSURL) {

        let ar = ZipArchive(file: url)!
        // find mod name
        let pattern = "GameData/([^/]+)/$"
        var error: NSError?
        let regexp = NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.DotMatchesLineSeparators, error: &error)
        for entry in ar.entries() {
            let filename = entry.fileName.lowercaseString as String
        }
        
        self.archive = ar
        self.name = (url.lastPathComponent.componentsSeparatedByString(".").first)!
    }
    
    func urlInProcessor(processor: KSPProcessor) -> NSURL {
        return NSURL()
    }
    
    func listFiles() -> [String] {
        return self.archive.listFiles()
    }
    
    func gamedataFiles() -> [String] {
        return filter(self.listFiles()) {
            (filename: String) -> (Bool) in
            let s = filename as NSString
            return s.lowercaseString.hasPrefix("gamedata")
        }
    }
}
