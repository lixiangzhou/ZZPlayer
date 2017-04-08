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
        
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        addGestureRecognizer(tap)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction))
        addGestureRecognizer(pan)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        layoutIfNeeded()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - 属性
    /// 最后的一个视频播放结束时是否停止播放, false 时会一直播放最后一个视频
    var playEndStop = true
    /// 开始播放时是否自动播放，当播放结束时是否自动重新播放，优先级低于 playEndStop
    var autoPlay: Bool = true
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
            
            playPauseBtn.setImage(autoPlay ? zz_bundleImage("zz_player_pause") : zz_bundleImage("zz_player_play"), for: .normal)
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
    
    var autoHideControlDuration: TimeInterval = 4
    
    fileprivate var isFullScreen: Bool {
        return UIApplication.shared.statusBarOrientation.isLandscape
    }
    fileprivate var player: ZZPlayer?
    fileprivate var isControlShowing = true
    // 屏幕滑动调整播放进度相关
    fileprivate var panStartLocation = CGPoint.zero
    fileprivate var totalTime: CGFloat = 0
    
    fileprivate var panStartTime: CGFloat = 0
    fileprivate var pausedForPanGesture = true
    fileprivate var panHorizontal = true
    fileprivate var panVolume = true
    
    // MARK: - UI 属性
    // 顶部
    fileprivate let backBtn = UIButton(imageName: zz_bundleImageName("zz_player_play_back_full"))
    fileprivate let titleLabel = UILabel(text: "标题", fontSize: 14, textColor: UIColor.white)
    
    // MARK:
    // 底部
    fileprivate let playPauseBtn = UIButton(imageName: zz_bundleImageName("zz_player_play"))
    fileprivate let fullScreenBtn = UIButton(imageName: zz_bundleImageName("zz_player_fullscreen"))
    fileprivate let nextBtn = UIButton(imageName: zz_bundleImageName("zz_player_skip_next"))
    fileprivate let progressView = UIProgressView()
    fileprivate let sliderView = UISlider()
    fileprivate let startTimeLabel = UILabel(text: "00:00", fontSize: 12, textColor: UIColor.white, textAlignment: .right)
    fileprivate let totalTimeLabel = UILabel(text: "00:00", fontSize: 12, textColor: UIColor.white)
    
    // MARK:
    // 顶部底部的透明层
    fileprivate var topGradientLayer: CAGradientLayer!
    fileprivate var bottomGradientLayer: CAGradientLayer!
    
    // MARK:
    
    // 滑动屏幕时 播放进度控制
    fileprivate let panPlayingStateView = UIView()
    fileprivate let panPlayingStateImgView = UIImageView(image: zz_bundleImage("zz_player_quickback"))
    fileprivate let panPlayingStateTimeLabel = UILabel(text: "0 / 0", fontSize: 12, textColor: UIColor.white, textAlignment: .center)
    
    // MARK:
    // 滑动屏幕时 音量/亮度控制
    fileprivate let panVolumeView = ZZPlayerProgressView()
    fileprivate let panBrightnessView = ZZPlayerProgressView()
    
    // MARK:
    fileprivate var topView: UIView!
    fileprivate var bottomView: UIView!
}

// MARK: - ZZPlayerDelegate
extension ZZPlayerView: ZZPlayerDelegate {
    func player(_ player: ZZPlayer, playTime: Int, totalTime: Int) {
        
        startTimeLabel.text = transform(time: playTime)
        totalTimeLabel.text = transform(time: totalTime)
        sliderView.maximumValue = Float(totalTime)
        sliderView.value = Float(playTime)
    }
    
    func player(_ player: ZZPlayer, bufferedTime: Int, totalTime: Int) {
        progressView.progress = Float(bufferedTime) / Float(totalTime)
    }
    
