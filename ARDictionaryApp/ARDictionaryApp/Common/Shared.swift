//
//  Shared.swift
//  ARDictionaryApp
//
//  Created by Tom on 2019/12/16.
//  Copyright © 2019 Dgene. All rights reserved.
//

import Foundation
import UIKit

public class Model:NSObject{
    var name:String = ""
    var modelPath = ""
    var imgPath = ""
    var initScale:Float = 0.01
    
    public init(name:String,mPath:String,iPath:String,scale:Float){
        self.name = name
        self.modelPath = mPath
        self.imgPath = iPath
        self.initScale = scale
    }
}

public class Shared{
    var modelList = [Model]()
    var configPath = "/config.txt"
    var viewControllerDelegate: PopOverDelegate?
    
    public static func showMessage(title:String,msg:String,controller:UIViewController,completion: ((UIAlertAction)-> Void)?){
        let action = UIAlertAction(title: "OK", style: .default, handler: completion)
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertController.addAction(action)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    public static var data: Shared = Shared()
}
