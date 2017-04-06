//
//  ZZPlayerView.swift
//  ZZPlayer
//
//  Created by lixiangzhou on 2017/3/23.
//  Copyright © 2017年 lixiangzhou. All rights reserved.
//

import UIKit

private func zz_bundleImage(_ imgName: String) -> UIImage? {
    return UIImage(named: zz_bundleImageName(imgName))
}

private func zz_bundleImageName(_ imgName: String) -> String {
    return "ZZPlayer.bundle/" + imgName
}


class ZZPlayerView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 属性
    /// 最后的一个视频播放结束时是否停止播放, false 时会一直播放最后一个视频
    var playEndStop = true
    /// 开始播放时是否自动播放，当播放结束时是否自动重新播放，优先级低于 playEndStop
    var autoPlay: Bool = true
    fileprivate var player: ZZPlayer?
    var playerItemModel: ZZPlayerItemModel? {
        didSet {
            guard let playerItemModel = playerItemModel else {
                return
            }
            
            titleLabel.text = playerItemModel.title
            
            if player == nil {
                player = ZZPlayer()
                player?.delegate = self
                insertSubview(player!, at: 0)
                player?.snp.makeConstraints({ (maker) in
                    maker.edges.equalTo(self)
                })
            }
            
            guard let player = player else {
                return
            }
            
            player.playerItemModel = playerItemModel
            
            playPauseBtn.setImage(autoPlay ? zz_bundleImage("kr-video-player-pause") : zz_bundleImage("kr-video-player-play"), for: .normal)
        }
    }
    
    var playerItemModels: [ZZPlayerItemModel]? {
        didSet {
            guard let playerItemModel = playerItemModels?.first else {
                return
            }
            self.playerItemModel = playerItemModel
        }
    }
    
    // MARK: - UI 属性
    var backBtn = UIButton(imageName: zz_bundleImageName("play_back_full"))
    var titleLabel = UILabel(text: "标题", fontSize: 14, textColor: UIColor.white)
    
    var playPauseBtn = UIButton(imageName: zz_bundleImageName("kr-video-player-play"))
    var fullScreenBtn = UIButton(imageName: zz_bundleImageName("kr-video-player-fullscreen"))
    var nextBtn = UIButton(imageName: zz_bundleImageName("skip_next"))
    var progressView = UIProgressView()
    var sliderView = UISlider()
    var startTimeLabel = UILabel(text: "00:00", fontSize: 12, textColor: UIColor.white, textAlignment: .right)
    var totalTimeLabel = UILabel(text: "00:00", fontSize: 12, textColor: UIColor.white)
    
    fileprivate var topGradientLayer: CAGradientLayer!
    fileprivate var bottomGradientLayer: CAGradientLayer!
    
    fileprivate var topView: UIView!
    fileprivate var midLeftView: UIView!
    fileprivate var midRightView: UIView!
    fileprivate var bottomView: UIView!
}

// MARK: - ZZPlayerDelegate
extension ZZPlayerView: ZZPlayerDelegate {
    func player(_ player: ZZPlayer, playTime: Int, totalTime: Int) {
        
        startTimeLabel.text = String(format: "%02zd:%02zd", playTime / 60, playTime % 60)
        totalTimeLabel.text = String(format: "%02zd:%02zd", totalTime / 60, totalTime % 60)
        sliderView.maximumValue = Float(totalTime)
        sliderView.value = Float(playTime)
    }
    
    func player(_ player: ZZPlayer, bufferedTime: Int, totalTime: Int) {
        progressView.progress = Float(bufferedTime) / Float(totalTime)
    }
    
    func player(_ player: ZZPlayer, willChange state: ZZPlayerState) {
        if autoPlay == false && state == .readyToPlay {
            DispatchQueue.main.async {
                self.player?.pauseByUser()
            }
        }
    }
    
    func playerDidPlayToEnd(_ player: ZZPlayer) {
        if let playerItemModels = playerItemModels,
            playerItemModels.count > 1 {
            // 多个视频播放结束
            guard let index = playerItemModels.index(where: { (item) -> Bool in
                return item.isEqual(playerItemModel)
            }) else {
                playToEnd(player: player)
                return
            }
            // 如果是最后一个视频，结束播放，否则播放下一个视频
            if index >= playerItemModels.count - 1 {
                playToEnd(player: player)
            } else {
                next_piece()
            }
        } else {    // 单个视频播放结束
            playToEnd(player: player)
        }
    }
}

// MARK: - 辅助
extension ZZPlayerView {
    func playToEnd(player: ZZPlayer) {
        startTimeLabel.text = "00:00"
        player.seekTo(time: 0)
        if playEndStop {
            playPauseBtn.setImage(zz_bundleImage("kr-video-player-play"), for: .normal)
            player.pauseByUser()
        } else {
            playPauseBtn.setImage(autoPlay ? zz_bundleImage("kr-video-player-pause") : zz_bundleImage("kr-video-player-play"), for: .normal)
            autoPlay ? player.play() : player.pauseByUser()
        }
    }
}

