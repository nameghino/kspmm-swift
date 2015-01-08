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
