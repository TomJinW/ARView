//
//  Extension.swift
//  ARDictionaryLib
//
//  Created by Plex on 2018/12/27.
//  Copyright © 2018 Dgene. All rights reserved.
//

import Foundation
import ARKit

extension ARSCNView{
    
    var lightingRootNode: SCNNode? {
        return scene.rootNode.childNode(withName: "lightingRootNode", recursively: true)
    }
    
    func smartHitTest(_ point: CGPoint,
                      infinitePlane: Bool = false,
                      objectPosition: float3? = nil,
                      allowedAlignments: [ARPlaneAnchor.Alignment] = [.horizontal]) -> ARHitTestResult? {
        
        // Perform the hit test.
        let results = hitTest(point, types: [.estimatedHorizontalPlane])
        
        // 1. Check for a result on an existing plane using geometry.
        //        if let existingPlaneUsingGeometryResult = results.first(where: { $0.type == .existingPlaneUsingGeometry }),
        //            let planeAnchor = existingPlaneUsingGeometryResult.anchor as? ARPlaneAnchor, allowedAlignments.contains(planeAnchor.alignment) {
        //            return existingPlaneUsingGeometryResult
        //        }
        
        if infinitePlane {
            
            // 2. Check for a result on an existing plane, assuming its dimensions are infinite.
            //    Loop through all hits against infinite existing planes and either return the
            //    nearest one (vertical planes) or return the nearest one which is within 5 cm
            //    of the object's position.
            let infinitePlaneResults = hitTest(point, types: .existingPlane)
            
            for infinitePlaneResult in infinitePlaneResults {
                if let planeAnchor = infinitePlaneResult.anchor as? ARPlaneAnchor, allowedAlignments.contains(planeAnchor.alignment) {
                    // For horizontal planes we only want to return a hit test result
                    // if it is close to the current object's position.
                    if let objectY = objectPosition?.y {
                        let planeY = infinitePlaneResult.worldTransform.translation.y
                        if objectY > planeY - 0.05 && objectY < planeY + 0.05 {
                            return infinitePlaneResult
                        }
                    } else {
                        return infinitePlaneResult
                    }
                }
            }
        }
        
        // 3. As a final fallback, check for a result on estimated planes.
        let vResult:ARHitTestResult? = nil
        let hResult = results.first(where: { $0.type == .estimatedHorizontalPlane })
        switch (allowedAlignments.contains(.horizontal),false) {
        case (true, false):
            return hResult
        case (false, true):
            // Allow fallback to horizontal because we assume that objects meant for vertical placement
            // (like a picture) can always be placed on a horizontal surface, too.
            return vResult ?? hResult
        case (true, true):
            if hResult != nil && vResult != nil {
                return hResult!.distance < vResult?.distance ?? 0.0 ? hResult! : vResult
            } else {
                return hResult ?? vResult
            }
        default:
            return nil
        }
    }
    
    func updateDirectionalLighting(intensity: CGFloat, queue: DispatchQueue) {
        guard let lightingRootNode = self.lightingRootNode else {
            return
        }
        
        queue.async {
            for node in lightingRootNode.childNodes {
                node.light?.intensity = intensity
            }
        }
    }
    
}

extension UIView {
    func flash(numberOfFlashes: Float) {
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.2
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = numberOfFlashes
        layer.add(flash, forKey: nil)
    }
}
