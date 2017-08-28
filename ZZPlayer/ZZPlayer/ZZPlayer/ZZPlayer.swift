//
//  ZZPlayer.swift
//  ZZPlayer
//
//  Created by lixiangzhou on 2017/3/23.
//  Copyright © 2017年 lixiangzhou. All rights reserved.
//

import UIKit
import AVFoundation

@objc enum ZZPlayerState: Int {
    case idle               // 空闲状态
    case readyToPlay        // 可以播放状态
    case playing            // 播放中
    case paused             // 暂停
    case buffering          // 缓冲
    case failed             // 失败
}

/// 播放时需要观察的 keypath
private enum ZZPlayerObseredKeyPath: String {
    case playToEndTime = "AVPlayerItemDidPlayToEndTimeNotification"
    case status
    case loadedTimeRanges
    case playbackBufferEmpty
    case playbackLikelyToKeepUp
}

@objc protocol ZZPlayerDelegate {
    
    /// 缓冲代理方法
    ///
    /// - parameter player:       播放器
    /// - parameter bufferedTime: 已缓冲好的时间
    /// - parameter totalTime:    视频总时间
    func player(_ player: ZZPlayer, bufferedTime: Int, totalTime: Int)
    
    
    /// 播放时间代理方法
    ///
    /// - parameter player:    播放器
    /// - parameter playTime:  已播放时间
    /// - parameter totalTime: 视频总时间
    func player(_ player: ZZPlayer, playTime: Int, totalTime: Int)
    
    
    /// 播放结束代理方法
    ///
    /// - parameter player: 播放器
    func playerDidPlayToEnd(_ player: ZZPlayer)
    
    
    /// 播放状态即将改变代理方法
    ///
    /// - parameter player: 播放器
    /// - parameter state:  将改变的状态
    @objc optional func player(_ player: ZZPlayer, willChange state: ZZPlayerState)
    
    
    /// 播放状态已改变的代理方法
    ///
    /// - parameter player: 播放器
    /// - parameter state:  改变的状态
    @objc optional func player(_ player: ZZPlayer, didChanged state: ZZPlayerState)
}

/// 提供最基本的播放功能
class ZZPlayer: UIView {
    
    public static let shared = ZZPlayer()
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clear
        
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        playerLayer?.frame = bounds
    }
    
    deinit {
        removeObservers()
    }
    
    // MARK: - 属性 Public
    
    weak var delegate: ZZPlayerDelegate?
    
    /// 播放资源
    var playerItemResource: ZZPlayerItemResource? {
        didSet {
            guard let videoUrlString = playerItemResource?.videoUrlString,
                let videoUrl = URL(string: videoUrlString) else {
                    validResource = false
                return
            }
            validResource = true
            
            removeObservers()
            
            let asset = AVAsset(url: videoUrl)
            let playerItem = AVPlayerItem(asset: asset)
            let player = AVPlayer(playerItem: playerItem)
            
            if playerLayer == nil {
                playerLayer = AVPlayerLayer(player: player)
                layer.insertSublayer(playerLayer!, at: 0)
            } else {
                playerLayer?.player = player
            }
            
            // 监听播放相关的状态
            NotificationCenter.default.addObserver(self, selector: #selector(didPlayToEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            
            func addObservedKeyPath(_ keypath: ZZPlayerObseredKeyPath) {
                playerItem.addObserver(self, forKeyPath: keypath.rawValue, options: .new, context: nil)
            }
            
            addObservedKeyPath(.status)
            addObservedKeyPath(.loadedTimeRanges)
            addObservedKeyPath(.playbackBufferEmpty)
            addObservedKeyPath(.playbackLikelyToKeepUp)
        }
    }
    
    /// 是否正在播放，不可用作播放状态判断
    var isPlaying: Bool {
        if currentPlayerItem != nil {
            return state == .playing
        }
        return false
    }
    
    /// 是否停止播放，可用作播放状态判断
    var isPaused: Bool {
        if currentPlayerItem != nil {
            return state == .paused
        }
        return true
    }
    
    /// 当前播放的Item
    var currentPlayerItem: AVPlayerItem? {
        if validResource == false {
            return nil
        }
        return playerLayer?.player?.currentItem
    }
    // MARK: - Private
    /// 播放层
    fileprivate var playerLayer: AVPlayerLayer?
    
    /// 是否由用户点击暂停还是由其他的原因（如没有缓冲好数据）
    fileprivate var pausedByUser = false
    
    /// 播放状态
    fileprivate var state: ZZPlayerState = .idle {
        didSet {
            guard let playerLayer = playerLayer,
                let player = playerLayer.player,
                oldValue != state,
                validResource else {
                    state = .idle
                return
            }
            
            delegate?.player?(self, willChange: state)
            
            switch state {
            case .idle:         // 空闲
                break
            case .readyToPlay:  // 准备好了播放
                state = .playing
                player.play()
                break
            case .buffering:    // 缓冲中
                bufferDatas()
                break
            case .playing:      // 播放中
                player.play()
                break
            case .paused:       // 暂停
                player.pause()
                break
            case .failed:       // 失败
                break
            }
            
            delegate?.player?(self, didChanged: state)
        }
    }
    
    /// 是否在缓冲
    fileprivate var isBuffering = false
    
    /// 资源是否有效
    fileprivate var validResource = true
}


