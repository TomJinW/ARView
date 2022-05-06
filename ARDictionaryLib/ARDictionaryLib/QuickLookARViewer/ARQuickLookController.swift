//
//  ARQuickLookController.swift
//  ARDictionaryLib
//
//  Created by Plex on 2018/12/26.
//  Copyright © 2018 Dgene. All rights reserved.
//

import Foundation
import QuickLook



@objc public class ARQuickLookController:NSObject,QLPreviewControllerDelegate,QLPreviewControllerDataSource{
    private let previewController = MyQLPreviewController()
    @objc public var url:URL
    
    @objc public init(url:URL){
        self.url = url
        
        super.init()
        previewController.dataSource = self
        previewController.delegate = self
        
        
    }
    
    @objc public func show(controller: UIViewController) {
        // Refreshing the view
        previewController.reloadData()
        // Printing the doc
        controller.present(previewController, animated: true, completion: nil)
    }
    
    
    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int { // Viewer supports previewing a single 3D object
        return 1
        
    }
    
    public func previewController(
        _ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        // Return the file URL to the .usdz file
        return self.url as QLPreviewItem
    }
}
