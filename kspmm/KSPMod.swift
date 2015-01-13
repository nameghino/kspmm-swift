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
    
    func listFiles() -> [String] {
        return self.archive.listFiles()
    }
    
    func remove(processor: KSPProcessor) -> NSError? {
        return nil
    }
    
    func install(processor: KSPProcessor) -> ([String]?, NSError?) {
        
        func findGameDataDirectory(directory: NSURL) -> Void {
        }
        
        let fileManager = NSFileManager.defaultManager()
        let tmpURL = NSURL(fileURLWithPath: NSTemporaryDirectory().stringByAppendingPathComponent("kspmm-\(name)"), isDirectory: true)
        var installedFiles = [String]()
        self.archive.unzipToDirectory(tmpURL!) { installedFiles.append($0) }
        
        // locate gamedata dir in tmp:
        // if exists: move tmp/kspmm-<modname>/gamedata/ contents into ksp gamedata
        // if not exists: move tmp/kspmm-<modname>/ contents into ksp gamedata
        
        
        
        /*
        var installed = [String]()
        for filepath in self.listFiles() {
            let (targetURL, indexEntry) = processor.installURLForFile(filepath)
            if let installError = self.archive.extractFile(filepath, toURL: targetURL) {
                if let removeError = self.remove(processor) {
                    return (nil, removeError)
                }
                return (nil, installError)
            }
            if countElements(indexEntry) != 0 {
                installed.append(indexEntry)
            }
        }
        return (installed, nil)
        */
        return (installedFiles, nil)
     }
    
    func gamedataFiles() -> [String] {
        return filter(self.listFiles()) {
            (filename: String) -> (Bool) in
            let s = filename as NSString
            return s.lowercaseString.hasPrefix("gamedata")
        }
    }
}