    func player(_ player: ZZPlayer, willChange state: ZZPlayerState) {
        if state == .readyToPlay {
            if autoPlay == false {
                DispatchQueue.main.async {
                    self.player?.pauseByUser()
                }
            } else {
                hideControlLater()
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
    fileprivate func playToEnd(player: ZZPlayer) {
        startTimeLabel.text = "00:00"
        player.seekTo(time: 0)
        if playEndStop {
            playPauseBtn.setImage(zz_bundleImage("zz_player_play"), for: .normal)
            player.pauseByUser()
        } else {
            playPauseBtn.setImage(autoPlay ? zz_bundleImage("zz_player_pause") : zz_bundleImage("zz_player_play"), for: .normal)
            autoPlay ? player.play() : player.pauseByUser()
        }
    }
    
    @objc fileprivate func orientationChanged() {
        print(#function)
    }
    
    // MARK: - 控制层的显示隐藏
    fileprivate func showControl() {
        UIView.animate(withDuration: 0.5, animations: {
            self.topView.alpha = 1
            self.bottomView.alpha = 1
            }) { (_) in
                self.isControlShowing = true
        }
    }
    
    @objc fileprivate func hideControl() {
        UIView.animate(withDuration: 0.5, animations: {
            self.topView.alpha = 0
            self.bottomView.alpha = 0
        }) { (_) in
            self.isControlShowing = false
        }
    }
    
    fileprivate func hideControlLater() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideControl), object: nil)
        perform(#selector(hideControl), with: nil, afterDelay: autoHideControlDuration)
    }
    
    fileprivate func transform(time: Int) -> String {
        var timeString = ""
        if time >= 3600 {
            timeString = String(format: "%02zd:%02zd:%02zd", time / 3600, time / 60, time % 60)
        } else {
            timeString = String(format: "%02zd:%02zd", time / 60, time % 60)
        }
        return timeString
    }
    
    // MARK: - 滑动控制播放进度
    fileprivate func beginPanHorizontal(location: CGPoint) {
        guard let player = player, let playerItem = player.currentPlayerItem else {
            return
        }
        showControl()
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideControl), object: nil)
        
        if player.isPaused {
            pausedForPanGesture = false
        } else {
            player.pauseByUser()
        }
        
        self.totalTime = CGFloat(playerItem.duration.value) / CGFloat(playerItem.duration.timescale)
        self.panStartTime = CGFloat(playerItem.currentTime().value) / CGFloat(playerItem.currentTime().timescale)
        
        UIView.animate(withDuration: 0.1, animations: {
            self.panPlayingStateView.alpha = 1
        })
    }
    
    fileprivate func panHorizontal(location: CGPoint) {
        let offsetX = location.x - panStartLocation.x
        // 滑满一屏最多是总时长的20%
        let offsetTime = offsetX / self.zz_width * self.totalTime * 0.2
        
        var time = Int(self.panStartTime + offsetTime)
        if time <= 0 {
            time = 0
        }
        
        if offsetX > 0 {
            panPlayingStateImgView.image = zz_bundleImage("zz_player_quickforward")
        } else {
            panPlayingStateImgView.image = zz_bundleImage("zz_player_quickback")
        }
        
        panPlayingStateTimeLabel.text = transform(time: time) + " / " + transform(time: Int(self.totalTime))
        
        player?.seekTo(time: Float(time))
    }
    
    fileprivate func endHorizontal() {
        if pausedForPanGesture {
            play_pause()
        }
        
        hideControlLater()
        
        UIView.animate(withDuration: 0.5, animations: {
            self.panPlayingStateView.alpha = 0
        })
    }

    
    // MARK: - 滑动控制音量/亮度
    fileprivate func beginPanVertical(location: CGPoint) {
        panVolume = location.x < bounds.midX
    }
    
    fileprivate func panVertical(location: CGPoint) {
        let offsetY = location.y - panStartLocation.y
        let offsetProgress = offsetY / bounds.height
        if panVolume {
            
        } else {
            
        }
    }
}

