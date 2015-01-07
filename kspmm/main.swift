//
//  main.swift
//
//
//  Created by Nicolas Ameghino on 1/7/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

import Foundation

func getPath() -> NSURL? {
    var pathComponents = NSProcessInfo.processInfo().arguments[0] as String
    return NSURL(fileURLWithPath: pathComponents)?.URLByDeletingLastPathComponent
}

class ZipArchive {
    
    let archive: ZZArchive
    
    init(file: NSURL) {
        var error: NSErrorPointer = nil
        archive = ZZArchive(URL: file, error: error)
    }
    
    func unzipToDirectory(directory: NSURL) -> Bool {
        let fileManager = NSFileManager.defaultManager();
        var error: NSErrorPointer = nil
        for entry in self.archive.entries as [ZZArchiveEntry] {
            let targetPath = directory.URLByAppendingPathComponent(entry.fileName)
            
            let mode = entry.fileMode as UInt16
            let mask = S_IFDIR
            
            let checkDirectory = mode & mask != 0;
            
            if (checkDirectory) {
                fileManager.createDirectoryAtURL(targetPath,
                    withIntermediateDirectories: true,
                    attributes: nil,
                    error: error)
                
                if (error != nil) {
                    return false;
                }
            } else {
                fileManager.createDirectoryAtURL(targetPath.URLByDeletingLastPathComponent!,
                    withIntermediateDirectories: true,
                    attributes: nil,
                    error: error)
                
                let fileData = entry.newDataWithError(error)
                fileData.writeToURL(targetPath, atomically: false)
                
                if (fileData == nil || error != nil) {
                    return false;
                }
            }
        }
        return true
    }
}

func parseJSONFile(url: NSURL) -> (NSError?, NSDictionary) {
    let data = NSData(contentsOfURL: url)
    var error: NSError? = nil
    let object = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: &error) as NSDictionary
    return (error, object)
}

func parseConfigFile() -> (NSError?, NSDictionary) {
    let url = NSURL(fileURLWithPath: "/Users/install/.kspmm")
    return parseJSONFile(url!)
}

// program
let (error, config) = parseConfigFile()
if (error != nil) {
    println("\(error?.localizedDescription)")
}
println("\(config)")