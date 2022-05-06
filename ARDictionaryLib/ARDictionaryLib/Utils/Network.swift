//
//  Network.swift
//  ARDictionaryLib
//
//  Created by Plex on 2018/12/27.
//  Copyright © 2018 Dgene. All rights reserved.
//

import Foundation
@objc public class Network:NSObject,URLSessionDelegate,URLSessionDownloadDelegate{
    

    @objc public func download(url:NSURL,localFileName:NSString,onState:@escaping (Int,NSString,NSURL?)->()){
        
        let sessionConfig
            = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig,delegate: self,delegateQueue:OperationQueue())
        let request = URLRequest(url:url as URL)
        DispatchQueue.main.async {
            onState(0,"Downloading",nil)
        }
        let task = session.downloadTask(with: request) { (url, response, error) in
            if error != nil {
                DispatchQueue.main.async {
                    onState(-1,error!.localizedDescription as NSString,nil)
                }
                return
            }
            guard let localURL = url else{
                DispatchQueue.main.async {
                    onState(-1,"Local url is nil",nil)
                }
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else{
                DispatchQueue.main.async {
                    onState(-1,"status code is nil",nil)
                }
                return
            }
            if statusCode != 200 {
                DispatchQueue.main.async {
                    onState(-1,"Status code is not 200",nil)
                }
                return
            }
            
            // moving file
            guard let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL? else{
                DispatchQueue.main.async {
                    onState(-1,"folder not exist",nil)
                }
                return
            }
            let destinationFileUrl = documentsUrl.appendingPathComponent(localFileName as String)
            try? FileManager.default.removeItem(at: destinationFileUrl)
            guard ((try? FileManager.default.copyItem(at: localURL, to: destinationFileUrl)) != nil) else{
                DispatchQueue.main.async {
                    onState(-1,"File Move Failed",nil)
                }
                return
            }
            onState(1,"Download Success",destinationFileUrl as NSURL)
        }
        task.resume()
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if totalBytesExpectedToWrite > 0 {
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            debugPrint("Progress \(downloadTask) \(progress)")
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        debugPrint("Download finished: \(location)")
        try? FileManager.default.removeItem(at: location)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        debugPrint("Task completed: \(task), error: \(String(describing: error))")
    }
}
