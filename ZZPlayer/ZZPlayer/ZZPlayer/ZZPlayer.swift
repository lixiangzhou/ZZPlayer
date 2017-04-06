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
    func player(_ player: ZZPlayer, bufferedTime: Int, totalTime: Int)
    func player(_ player: ZZPlayer, playTime: Int, totalTime: Int)
    func playerDidPlayToEnd(_ player: ZZPlayer)
    @objc optional func player(_ player: ZZPlayer, willChange state: ZZPlayerState)
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
            
            // 有在播放的item, 就取消该 item 的监听操作
            if let playerItem = playerLayer?.player?.currentItem {
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
                
                playerItem.removeObserver(self, forKeyPath: ZZPlayerObseredKeyPath.status.rawValue)
                playerItem.removeObserver(self, forKeyPath: ZZPlayerObseredKeyPath.loadedTimeRanges.rawValue)
                playerItem.removeObserver(self, forKeyPath: ZZPlayerObseredKeyPath.playbackBufferEmpty.rawValue)
                playerItem.removeObserver(self, forKeyPath: ZZPlayerObseredKeyPath.playbackLikelyToKeepUp.rawValue)
            }
            
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
//            NotificationCenter.addObserver(self, forKeyPath: NSNotification.Name.AVPlayerItemDidPlayToEndTime.rawValue, options: .new, context: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(didPlayToEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            
            playerItem.addObserver(self, forKeyPath: ZZPlayerObseredKeyPath.status.rawValue, options: .new, context: nil)
            playerItem.addObserver(self, forKeyPath: ZZPlayerObseredKeyPath.loadedTimeRanges.rawValue, options: .new, context: nil)
            playerItem.addObserver(self, forKeyPath: ZZPlayerObseredKeyPath.playbackBufferEmpty.rawValue, options: .new, context: nil)
            playerItem.addObserver(self, forKeyPath: ZZPlayerObseredKeyPath.playbackLikelyToKeepUp.rawValue, options: .new, context: nil)
        }
    }
    
    var isPlaying: Bool {
        return state == .playing
    }
    
    fileprivate var playerLayer: AVPlayerLayer?
    /// 是否由用户点击暂停还是由其他的原因（如没有缓冲好数据）
    fileprivate var pausedByUser = false
    
    fileprivate var state: ZZPlayerState = .idle {
        didSet {
            guard let playerLayer = playerLayer,
                let player = playerLayer.player else {
                return
            }
            
            if oldValue != state {
                delegate?.player?(self, willChange: state)
            }
            
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
            
            if oldValue != state {
                delegate?.player?(self, didChanged: state)
            }
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
    }
}

extension ZZPlayer {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let playerItem = playerLayer?.player?.currentItem else {
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
    
    func initialize() {
        
    }
    
    func processPlayTime(_ playerItem: AVPlayerItem) {
        if playerItem.seekableTimeRanges.count > 0 && playerItem.duration.timescale != 0 {
            let playTime = Int(CMTimeGetSeconds(playerItem.currentTime()))
            let totalTime = Int(CMTimeGetSeconds(playerItem.duration))
            self.delegate?.player(self, playTime: playTime, totalTime: totalTime)
        }
    }
    
    func bufferDatas() {
        if isBuffering {
            return
        }
        isBuffering = true
        
//        playerLayer?.player?.pause()
        
        DispatchQueue.main.zz_after(1) {
            guard let playerItem = self.playerLayer?.player?.currentItem else {
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
}
