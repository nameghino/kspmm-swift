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
        self.name = (url.lastPathComponent.componentsSeparatedByString(".").first)!
        self.archive = ZipArchive(file: url)!
    }
    
    func urlInProcessor(processor: KSPProcessor) -> NSURL {
        return NSURL()
    }
}
