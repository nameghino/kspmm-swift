//
//  ZipArchive.swift
//  kspmm
//
//  Created by Nicolas Ameghino on 1/8/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

import Cocoa
import Foundation

class ZipArchive {
    
    let archive: ZZArchive
    let index: [String: ZZArchiveEntry]
    init?(file: NSURL) {
        var error: NSError?
        var t_index = [String: ZZArchiveEntry]()
        self.archive = ZZArchive(URL: file, error: &error)
        if let e = error {
            self.index = t_index
            println("error creating archive: \(e.localizedDescription)")
            return nil
        }
        for entry in archive.entries as [ZZArchiveEntry] {
            t_index[entry.fileName] = entry
        }
        self.index = t_index
    }
    
    func listFiles() -> [String] {
        return map(self.entries()) {
            (entry: ZZArchiveEntry) -> String in
            return entry.fileName
        }
    }
    
    func entryForPath(filepath: String) -> ZZArchiveEntry? {
        if let e = self.index[filepath] {
            return e
        }
        return nil
    }
    
    func extractFile(filepath: String, toURL url: NSURL) -> NSError? {
        println("extracting \"\(filepath)\" to \"\(url.absoluteString)\"")
        if let entry = self.entryForPath(filepath) {
            let fileManager = NSFileManager.defaultManager()
            var error: NSError?
            let directoryURL = url.URLByDeletingLastPathComponent!
            
            if !fileManager.fileExistsAtPath(directoryURL.absoluteString!) {
                if !fileManager.createDirectoryAtURL(directoryURL, withIntermediateDirectories: true, attributes: nil, error: &error) {
                    return error
                }
            }
            
            let fileData = entry.newDataWithError(&error)
            if let e = error {
                return e
            }
            fileData.writeToURL(url, atomically: false)
        }
        return nil
    }
    
    func unzipToDirectory(directory: NSURL, afterBlock: (String -> Void)) -> Bool {
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
                afterBlock(entry.fileName)
                
                if (fileData == nil || error != nil) {
                    return false;
                }
            }
        }
        return true
    }
    
    func entries() -> [ZZArchiveEntry] {
        return self.archive.entries as [ZZArchiveEntry]
    }
}