// MARK: - Main feature
extension ZZPlayer {
    
    /// 用户手动停止播放
    func pauseByUser() {
        pausedByUser = true
        state = .paused
        print(#function)
    }
    
    /// 其他原因停止播放
    func pausedByOtherReasons() {
        pausedByUser = false
        state = .paused
        print(#function)
    }
    
    /// 播放
    func play() {
        state = .playing
        print(#function)
    }
    
    /// 从 time 秒开始播放
    ///
    /// - Parameter time: 播放的时间
    func seekTo(time: Float) {
        if validResource == false {
            return
        }
        playerLayer?.player?.seek(to: CMTime(value: CMTimeValue(time), timescale: 1), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero) {_ in 
            if self.pausedByUser {
                return
            }
            self.state = .playing
        }
        print(#function)
    }
}

// MARK: - Observer
extension ZZPlayer {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if validResource == false {
            return
        }
        
        guard let playerItem = currentPlayerItem else {
            return
        }
        
        if keyPath == ZZPlayerObseredKeyPath.status.rawValue {
            let status: AVPlayerItemStatus
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItemStatus(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            
            switch status {
            case .readyToPlay:
                state = .readyToPlay
                processPlayTime(playerItem)
            case .failed:
                state = .failed
            case .unknown:
                state = .idle
            }
            
            playerLayer?.player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: nil, using: { time in
                self.processPlayTime(playerItem)
            })
        }
        else if keyPath == ZZPlayerObseredKeyPath.loadedTimeRanges.rawValue {
            guard let timeRange = playerItem.loadedTimeRanges.first?.timeRangeValue else {
                return
            }
            
            let start = Int(CMTimeGetSeconds(timeRange.start))
            let duration = Int(CMTimeGetSeconds(timeRange.duration))
            
            let bufferedTime = start + duration
            let totalTime = Int(CMTimeGetSeconds(playerItem.duration))
            
            delegate?.player(self, bufferedTime: bufferedTime, totalTime: totalTime)
        }
        else if keyPath == ZZPlayerObseredKeyPath.playbackBufferEmpty.rawValue {
            
            if playerItem.isPlaybackBufferEmpty {
                pausedByOtherReasons()
                state = .buffering
            }
            
        }
        else if keyPath == ZZPlayerObseredKeyPath.playbackLikelyToKeepUp.rawValue {
        }
    }
    
    
    func didPlayToEnd(note: Notification) {
        self.delegate?.playerDidPlayToEnd(self)
    }
}

// MARK: - Helper
extension ZZPlayer {
    
    fileprivate func initialize() {
        
    }
    
    /// 处理时间
    fileprivate func processPlayTime(_ playerItem: AVPlayerItem) {
        if validResource && playerItem.seekableTimeRanges.count > 0 && playerItem.duration.timescale != 0 {
            let playTime = Int(CMTimeGetSeconds(playerItem.currentTime()))
            let totalTime = Int(CMTimeGetSeconds(playerItem.duration))
            self.delegate?.player(self, playTime: playTime, totalTime: totalTime)
        }
    }
    
    
    /// 数据缓冲
    fileprivate func bufferDatas() {
        if validResource == false {
            return
        }
        if isBuffering {
            return
        }
        isBuffering = true
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { 
            guard let playerItem = self.currentPlayerItem else {
                self.state = .idle
                self.isBuffering = false
                return
            }
            
            if self.pausedByUser {
                self.isBuffering = false
                return
            }
            
            
            if playerItem.isPlaybackLikelyToKeepUp {
                self.state = .playing
                self.isBuffering = false
            } else {
                self.bufferDatas()
            }
        }
    }
    
    /// 有在播放的item, 就取消该 item 的监听操作
    fileprivate func removeObservers() {
        if let playerItem = currentPlayerItem {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            
            func removeObservedKeyPath(_ keypath: ZZPlayerObseredKeyPath) {
                playerItem.removeObserver(self, forKeyPath: keypath.rawValue)
            }
            
            removeObservedKeyPath(.status)
            removeObservedKeyPath(.loadedTimeRanges)
            removeObservedKeyPath(.playbackBufferEmpty)
            removeObservedKeyPath(.playbackLikelyToKeepUp)
        }
    }
}
