//
//  ConfigLoader.swift
//  ARDictionaryApp
//
//  Created by Tom on 2019/12/16.
//  Copyright © 2019 Dgene. All rights reserved.
//

import Foundation
import UIKit

public class Loader:NSObject{
    public static func loadModelInfo(configURL:NSURL) throws ->Bool{
        if let path = configURL.path {
            do {
                let data = try String(contentsOfFile: path, encoding: .utf8)
                let myStrings = data.components(separatedBy: .newlines)
                
                let modelCount:Int = Int(myStrings.first!) ?? 0
                for id in 0..<modelCount{
                    let offset = id * 5
                    let name = myStrings[offset + 1]
                    let modelPath = myStrings[offset + 2]
                    let imgPath = myStrings[offset + 3]
                    let scale = Float(myStrings[offset + 4]) ?? 0.001
                    let newModel = Model(name: name, mPath: modelPath, iPath: imgPath, scale: scale)
                    Shared.data.modelList.append(newModel)
                }
            } catch {
                throw error
            }
        }
        
        return true
    }
}
