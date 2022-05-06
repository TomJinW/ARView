//
//  ARControllerMiscLoader.swift
//  ARDictionaryLib
//
//  Created by Plex on 2018/12/27.
//  Copyright © 2018 Dgene. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

extension ARController{
    
    // 从屏幕XY坐标得到ARKit世界坐标系XYZ
    func getWorldPosition(pos:CGPoint)->SCNVector3?{
        let result = sceneView.hitTest(pos, types: ARHitTestResult.ResultType.existingPlane)
        guard let hitResult = result.first else {return nil}
        let hitTransform = SCNMatrix4(hitResult.worldTransform)
        let hitVector = SCNVector3(hitTransform.m41,hitTransform.m42,hitTransform.m43)
        return hitVector
    }
    
    // 加载模型
    func loadModel(url:URL) throws ->SCNNode {
        var scene:SCNScene!
        
        do{
           scene = try SCNScene(url: url, options: nil)
        }catch let error{
            throw error
        }
        
        let node = SCNNode()
        node.name = name
        for eachNode in scene.rootNode.childNodes{
            node.addChildNode(eachNode)
        }
        
        lastSavedX = 0.0
        
        // Load Animation
        storedAnimations = loadAnimation(url: url)
        let _ = setAnimation(speed: 1.0)
        return node
    }
    
    // 加载模型动画
    func loadAnimation(url:URL)->[CAAnimation]{
        
        var animations = [CAAnimation]()
        let sceneSource = SCNSceneSource(url: url, options: nil)
        guard let animationIdentifiers = sceneSource?.identifiersOfEntries(withClass: CAAnimation.self) else{ return animations }
        
        for identifier in animationIdentifiers {
            guard let animation = sceneSource?.entryWithIdentifier(identifier, withClass: CAAnimation.self) else { return animations }
            animations.append(animation)
        }
        
        return animations
    }
}