// MARK: - Action
extension ZZPlayerView {
    func back() {
        print(#function)
    }
    
    func play_pause() {
        guard let player = player else {
            return
        }
        playPauseBtn.setImage(player.isPlaying ? zz_bundleImage("kr-video-player-play") : zz_bundleImage("kr-video-player-pause"), for: .normal)
        player.isPlaying ? player.pauseByUser() : player.play()
    }
    
    func next_piece() {
        
        guard let playerItemModels = playerItemModels,
            playerItemModels.count > 1 else {
            return
        }
        
        guard let index = playerItemModels.index(where: { (item) -> Bool in
            return item.isEqual(playerItemModel)
        }) else {
            return
        }
        
        if index < playerItemModels.count - 1 {
            self.playerItemModel = playerItemModels[index + 1]
        }
    }
    
    func fullscreen() {
        print(#function)
    }
    
    func playProgress(sender: UISlider) {
        guard let player = player else {
            return
        }
        player.seekTo(time: sender.value)
    }
}

// MARK: - set UI
extension ZZPlayerView {
    fileprivate func setupUI() {
        
        setTopView()
        
        setBottomView()

    }
    
    private func setBottomView() {
        bottomView = zz_add(subview: UIView())
        bottomView.backgroundColor = UIColor.clear
        bottomGradientLayer = addGradientLayer(toView: bottomView, colors: [UIColor.clear.cgColor, UIColor(red: 0, green: 0, blue: 0, alphaValue: 0.9).cgColor])
        
        sliderView.setThumbImage(zz_bundleImage("slider"), for: .normal)
        sliderView.minimumTrackTintColor = UIColor(red: 45, green: 186, blue: 247)
        sliderView.maximumTrackTintColor = UIColor.clear
        sliderView.backgroundColor = UIColor.clear
//        sliderView.value = 0.5
        
        progressView.trackTintColor = UIColor(white: 1, alpha: 0.5)
        progressView.progressTintColor = UIColor(white: 1, alpha: 0.7)
//        progressView.progress = 0.7
        
        bottomView.addSubview(playPauseBtn)
        bottomView.addSubview(fullScreenBtn)
        bottomView.addSubview(nextBtn)
        bottomView.addSubview(progressView)
        bottomView.addSubview(sliderView)
        bottomView.addSubview(startTimeLabel)
        bottomView.addSubview(totalTimeLabel)
        
        playPauseBtn.addTarget(self, action: #selector(play_pause), for: .touchUpInside)
        nextBtn.addTarget(self, action: #selector(next_piece), for: .touchUpInside)
        fullScreenBtn.addTarget(self, action: #selector(fullscreen), for: .touchUpInside)
        sliderView.addTarget(self, action: #selector(playProgress), for: .valueChanged)
        
        bottomView.snp.makeConstraints { (maker) in
            maker.bottom.left.right.equalTo(self)
            maker.height.equalTo(40)
        }
        
        playPauseBtn.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(bottomView)
            maker.left.equalTo(10)
            maker.width.height.equalTo(30)
        }
        
        nextBtn.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(bottomView)
            maker.left.equalTo(playPauseBtn.snp.right).offset(10)
            maker.right.equalTo(startTimeLabel.snp.left).offset(-10)
            maker.width.height.equalTo(30)
        }
        
        let timeLabelWidth = ceil("000:00".zz_size(withLimitWidth: 100, fontSize: 12).width)
        
        
        startTimeLabel.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(bottomView)
            maker.width.equalTo(timeLabelWidth)
            maker.right.equalTo(sliderView.snp.left).offset(-5)
        }
        
        sliderView.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(bottomView)
            maker.right.equalTo(totalTimeLabel.snp.left).offset(-5)
        }
        
        progressView.snp.makeConstraints { (maker) in
            maker.height.equalTo(2)
            maker.width.centerX.equalTo(sliderView)
            maker.centerY.equalTo(sliderView).offset(0.5)
        }
        
        totalTimeLabel.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(bottomView)
            maker.width.equalTo(timeLabelWidth)
            maker.right.equalTo(fullScreenBtn.snp.left).offset(-5)
        }
        
        fullScreenBtn.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(bottomView)
            maker.right.equalTo(-10)
            maker.width.height.equalTo(30)
        }
    }
    
    private func setTopView() {
        topView = zz_add(subview: UIView())
        topView.backgroundColor = UIColor.clear
        topGradientLayer = addGradientLayer(toView: topView, colors: [UIColor(red: 0, green: 0, blue: 0, alphaValue: 0.9).cgColor, UIColor.clear.cgColor])
        
        topView.addSubview(backBtn)
        topView.addSubview(titleLabel)
        
        backBtn.addTarget(self, action: #selector(back), for: .touchUpInside)
        
        topView.snp.makeConstraints { (maker) in
            maker.top.left.right.equalTo(self)
            maker.height.equalTo(40)
        }
        
        backBtn.snp.makeConstraints { (maker) in
            maker.left.equalTo(5)
            maker.centerY.equalTo(topView)
            maker.size.equalTo(CGSize(width: 30, height: 30))
        }
        
        titleLabel.snp.makeConstraints { (maker) in
            maker.left.equalTo(backBtn.snp.right).offset(5)
            maker.centerY.equalTo(topView)
            maker.right.equalTo(-20)
        }
    }
    
    // 添加渐变层
    private func addGradientLayer(toView: UIView, colors: [Any]?) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        toView.layer.addSublayer(gradientLayer)
        return gradientLayer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        topGradientLayer.frame = topView.bounds
        bottomGradientLayer.frame = bottomView.bounds
    }
}

