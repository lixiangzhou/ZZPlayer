//
//  ZZPlayer.swift
//  ZZPlayer
//
//  Created by lixiangzhou on 2017/3/23.
//  Copyright © 2017年 lixiangzhou. All rights reserved.
//

import UIKit
import AVFoundation

enum ZZPlayerState {
    case idle               // 空闲状态
    case readyToPlay        // 可以播放状态
    case playing            // 播放中
    case paused             // 暂停
    case buffering          // 缓冲
    case failed             // 失败
}

/// play item model protocol
@objc protocol ZZPlayerItemModel {
    var title: String? { get set }
    var videoUrlString: String? { get set }
    @objc optional var placeholderImage: UIImage? { get set }
    @objc optional var placeholderImageUrl: String?  { get set }
    @objc optional var resolutions: [String: String]?  { get set }
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
    
    // MARK: - Properties
    var playerLayer: AVPlayerLayer?
    
    var playerItemModel: ZZPlayerItemModel? {
        didSet {
            guard let videoUrlString = playerItemModel?.videoUrlString,
                let videoUrl = URL(string: videoUrlString) else {
                return
            }
            if playerLayer == nil {
                let asset = AVAsset(url: videoUrl)
                let item = AVPlayerItem(asset: asset)
                let player = AVPlayer(playerItem: item)
                playerLayer = AVPlayerLayer(player: player)
                layer.insertSublayer(playerLayer!, at: 0)
            }
        }
    }
    
    var playerItemModels: [ZZPlayerItemModel]? {
        didSet {
            
        }
    }
    
    var state: ZZPlayerState = .idle {
        didSet {
            
            guard let playerLayer = playerLayer,
                let player = playerLayer.player else {
                return
            }
            
            switch state {
            case .idle:         // 空闲
                break
            case .buffering:    // 缓冲中
                break
            case .readyToPlay:  // 准备好了播放
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
        }
    }
}


// MARK: -
extension ZZPlayer {
    func pause() {
        state = .paused
        print(#function)
    }
    
    func play() {
        state = .playing
        print(#function)
    }
    
    func next() {
        print(#function)
    }
}

// MARK: - Config
extension ZZPlayer {
    
    func initialize() {
        
    }
}