// MARK: - 功能方法
extension ZZPlayerView {
    func back() {
        if isFullScreen {
            fullscreen()
        } else {
            
        }

        print(#function)
    }
    
    func play_pause() {
        guard let player = player else {
            return
        }

        if !player.isPaused {
            playPauseBtn.setImage(zz_bundleImage("zz_player_play"), for: .normal)
            player.pauseByUser()
        } else {
            playPauseBtn.setImage(zz_bundleImage("zz_player_pause"), for: .normal)
            player.play()
            hideControlLater()
        }
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
        if let player = player, !player.isPaused {
            hideControlLater()
        }
        
        if isFullScreen {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            UIApplication.shared.statusBarOrientation = .portrait
        } else {
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            UIApplication.shared.statusBarOrientation = .landscapeRight
        }
        
        print(#function)
    }
    
    func playProgress(sender: UISlider) {
        guard let player = player else {
            return
        }
        player.seekTo(time: sender.value)
    }
    
    func playProgressLeave(sender: UISlider) {
        hideControlLater()
    }
    
    func tapAction() {
        isControlShowing ? hideControl() : showControl()
    }
    
    func panAction(pan: UIPanGestureRecognizer) {
        let location = pan.location(in: self)
        
        switch pan.state {
        case .began:
            let velocity = pan.velocity(in: self)
            panStartLocation = location
            panHorizontal = abs(velocity.x) > abs(velocity.y)
            if panHorizontal {
                beginPanHorizontal(location: location)
            } else {
                beginPanVertical(location: location)
            }
            
        case .changed:
            if panHorizontal {
                panHorizontal(location: location)
            } else {
                panVertical(location: location)
            }
        default:
            if panHorizontal {
                endHorizontal()
            }
            
            break
        }
    }
}

// MARK: - UI
extension ZZPlayerView {
    fileprivate func setupUI() {
        backgroundColor = UIColor.black
        
        setTopView()
        
        setBottomView()

        setMidView()
    }
    
    private func setMidView() {
        setPanPlayingStateView()
    }
    
    private func setPanPlayingStateView() {
        addSubview(panPlayingStateView)
        panPlayingStateView.alpha = 0
        panPlayingStateView.backgroundColor = UIColor(white: 0, alpha: 0.75)
        
        panPlayingStateView.addSubview(panPlayingStateImgView)
        panPlayingStateView.addSubview(panPlayingStateTimeLabel)
        
        let imgSize = panPlayingStateImgView.image!.size
        
        panPlayingStateView.snp.makeConstraints { (maker) in
            maker.centerX.equalTo(self)
            maker.centerY.equalTo(self).multipliedBy(0.8)
            maker.width.equalTo(100)
        }
        
        panPlayingStateImgView.snp.makeConstraints { (maker) in
            maker.top.equalTo(5)
            maker.centerX.equalTo(panPlayingStateView)
            maker.height.equalTo(30)
            maker.width.equalTo(imgSize.width / imgSize.height * 30)
        }
        
        panPlayingStateTimeLabel.snp.makeConstraints { (maker) in
            maker.top.equalTo(panPlayingStateImgView.snp.bottom).offset(5)
            maker.centerX.equalTo(panPlayingStateView)
            maker.bottom.equalTo(panPlayingStateView).offset(-5)
            maker.width.equalTo(panPlayingStateView)
        }
    }
    
    private func setBottomView() {
        bottomView = zz_add(subview: UIView())
        bottomView.backgroundColor = UIColor.clear
        bottomGradientLayer = addGradientLayer(toView: bottomView, colors: [UIColor.clear.cgColor, UIColor(red: 0, green: 0, blue: 0, alphaValue: 0.9).cgColor])
        
        sliderView.setThumbImage(zz_bundleImage("slider"), for: .normal)
        sliderView.minimumTrackTintColor = UIColor(red: 45, green: 186, blue: 247)
        sliderView.maximumTrackTintColor = UIColor.clear
        sliderView.backgroundColor = UIColor.clear
        
        progressView.trackTintColor = UIColor(white: 1, alpha: 0.5)
        progressView.progressTintColor = UIColor(white: 1, alpha: 0.7)
        
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
        sliderView.addTarget(self, action: #selector(playProgressLeave), for: [.touchUpOutside, .touchUpInside, .touchCancel])
        
        bottomView.addGestureRecognizer(UITapGestureRecognizer(target: nil, action: nil))
        
        bottomView.snp.makeConstraints { (maker) in
            maker.bottom.left.right.equalTo(self)
            maker.height.equalTo(30)
        }
        
        playPauseBtn.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(bottomView)
            maker.left.equalTo(10)
            maker.width.height.equalTo(15)
        }
        
        nextBtn.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(bottomView)
            maker.left.equalTo(playPauseBtn.snp.right).offset(10)
            maker.right.equalTo(startTimeLabel.snp.left).offset(-10)
            maker.width.height.equalTo(15)
        }
        
        let timeLabelWidth = ceil("00:00:00".zz_size(withLimitWidth: 100, fontSize: 12).width)
        
        
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
            maker.right.equalTo(fullScreenBtn.snp.left)
        }
        
        fullScreenBtn.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(bottomView)
            maker.right.equalTo(-10)
            maker.width.height.equalTo(15)
        }
    }
    
    private func setTopView() {
        topView = zz_add(subview: UIView())
        topView.backgroundColor = UIColor.clear
        topGradientLayer = addGradientLayer(toView: topView, colors: [UIColor(red: 0, green: 0, blue: 0, alphaValue: 0.9).cgColor, UIColor.clear.cgColor])
        
        topView.addSubview(backBtn)
        topView.addSubview(titleLabel)
        
        backBtn.addTarget(self, action: #selector(back), for: .touchUpInside)
        
        topView.addGestureRecognizer(UITapGestureRecognizer(target: nil, action: nil))
        
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

private let progressThemeColor = UIColor(red: 45, green: 45, blue: 45)
class ZZPlayerProgressView: UIView {
    
    class _ZZPlayerProgressView: UIView {
        
        var progress: CGFloat = 0 {
            didSet {
                setNeedsDisplay()
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: CGRect(x: 0, y: 0, width: 129, height: 7))
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func draw(_ rect: CGRect) {
            let progressBgPath = UIBezierPath(rect: rect)
            progressThemeColor.setFill()
            progressBgPath.fill()
            
            let count = Int(floor(progress * 16))
            
            let itemW: CGFloat = 7
            let itemH: CGFloat = 5
            for i in 0..<count {
                let itemX = CGFloat(i) * itemW + CGFloat(i) + 1
                let r = CGRect(x: itemX, y: 1, width: itemW, height: itemH)
                
                let p = UIBezierPath(rect: r)
                UIColor.white.setFill()
                p.fill()
            }
        }
    }
    
    var titleLabel = UILabel(text: "", fontSize: 15, textColor: UIColor.lightGray, textAlignment: .center)
    var iconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 74, height: 63))
    var progressView = _ZZPlayerProgressView()
    var progress: CGFloat = 0.0 {
        didSet {
            progressView.progress = progress
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 155, height: 155))
        
        backgroundColor = nil
        
        let bgView = zz_add(subview: UIImageView(frame: bounds)) as! UIImageView
        bgView.image = zz_bundleImage("zz_player_brightness_bg")
        
        setupUI()
        config()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config() { }
    
    func setupUI() {
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        addSubview(titleLabel)
        addSubview(iconView)
        addSubview(progressView)
        
        iconView.image = zz_bundleImage("zz_player_brightness")
        
        titleLabel.frame = CGRect(x: 0, y: 10, width: bounds.width, height: 20)
        titleLabel.textColor = progressThemeColor
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        
        iconView.center.x = bounds.width * 0.5
        iconView.zz_y = titleLabel.frame.maxY + 20
        
        progressView.zz_x = 13
        progressView.zz_y = 132.5
    }
}

class ZZPlayerVolumeProgressView: ZZPlayerProgressView {
    private let silentLabel = UILabel(text: "静音", fontSize: 14, textColor: progressThemeColor, textAlignment: .center)
    override func setupUI() {
        super.setupUI()
        
        addSubview(silentLabel)
        silentLabel.sizeToFit()
        silentLabel.center = progressView.center
        silentLabel.isHidden = true
    }
    override func config() {
        titleLabel.text = "音量"
        iconView.image = zz_bundleImage("zz_player_volume")
    }
    
    override var progress: CGFloat {
        didSet {
            iconView.image = zz_bundleImage(progress > 0 ? "zz_player_volume" : "zz_player_volume_silent")
            silentLabel.isHidden = progress > 0
            progressView.isHidden = progress <= 0
        }
    }
}

