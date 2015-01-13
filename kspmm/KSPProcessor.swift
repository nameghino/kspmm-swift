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
            self.config[KSPDirectoryKey] = targetDirectory.absoluteString
            if let e = self.saveConfig() {
                return nil
            }
        } else {
            self.config = config!
        }
    }
    
    class func initialConfig() -> [String: AnyObject] {
        var empty = [String: [String]]()
        var config = [KSPInstalledModsKey: empty]
        return config
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
            return error
        }
        return nil
    }
    
    func installURLForFile(filepath: String) -> (NSURL, String) {
        
        func processGamedataPrefix(kspURL: NSURL?, gamedataPrefix: String, filepath: String) -> (NSURL, String) {
            if let fileURL = kspURL?.URLByAppendingPathComponent(filepath) {
                let indexEntry = filepath.stringByReplacingOccurrencesOfString(gamedataPrefix, withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range:
                    Range(start: filepath.startIndex, end: filepath.endIndex)
                )
                return (fileURL, indexEntry)
            }
            return (NSURL(), "")
        }
        
        let kspDirectory = self.config[KSPDirectoryKey] as String
        let kspURL = NSURL(fileURLWithPath: kspDirectory.stringByStandardizingPath)
        // if filepath begins with gamedata
        let gamedataPrefix = "gamedata/"
        if filepath.lowercaseString.hasPrefix(gamedataPrefix) {
            return processGamedataPrefix(kspURL, gamedataPrefix, filepath)
        }
        
        // search for gamedata down the tree 
        let components = filepath.componentsSeparatedByString("/")
        for (index, component) in enumerate(components)  {
            if component == gamedataPrefix {
                let range = index..<(countElements(components))
                let modifiedPath = components[range].reduce("") {
                    (prev: String, item: String) -> String in
                    return prev + "/" + item
                }
                return processGamedataPrefix(kspURL, gamedataPrefix, modifiedPath)
            }
        }
        return (NSURL(), "")
    }
    
    func installMod(mod: KSPMod) -> NSError? {
        
        // determine install point
        // use LCS algorithm to determine what is the target path
        // for the mod, i.e.:
        //
        // <modname>/<filename> -> GameData
        // GameData/<modname>/<filename> -> GameData parent
        
        
        switch mod.install(self) {
        case (nil, let error):
            return error
        case (let files, nil):
            // update config
            var installed = self.config[KSPInstalledModsKey] as [String: [String]]
            installed[mod.name] = files
            self.config[KSPInstalledModsKey] = installed as AnyObject
            if let e = self.saveConfig() {
                return e
            }
        default:
            println("should not be here")
        }
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
