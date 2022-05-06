//
//  ARController.swift
//  ARDictionaryLib
//
//  Created by Plex on 2018/12/25.
//  Copyright © 2018 Dgene. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

@objc public class ARController:NSObject,ARSCNViewDelegate,ARSessionDelegate{
    
    // ARViews
    let sceneView:ARSCNView!
    
    var loadScale:Float = 0.001
    
    // Gestures related
    var baseScale:Float = 1.0
    var modelAdded = false

    var nodePosition:SCNVector3? = nil
    
    var state = -1
    let callback:(Int,String)->(Void)
    
    // Path
    let name = "group"
    var modelURL:URL!;
    
    // Animation
    var storedAnimations = [CAAnimation]()
    var panGestureMode:PanGestureMode = .movement
    
    // HUD
    var focusSquare = FocusSquare()
    var screenCenter: CGPoint {
        let bounds = sceneView.bounds
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    var initRotation:Float = 0.0
    var lastSavedX:Float = 0.0
    var initLocation:CGPoint? = nil
    // Threads
    let updateQueue = DispatchQueue(label: "com.example.apple-samplecode.arkitexample.serialSceneKitQueue")
    
//    public var delegate:ARControllerDelegate?
    public func setPanMode(mode:PanGestureMode){
        panGestureMode = mode
    }
    
    /// 初始化 AR 会话
    @objc public init(scnView:ARSCNView,url:NSURL,scale:Float,delegate:@escaping (Int,String)->(Void)){
        modelURL = url as URL
        sceneView = scnView
        callback = delegate
        loadScale = scale
        sceneView.scene.rootNode.addChildNode(focusSquare)
    }
    
    @objc public func setScale(scale:Float){
        loadScale = scale
    }
    
    /// 启动 AR 会话
    @objc public func run() {
        self.sceneView.autoenablesDefaultLighting = true
        // Set the delegate
        sceneView.session.delegate = self
        sceneView.delegate = self
        // Register Gestures
        registerGestures()
        resetTracking(options: .removeExistingAnchors)
    }
    @objc public func setModel(withURL:NSURL){
        modelURL = withURL as URL
    }
    func removeAllNodes(){
        sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            if node.name == name{
                node.removeFromParentNode()
            }
        }
    }
    /// 重置 AR 会话
    @objc public func resetTracking(options: ARSession.RunOptions = []) {
        
        removeAllNodes()
        modelAdded = false
        // Set configuration and run
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        if #available(iOS 11.3, *) {
            configuration.planeDetection = [.horizontal,.vertical]
        }
        if #available(iOS 12.0, *) {
            configuration.environmentTexturing = .automatic
        }

        nodePosition = nil
        self.sceneView.session.run(configuration, options: options)
    }
    
    /// 设定动画倍速
    @objc public func setAnimation(speed:Float)->Bool{
        guard let node = sceneView.scene.rootNode.childNode(withName: name, recursively: true) else{return false}
        node.removeAllAnimations()
        var id = 0
        for animation in storedAnimations{
            animation.speed = speed
            node.addAnimation(animation, forKey: "Animation_\(id)")
            id += 1
        }
        return true
    }
    /// 暂停 AR 会话
    @objc public func pauseSession(){
        sceneView.session.pause()
    }
    /// 返回 ARSCNView 截图, animated 决定是否有动画效果
    @objc public func takeSnapShot(animated:Bool)->UIImage?{
        let impact = UIImpactFeedbackGenerator()
        impact.impactOccurred()
        // 闪烁动画与拍摄声音
        if (animated){
            sceneView.flash(numberOfFlashes: 1.0)
            if #available(iOS 9.0, *) {
                AudioServicesPlaySystemSoundWithCompletion(SystemSoundID(1108), nil)
            } else {
                AudioServicesPlaySystemSound(1108)
            }
        }
        return sceneView?.snapshot()
    }
        
    // 暂时没用
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        DispatchQueue.main.async {
            let imageName = referenceImage.name ?? ""
            print("Image Name is \(imageName)")
        }
    }
    
    /// 渲染聚焦方块以及更新场景光源设置
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        var ifObjectInView = false
        if let node = sceneView.scene.rootNode.childNode(withName: name, recursively: true){
             ifObjectInView = sceneView.isNode(node, insideFrustumOf: sceneView.pointOfView!)
        }
        DispatchQueue.main.async {
            self.updateFocusSquare(isObjectVisible: ifObjectInView)
        }
        // If light estimation is enabled, update the intensity of the directional lights
        if let lightEstimate = sceneView.session.currentFrame?.lightEstimate {
            sceneView.updateDirectionalLighting(intensity: lightEstimate.ambientIntensity, queue: updateQueue)
        } else {
            sceneView.updateDirectionalLighting(intensity: 1000, queue: updateQueue)
        }
    }

    var planeFound = false
    /// 更新返回给 code block 的状态
    func updateStates(state:Int){
        if (state == 0){
            planeFound = false
        }
        if (state == 1 && planeFound){
            return
        }
        if (state == 1){
            planeFound = true
        }
        if (self.state != state){
            self.state = state
            DispatchQueue.main.async {
                self.callback(state,"")
            }
        }
    }
    
    /// 更新聚焦方块的状态
    func updateFocusSquare(isObjectVisible: Bool) {
        if isObjectVisible {
            focusSquare.hide()
        } else {
            focusSquare.unhide()
        }
        // Perform hit testing only when ARKit tracking is in a good state.
        if let camera = sceneView.session.currentFrame?.camera, case .normal = camera.trackingState,
            let result = self.sceneView.smartHitTest(screenCenter) {
            updateQueue.async {
                DispatchQueue.main.async {
                    self.updateStates(state: 1)
                }
                self.sceneView.scene.rootNode.addChildNode(self.focusSquare)
                self.focusSquare.state = .detecting(hitTestResult: result, camera: camera)
            }
        } else {
            updateQueue.async {
                DispatchQueue.main.async {
                    self.updateStates(state: 0)
                }
                self.focusSquare.state = .initializing
                self.focusSquare.name = "Focus"
                self.sceneView.pointOfView?.addChildNode(self.focusSquare)
            }
        }
    }
}
