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

enum ZZPlayerObseredKeyPath: String {
    case playToEndTime = "AVPlayerItemDidPlayToEndTimeNotification"
    case status
    case loadedTimeRanges
    case playbackBufferEmpty
    case playbackLikelyToKeepUp
}

/// 播放的 model 必须遵循的协议
@objc protocol ZZPlayerItemModel: NSObjectProtocol {
    var title: String? { get set }
    var videoUrlString: String? { get set }
    @objc optional var placeholderImage: UIImage? { get set }
    @objc optional var placeholderImageUrl: String?  { get set }
    @objc optional var resolutions: [String: String]?  { get set }
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

class ZZPlayer: UIView {
    
    override init(frame: CGRect) {
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
    
    // MARK: - 属性
    
    weak var delegate: ZZPlayerDelegate?
    
    var playerItemModel: ZZPlayerItemModel? {
        didSet {

            if playerItemModel == nil || playerItemModel!.isEqual(oldValue) {
                return
            }
            
            guard let videoUrlString = playerItemModel?.videoUrlString,
                let videoUrl = URL(string: videoUrlString) else {
                return
            }
            
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
    
    // 是否正在播放，不可用作播放状态判断
    var isPlaying: Bool {
        if currentPlayerItem != nil {
            return state == .playing
        }
        return false
    }
    
    // 是否停止播放，可用作播放状态判断
    var isPaused: Bool {
        if currentPlayerItem != nil {
            return state == .paused
        }
        return true
    }
    
    var currentPlayerItem: AVPlayerItem? {
        return playerLayer?.player?.currentItem
    }
    
    fileprivate var playerLayer: AVPlayerLayer?
    /// 是否由用户点击暂停还是由其他的原因（如没有缓冲好数据）
    fileprivate var pausedByUser = false
    
    fileprivate var state: ZZPlayerState = .idle {
        didSet {
            guard let playerLayer = playerLayer,
                let player = playerLayer.player,
                oldValue != state else {
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
    
    fileprivate var isBuffering = false
}


// MARK: - Main feature
extension ZZPlayer {
    func pauseByUser() {
        pausedByUser = true
        state = .paused
        print(#function)
    }
    
    func pausedByOtherReasons() {
        pausedByUser = false
        state = .paused
        print(#function)
    }
    
    func play() {
        state = .playing
        print(#function)
    }
    
    func seekTo(time: Float) {
        playerLayer?.player?.seek(to: CMTime(value: CMTimeValue(time), timescale: 1), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero) {_ in 
            if self.pausedByUser {
                return
            }
            self.state = .playing
        }
        print(#function)
    }
}

extension ZZPlayer {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
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
        if playerItem.seekableTimeRanges.count > 0 && playerItem.duration.timescale != 0 {
            let playTime = Int(CMTimeGetSeconds(playerItem.currentTime()))
            let totalTime = Int(CMTimeGetSeconds(playerItem.duration))
            self.delegate?.player(self, playTime: playTime, totalTime: totalTime)
        }
    }
    
    
    /// 数据缓冲
    fileprivate func bufferDatas() {
        if isBuffering {
            return
        }
        isBuffering = true
        
        DispatchQueue.main.zz_after(1) {
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
