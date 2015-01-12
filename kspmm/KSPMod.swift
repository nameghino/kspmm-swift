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
        let regexp = NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive, error: &error)

        var modName = "NO_MOD_NAME"
        for entry in ar.entries() {
            let filename = entry.fileName as String
            if let match = regexp?.firstMatchInString(filename, options: .allZeros, range: filename.fullRange) {
                let matchRange = match.rangeAtIndex(1)
                let t_modName = filename.substring(matchRange)
                modName = t_modName
                break
            }
        }

        self.name = modName
        self.archive = ar
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
