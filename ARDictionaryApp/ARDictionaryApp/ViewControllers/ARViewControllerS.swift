//
//  ARViewControllerS.swift
//  ARDictionaryApp
//
//  Created by Tom on 2019/12/16.
//  Copyright © 2019 Dgene. All rights reserved.
//

import UIKit
import ARDictionaryLib
import ARKit

class ARViewControllerS: UIViewController,PopOverDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    
    func modelIdentifier() -> String {
        if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] { return simulatorModelIdentifier }
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }

    @IBOutlet weak var btnCap1: UIButton!
    @IBOutlet weak var btnCap2: UIButton!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var lblIndicator: UILabel!
    @IBOutlet weak var btnViewPhoto: UIButton!
    @IBOutlet weak var btnReset: UIButton!
    @IBOutlet weak var btnChange: UIButton!
    @IBOutlet weak var segMode: UISegmentedControl!
    
    var controller:ARController? = nil

    @IBAction func segModeChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            controller?.setPanMode(mode:.movement)
        }else{
            controller?.setPanMode(mode:.rotation)

        }
    }
    
    
    func SYSTEM_VERSION_LESS_THAN(version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version, options: .numeric) == .orderedAscending
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        if SYSTEM_VERSION_LESS_THAN(version: "12.0"){
            return true
        }else{
            return false
        }
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool{
        return true
    }
    
    @objc func appDidBecomeActive(notification:NSNotification){
//        print("did become active notification")
    }
    
    @objc func appWillEnterForeground(notification:NSNotification){
//        print("will enter foreground notification")
        controller?.resetTracking(options: [.removeExistingAnchors,.resetTracking])

    }

    
    var globalERR = false
    var globalMsg = ""
    
    override func viewDidLoad() {
        Shared.data.viewControllerDelegate = self
        
        if SYSTEM_VERSION_LESS_THAN(version: "13.0"){
            segMode.backgroundColor = .white
            segMode.layer.cornerRadius = 5.0
            segMode.alpha = 0.8
        }
        
        btnReset.layer.cornerRadius = 4.0
        btnChange.layer.cornerRadius = 4.0
        btnViewPhoto.layer.cornerRadius = 4.0
        let orient = UIApplication.shared.statusBarOrientation
        if orient.isLandscape{
            btnCap1.isHidden = true
            btnCap2.isHidden = false
        }else{
//            let id = modelIdentifier()
//            if (id.substring(with: 0..<4) == "ipod"){
//                
//            }
            btnCap1.isHidden = false
            btnCap2.isHidden = true
        }
        super.viewDidLoad()
    
//        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        var modelURL = paths.last!;
        
        var modelURL = Bundle.main.bundleURL.appendingPathComponent("/Bundle")

        do{
            let _ = try Loader.loadModelInfo(configURL: modelURL.appendingPathComponent("/config.txt") as NSURL)
            modelURL.appendPathComponent(Shared.data.modelList[0].modelPath)
            controller = ARController(scnView: self.sceneView, url: modelURL as NSURL, scale: Shared.data.modelList[0].initScale,delegate: { (state, msg) -> (Void) in
               switch state{
               case -1:
                Shared.showMessage(title: "模型加载失败", msg: msg,controller:self, completion: nil)
               case 0:
                    self.lblIndicator.text = "正在搜索平面，请移动设备";
                    self.lblIndicator.text = "Move Around";
               case 1:
                    self.lblIndicator.text = "Plane Detected";
               case 2:
                    self.lblIndicator.text = "Object Placed";
               case 3:
                    self.lblIndicator.text = "Object Position Updated";
               case 9:
                    self.lblIndicator.text = "AR Reset";
               case 10:
                    self.lblIndicator.text = "Unable to Detect Position";
               default:
                   break
               }
           })
        }catch{
            globalERR = true
            globalMsg = error.localizedDescription
        }

       
    }
    @IBAction func openPhoto(_ sender: UIButton) {

        openAlbum()
    }
    
    @IBAction func captureTapped(_ sender: UIButton) {
        if let image = controller?.takeSnapShot(animated: true){
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            self.lblIndicator.text = "相片已保存到系统相册"
        }
    }
    
    @IBAction func resetTapped(_ sender: UIButton) {
        controller?.resetTracking(options: [.removeExistingAnchors,.resetTracking])
    }
    
    @objc func orientationChanged(notification:NSNotification){
        let orient = UIApplication.shared.statusBarOrientation
        btnCap1.isHidden = orient.isLandscape
        btnCap2.isHidden = !orient.isLandscape
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appDidBecomeActive(notification:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appWillEnterForeground(notification:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.orientationChanged(notification:)), name: UIDevice.orientationDidChangeNotification, object: nil)
        controller?.run()
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (globalERR){
            Shared.showMessage(title: "配置载入失败", msg: globalMsg, controller: self) { (action) in
                exit(-1)
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        controller?.pauseSession()
    }
    
    func popOverDidDismissed(index:Int) {
        let docURL = Bundle.main.bundleURL.appendingPathComponent("/Bundle")
        controller?.setModel(withURL: docURL.appendingPathComponent(Shared.data.modelList[index].modelPath) as NSURL)
        controller?.setScale(scale:Shared.data.modelList[index].initScale)
        lblIndicator.text = "The model has been changed to \(Shared.data.modelList[index].name)"
        controller?.reloadModel()
    }
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let picURL = paths.last!.appendingPathComponent("Share.jpg");
        let image = info[UIImagePickerController.InfoKey.originalImage]as! UIImage
        try? image.jpegData(compressionQuality: 1.0)?.write(to: picURL)


        
        //图片控制器退出
        picker.dismiss(animated: true, completion: {
            () -> Void in
            let activityViewController = UIActivityViewController(activityItems: [picURL], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 200, width: 768, height: 20)
            self.present(activityViewController, animated: true, completion: nil)
        })
    }
    
    func openAlbum(){

        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            picker.allowsEditing = true
            self.present(picker, animated:true, completion: {
                () -> Void in
            })
        }else{
            print("读取相册错误")
        }

    }

}
