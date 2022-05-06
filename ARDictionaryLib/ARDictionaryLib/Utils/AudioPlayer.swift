//
//  AudioPlayer.swift
//  ARDictionaryLib
//
//  Created by Plex on 2019/1/2.
//  Copyright © 2019 Dgene. All rights reserved.
//

import Foundation
import AVFoundation

// 音频播放器 Class
@objc public class AudioPlayer:NSObject{
    
    var audioPlayer: AVAudioPlayer?
    let delegate:(Bool)->(Void)
    
    // 返回音频是否正在播放
    @objc public var isPlaying:Bool {
        guard let player = audioPlayer else {return false}
        return player.isPlaying
    }
    

    // 传入音频文件URL，以及一个实时返回音频播放状态的 Code Block
    @objc public init(url:NSURL,block:@escaping (Bool)->(Void)){
        audioPlayer = try? AVAudioPlayer(contentsOf: url as URL)
        delegate = block
    }
    
    // 播放音频
    @objc public func play()->Bool{
        if (audioPlayer == nil){return false}
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
        DispatchQueue.main.async {
            self.delegate(true)
        }
        
        DispatchQueue.global().async {
            while (self.isPlaying){
                usleep(100000)
            }
            DispatchQueue.main.async {
                self.delegate(false)
            }
        }
        return true
    }
    
    // 暂停音频播放
    @objc public func pause()->Bool{
        if (audioPlayer == nil){return false}
        audioPlayer?.pause()
        DispatchQueue.main.async {
            self.delegate(false)
        }
        return true
    }
    
    // 停止音频播放
    @objc public func stop()->Bool{
        if (audioPlayer == nil){return false}
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        DispatchQueue.main.async {
            self.delegate(false)
        }
        return true
    }
}
