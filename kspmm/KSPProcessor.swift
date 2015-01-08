//
//  KSPProcessor.swift
//  kspmm
//
//  Created by Nicolas Ameghino on 1/8/15.
//  Copyright (c) 2015 Nicolas Ameghino. All rights reserved.
//

import Cocoa

//TODO: fix this
let KSPDirectoryKey = "KSPDirectory"
let KSPInstalledModsKey = "KSPMMInstalledMods"

enum KSPConfigKeys: String, Hashable {
    case KSPDirectory = "KSPDirectory"
    case InstalledMods = "KSPMMInstalledMods"
}

func == (lhs: KSPConfigKeys, rhs: KSPConfigKeys) -> Bool {
    return lhs.rawValue == rhs.rawValue
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
            self.config = KSPProcessor.initialConfig()
            if let e = self.saveConfig() {
                return nil
            }
        } else {
            self.config = config!
        }
    }
    
    class func initialConfig() -> [String: AnyObject] {
        return [KSPInstalledModsKey: []]
    }
    
    class func configFileURL(directory: NSURL) -> NSURL {
        return directory.URLByAppendingPathComponent(".kspmm")
    }
    
    class func loadConfig(directory: NSURL) -> (NSError?, [String:AnyObject]?) {
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
        //TODO: stub
        if let files = (self.config[KSPInstalledModsKey] as [String:[String]])[modName] {
            let manager = NSFileManager.defaultManager()
            for file in files {
            }
        }
        return nil
    }
    
    func checkUniqueFile(filename: String) -> Bool {
        //TODO: stub
        // ModuleManager
        // KSPAPIExtensions
        return false
    }
}
