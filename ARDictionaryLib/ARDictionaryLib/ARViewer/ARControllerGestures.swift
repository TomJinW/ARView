//
//  ARControllerGestures.swift
//  ARDictionaryLib
//
//  Created by Plex on 2018/12/27.
//  Copyright © 2018 Dgene. All rights reserved.
//

import Foundation
import SceneKit

extension ARController{
    
    
    // 往 sceneView 加入交互手势监听
    func registerGestures(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(sender:)))
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(sender:)))
        sceneView.addGestureRecognizer(tapGesture)
        sceneView.addGestureRecognizer(panGesture)
        sceneView.addGestureRecognizer(pinchGesture)
        sceneView.addGestureRecognizer(rotationGesture)
        
    }
    
    

    // 处理点击事件
    @objc func handleTap(sender: UITapGestureRecognizer? = nil)->Bool {
        
        // 获取屏幕点击位置
        guard let location = sender?.location(in: sceneView) else {
            return false
        }
        guard let position = getWorldPosition(pos: location) else {
            self.updateStates(state: 10)
            return false
        }
        
        if !modelAdded{
            
            // 设置模型
            var node:SCNNode!
            do{
                // 读入模型
                node = try loadModel(url: modelURL)
            }catch let error{
                
                // 如果模型加载失败，返回错误
                callback(-1,error.localizedDescription)
                return false
            }

            // 设定模型位置与缩放因子
            node.position = position
            nodePosition = position
            node.scale = SCNVector3(x: loadScale, y: loadScale, z: loadScale)
            
            // 在 View 中显示模型
            self.sceneView.scene.rootNode.addChildNode(node)
            
            // 通知外部模型加载完成
            self.updateStates(state: 2)
            modelAdded = true
            
        }else{
            // 更新模型位置
            guard let node = sceneView.scene.rootNode.childNode(withName: name, recursively: true) else {return false}
            self.updateStates(state: 3)
            nodePosition = position
            node.position = position
        }
        return true
    }
    
    @objc public func reloadModel(){
        removeAllNodes()
        guard let node = try? loadModel(url: modelURL) else {
            modelAdded = false
            return
        }
        guard let position = nodePosition else {
            modelAdded = false
            return
        }
        node.position = position
        node.scale = SCNVector3(x: loadScale, y: loadScale, z: loadScale)
        self.sceneView.scene.rootNode.addChildNode(node)
//        self.updateStates(state: 9)
    }
    
    // 处理拖移手势
    @objc func handlePan(sender: UIPanGestureRecognizer? = nil) {
        
        if panGestureMode == .movement{
            if sender?.state == .changed{
                // 检测手势位置并更新状态
                guard let node = sceneView.scene.rootNode.childNode(withName: name, recursively: true) else {return}
                guard let location = sender?.location(in: sceneView) else {return}
                guard let position = getWorldPosition(pos: location) else {return}
                nodePosition = position
                node.position = position
                
            }else if sender?.state == .ended{
                self.updateStates(state: 3)
            }
        }else{
            switch sender?.state{
            case .began:
                initRotation = Float(sender?.location(in: sceneView).x ?? 0.0)
            case .changed:
                let location = Float(sender?.location(in: sceneView).x ?? 0.0)
                let x = (Float(location)-initRotation) * 2 + lastSavedX
                rotateModel(x: x)
            case .ended:
                let location = Float(sender?.location(in: sceneView).x ?? 0.0)
                let x = (Float(location)-initRotation) * 2 + lastSavedX
                lastSavedX = x
            default:
                break
            }
        }

    }
    
    // 检测缩放手势
    @objc func handlePinch(sender: UIPinchGestureRecognizer? = nil) {
        if sender?.state == .changed{
            guard let node = sceneView.scene.rootNode.childNode(withName: name, recursively: true) else {return}
            let pinchScaleX = Float((sender?.scale)!) * node.scale.x
            let pinchScaleY = Float((sender?.scale)!) * node.scale.y
            let pinchScaleZ = Float((sender?.scale)!) * node.scale.z
            node.scale = SCNVector3(x: pinchScaleX, y: pinchScaleY, z: pinchScaleZ)
            sender?.scale = 1
        }
        
    }
    

    func rotateModel(x:Float){
        let y:Float = 0
       let anglePan = sqrt(pow(x,2)+pow(y,2))*(Float)(Double.pi)/180.0
       
       guard let node = sceneView.scene.rootNode.childNode(withName: name, recursively: true) else {return}
       var rotationVector = SCNVector4()
       rotationVector.x = -y
       rotationVector.y = -x
       rotationVector.z = 0
       rotationVector.w = anglePan
       node.rotation = rotationVector

    }
    
    // 检测旋转手势
    @objc func handleRotation(sender: UIRotationGestureRecognizer? = nil){
        if sender?.state == .changed{
            guard let rotation = sender?.rotation else {return}
            let x = (Float(rotation)-initRotation) * 90 + lastSavedX
            rotateModel(x: x)
        }else if sender?.state == .began{
            initRotation = Float((sender?.rotation)!)
        }
        else if sender?.state == .ended{
            guard let rotation = sender?.rotation else {return}
            let x = (Float(rotation)-initRotation) * 90 + lastSavedX
            lastSavedX = x
        }
    }
}
