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
    
    init?(file: NSURL) {
        var error: NSError?
        self.archive = ZZArchive(URL: file, error: &error)
        if let e = error {
            println("error creating archive: \(e.localizedDescription)")
            return nil
        }
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
}

let KSPDirectoryKey = "KSPDirectory"
let KSPInstalledModsKey = "KSPMMInstalledMods"

enum KSPConfigKeys: String, Hashable {
    case KSPDirectory = "KSPDirectory"
    case InstalledMods = "KSPMMInstalledMods"
}

func == (lhs: KSPConfigKeys, rhs: KSPConfigKeys) -> Bool {
    return lhs.rawValue == rhs.rawValue
}


class KSPMod {
    let archive: ZipArchive
    let name: String
    
    init(url: NSURL) {
        self.name = (url.lastPathComponent?.componentsSeparatedByString(".").first)!
        self.archive = ZipArchive(file: url)!
    }
    
    func urlInProcessor(processor: KSPProcessor) -> NSURL {
        return NSURL()
    }
}

class KSPProcessor {
    /*
     * Ideas for the processor:
     * - should work on a single KSP installation instance
     *      - therefore, it requires the target KSP installation path
     *      - therefore, the config file should either 
     *          A) not exist
     *          B) have relative paths
     *          C) only contain KSPMM-related information such as installed mods
     *      - (going with C, I think)
     *      - therefore, the PWD can be taken or the user can put it into the program (i.e.: on a GUI)
     * - should provide access to the URLs for a KSPMod to yield complete URLs (or not)
     *      - if not, it should provide URL-building facilities for target mod
     */
    
    
    
    var config: [String:AnyObject]
    let targetDirectory: NSURL
    
    init?(targetDirectory: NSURL) {
        self.targetDirectory = targetDirectory
        let (err, config) = KSPProcessor.loadConfig(self.targetDirectory)
        if let e = err {
            NSLog("error initializing processor: \(e.localizedDescription)")
            self.config = [:]
            return nil
        } else {
            self.config = config
        }
    }
    
    class func configFileURL(directory: NSURL) -> NSURL {
        return directory.URLByAppendingPathComponent(".kspmm")
    }
    
    class func loadConfig(directory: NSURL) -> (NSError?, [String:AnyObject]) {
        let url = configFileURL(directory)
        println("looking for config file on: \(url.absoluteString)")
        return parseJSONFile(url)
    }
    
    func saveConfig() -> NSError? {
        var error: NSError?
        let newConfigData = NSJSONSerialization.dataWithJSONObject(self.config, options: NSJSONWritingOptions.PrettyPrinted, error: &error)
        newConfigData?.writeToURL(KSPProcessor.configFileURL(self.targetDirectory), atomically: true)
        if let e = error {
            NSLog("error journaling: \(e.localizedDescription)")
        }
        return error
    }
    
    func installMod(mod: KSPMod) -> NSError? {
        NSLog("about to install \"\(mod.name)\"")
        var gamedataDir = self.config[KSPDirectoryKey]?.stringByAppendingPathComponent("GameData").stringByAppendingPathComponent(mod.name)
        gamedataDir = gamedataDir?.stringByStandardizingPath
        let gamedataURL = NSURL(fileURLWithPath: gamedataDir!)!
        
        var files = [String]()
        NSLog("\tunzipping files...")
        mod.archive.unzipToDirectory(gamedataURL) {
            (filename: String) -> Void in
            files.append(filename)
            return
        }
        NSLog("\tunzipping done, bookkeeping...")
        
        var installed = self.config[KSPInstalledModsKey] as [String: [String]]
        installed[mod.name] = files
        self.config[KSPInstalledModsKey] = installed as AnyObject
        if let e = self.saveConfig() {
            NSLog("\terror installing \"\(mod.name)\": \(e.localizedDescription)")
            return e
        }
        NSLog("\(mod.name) installed")
        return nil
    }
    
    func installedMods() -> [String] {
        let installed = self.config[KSPConfigKeys.InstalledMods.rawValue] as [String:[String]]
        return installed.keys.array
    }
    
    func removeMod(modName: String) -> NSError? {
        if let files = (self.config[KSPInstalledModsKey] as [String:[String]])[modName] {
            let manager = NSFileManager.defaultManager()
            for file in files {
            }
        }
        return nil
    }
    
    func checkUniqueFile(filename: String) -> Bool {
        return false
    }
}

func parseJSONFile(url: NSURL) -> (NSError?, [String:AnyObject]) {
    let data = NSData(contentsOfURL: url)
    var error: NSError?
    let object = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: &error) as [String:AnyObject]
    return (error, object)
}

func checkArguments(args: [AnyObject]) -> Bool {
    return args.count > 2
}

// program

let validArgs = checkArguments(NSProcessInfo.processInfo().arguments)
if (validArgs) {
    println("you need to provide the mod file you want to install")
    exit(1)
}

let zipPath = NSProcessInfo.processInfo().arguments[1] as String
let zipURL = NSURL(fileURLWithPath: zipPath.stringByStandardizingPath)!
let fakemod = KSPMod(url: zipURL)

let kspPath = "/Users/nameghino/Desktop/KSP_osx"
let kspURL = NSURL(fileURLWithPath: kspPath)!
if let processor = KSPProcessor(targetDirectory: kspURL) {
    println("list of installed mods: \(processor.installedMods())")
}
