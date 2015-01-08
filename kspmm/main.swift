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

func parseJSONFile(url: NSURL) -> (NSError?, [String:AnyObject]?) {
    if let data = NSData(contentsOfURL: url) {
        var error: NSError?
        var object: [String: AnyObject]? = nil
        if let o = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: &error) as? [String: AnyObject] {
            object = o as [String: AnyObject]
        } else if let e = error {
            println("error: \(e.localizedDescription)")
        }
        return (error, object)
    } else {
        
        //    init(domain: String, code: Int, userInfo dict: [NSObject : AnyObject]?)

        let error = NSError(domain: NSCocoaErrorDomain,
            code: 206,
            userInfo: [NSLocalizedDescriptionKey: "file not found"])
        return (error, nil)
    }
}

enum KSPMMStartType {
    case KSPMMSpecificKSPInstance
    case KSPMMLocalKSPInstance
    case KSPMMNotEnoughArguments
}

enum KSPMMCommand {
    case Install
    case List
    case Remove
    case RemoveAll
}

func checkArguments(args: [AnyObject]) -> (KSPMMStartType, [String:String]) {
    let t = args as [String]
    if args.count == 3 {
        return (
            KSPMMStartType.KSPMMLocalKSPInstance,
            [
                "Command": t[1],
                "ModFile": t[2]
            ]
        )
    } else if args.count == 4 {
        return (
            KSPMMStartType.KSPMMSpecificKSPInstance,
            [
                "KSPDirectory": t[1],
                "Command": t[2],
                "ModFile": t[3]
            ]
        )
    }
    return (.KSPMMNotEnoughArguments, [:])
}



// program

// test args
// 1- /Users/install/tmp/KSP_osx
// 2- install
// 3- /Users/install/tmp/Neophytes_Elementary_Aerodynamics_Replacement-v1.3.1.zip


let (startType, parsedArgs): (KSPMMStartType, [String:String]) = checkArguments(NSProcessInfo.processInfo().arguments)

if (startType == .KSPMMNotEnoughArguments) {
    println("not enough arguments specified")
    exit(EXIT_FAILURE)
}

let zipPath = parsedArgs["ModFile"] as String!
let zipURL = NSURL(fileURLWithPath: zipPath.stringByStandardizingPath)!
let mod = KSPMod(url: zipURL)
let files = mod.gamedataFiles()
println("files: \(files)")

//FIXME: makes no sense at all... effin' swift
var kspPath: String = ""
if (startType == .KSPMMSpecificKSPInstance) {
    kspPath = parsedArgs["KSPDirectory"] as String!
} else {
    kspPath = "."
}
let kspURL = NSURL(fileURLWithPath: kspPath)!

if let processor = KSPProcessor(targetDirectory:kspURL) {
    //processor.installMod(mod)
}


