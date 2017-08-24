//
//  ZZPlayerView.swift
//  ZZPlayer
//
//  Created by lixiangzhou on 2017/3/23.
//  Copyright © 2017年 lixiangzhou. All rights reserved.
//

import UIKit
import MediaPlayer

private func zz_bundleImage(_ imgName: String) -> UIImage? {
    return UIImage(named: zz_bundleImageName(imgName))
}

private func zz_bundleImageName(_ imgName: String) -> String {
    return "ZZPlayer.bundle/" + imgName
}

class ZZPlayerView: UIView {
    
    /// 初始化
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
    /// 播放的资源
    var playerItemResource: ZZPlayerItemResource? {
        didSet {
            guard let playerItemResource = playerItemResource else {
                return
            }
            
            titleLabel.text = playerItemResource.title
            
            if player == nil {
                player = ZZPlayer()
                player?.delegate = self
                insertSubview(player!, at: 0)
                player?.snp.makeConstraints({ (maker) in
                    maker.edges.equalTo(self)
                })
            }
            
            player!.playerItemResource = playerItemResource
            
            playPauseBtn.setImage(autoPlay ? zz_bundleImage("zz_player_pause") : zz_bundleImage("zz_player_play"), for: .normal)
        }
    }
    /// 播放的资源数组
    var playerItemResources: [ZZPlayerItemResource]? {
        didSet {
            guard let playerItemResource = playerItemResources?.first else {
                return
            }
            self.playerItemResource = playerItemResource
        }
    }
    
    /// 自动隐藏控制条的时间
    var autoHideControlDuration: TimeInterval = 4
    
    /// 是否全屏
    fileprivate var isFullScreen: Bool {
        return UIApplication.shared.statusBarOrientation.isLandscape
    }
    /// 播放器
    fileprivate var player: ZZPlayer?
    /// 是否显示控制条
    fileprivate var isControlShowing = true
    // 屏幕滑动调整播放进度相关
    fileprivate var panStartLocation = CGPoint.zero
    
    /// 播放总时间
    fileprivate var totalTime: CGFloat = 0
    
    /// pan手势开始时间
    fileprivate var panStartTime: CGFloat = 0
    
    /// 因手势暂停播放
    fileprivate var pausedForPanGesture = true
    
    /// pan手势是否横向
    fileprivate var panHorizontal = true
    
    /// pan手势是音量
    fileprivate var panVolume = true
    
    /// 开始音量
    fileprivate var startVolumeValue: Float = 0
    
    /// 开始屏幕亮度
    fileprivate var startBrightnessValue: CGFloat = 0
    
    // MARK: - UI 属性
    /// 顶部
    fileprivate let backBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: zz_bundleImageName("zz_player_play_back_full")), for: .normal)
        return btn
    }()
    
    /// 标题
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    
    // MARK:
    /// 底部
    
    /// 播放、暂停按钮
    fileprivate let playPauseBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: zz_bundleImageName("zz_player_play")), for: .normal)
        return btn
    }()

    /// 全屏按钮
    fileprivate let fullScreenBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: zz_bundleImageName("zz_player_fullscreen")), for: .normal)
        return btn
    }()
    
    /// 下一首按钮
    fileprivate let nextBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: zz_bundleImageName("zz_player_skip_next")), for: .normal)
        return btn
    }()

    /// 缓冲进度条
    fileprivate let progressView = UIProgressView()
    
    /// 播放进度条
    fileprivate let sliderView = UISlider()
    
    /// 开始时间
    fileprivate let startTimeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    /// 总时间
    fileprivate let totalTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    // MARK:
    // 顶部底部的透明层
    
    /// 顶部渐变层
    fileprivate var topGradientLayer: CAGradientLayer!
    
    /// 底部渐变层
    fileprivate var bottomGradientLayer: CAGradientLayer!
    
    // MARK:
    
    /// 滑动屏幕时 播放进度控制
    
    /// pan手势控制快进、快退的View
    fileprivate let panPlayingStateView = UIView()
    
    /// pan手势控制快进、快退的图标
    fileprivate let panPlayingStateImgView = UIImageView(image: zz_bundleImage("zz_player_quickback"))
    
    /// pan手势控制快进、快退的时间
    fileprivate let panPlayingStateTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "0 / 0"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        return label
    }()
    
    // MARK:
    // 滑动屏幕时 音量/亮度控制
    fileprivate var volumeSlider: UISlider = {
        var slider: UISlider?
        for sub in MPVolumeView().subviews {
            if sub is UISlider {
                slider = sub as? UISlider
                break
            }
        }
        return slider!
    }()
    
    // MARK:
    
    /// 顶部View
    fileprivate var topView: UIView!
    
    /// 底部View
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
        if let playerItemResources = playerItemResources,
            playerItemResources.count > 1 {
            // 多个视频播放结束
            guard let index = playerItemResources.index(where: { (item) -> Bool in
                return item.isEqual(playerItemResource)
            }) else {
                playToEnd(player: player)
                return
            }
            // 如果是最后一个视频，结束播放，否则播放下一个视频
            if index >= playerItemResources.count - 1 {
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
    /// 播放结束时
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
    
    /// 隐藏控制条
    @objc fileprivate func hideControl() {
        UIView.animate(withDuration: 0.5, animations: {
            self.topView.alpha = 0
            self.bottomView.alpha = 0
        }) { (_) in
            self.isControlShowing = false
        }
    }
    
    /// 稍后隐藏控制条
    fileprivate func hideControlLater() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideControl), object: nil)
        perform(#selector(hideControl), with: nil, afterDelay: autoHideControlDuration)
    }
    
    
    /// 转换时间
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
    
    /// 开始横向手势
    fileprivate func beginPanHorizontal(location: CGPoint) {
        guard let player = player, let playerItem = player.currentPlayerItem else {
            return
        }
        showControl()
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideControl), object: nil)
        
        if player.isPaused {
            pausedForPanGesture = false
        } else {
            pausedForPanGesture = true
            player.pauseByUser()
        }
        
        self.totalTime = CGFloat(CMTimeGetSeconds(playerItem.duration))
        self.panStartTime = CGFloat(CMTimeGetSeconds(playerItem.currentTime()))
        UIView.animate(withDuration: 0.1, animations: {
            self.panPlayingStateView.alpha = 1
        })
    }
    
    
    /// 处理横向手势
    fileprivate func panHorizontal(location: CGPoint) {
        let offsetX = location.x - panStartLocation.x
        // 滑满一屏最多是总时长的20%
        let offsetTime = offsetX / self.bounds.width * self.totalTime * 0.2
        
        if offsetTime == CGFloat.nan {
            return
        }
        
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
    
    
    /// 横向手势结束
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
    
    /// 开始纵向手势
    fileprivate func beginPanVertical(location: CGPoint) {
        panVolume = location.x < bounds.midX
        if panVolume {
            startVolumeValue = volumeSlider.value
        } else {
            startBrightnessValue = UIScreen.main.brightness
        }
    }
    
    /// 处理纵向手势
    fileprivate func panVertical(location: CGPoint) {
        let offsetY = panStartLocation.y - location.y
        let offsetProgress = offsetY / bounds.height
        
        if panVolume {
            var newValue = startVolumeValue + Float(offsetProgress)
            newValue = max(newValue, 0)
            newValue = min(newValue, 1)
            
            volumeSlider.value = newValue
        } else {
            var newValue = startBrightnessValue + offsetProgress
            newValue = max(newValue, 0)
            newValue = min(newValue, 1)
            
            UIScreen.main.brightness = newValue
        }
    }
}

// MARK: - 功能方法
extension ZZPlayerView {
    // 返回
    func back() {
        if isFullScreen {
            fullscreen()
        } else {
            
        }

        print(#function)
    }
    
    
    /// 暂停、播放
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
    
    
    /// 下一首
    func next_piece() {
        guard let playerItemResources = playerItemResources,
            playerItemResources.count > 1 else {
            return
        }
        
        guard let index = playerItemResources.index(where: { (item) -> Bool in
            return item.isEqual(playerItemResource)
        }) else {
            return
        }
        
        if index < playerItemResources.count - 1 {
            self.playerItemResource = playerItemResources[index + 1]
        }
    }
    
    
    /// 全屏
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
    
    
    /// 处理进度
    func playProgress(sender: UISlider) {
        guard let player = player else {
            return
        }
        player.seekTo(time: sender.value)
    }
    
    
    /// 进度结束
    func playProgressLeave(sender: UISlider) {
        hideControlLater()
    }
    
    
    /// 点击手势，用来控制控制条的显示隐藏
    func tapAction() {
        isControlShowing ? hideControlLater() : showControl()
    }
    
    
    /// 滑动手势，用来控制音量、亮度、快进、快退
    func panAction(pan: UIPanGestureRecognizer) {
        let location = pan.location(in: self)
        
        if bounds.contains(location) == false {
            return
        }
        
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
        bottomView = UIView()
        addSubview(bottomView)
        bottomView.backgroundColor = UIColor.clear
        
        bottomGradientLayer = addGradientLayer(toView: bottomView, colors: [UIColor.clear.cgColor, UIColor(red: 0, green: 0, blue: 0, alpha: 0.9).cgColor])
        
        sliderView.setThumbImage(zz_bundleImage("zz_player_slider"), for: .normal)
        sliderView.minimumTrackTintColor = UIColor(red: 45 / 255.0, green: 186 / 255.0, blue: 247 / 255.0, alpha: 1)
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
            maker.width.height.equalTo(25)
        }
        
        nextBtn.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(bottomView)
            maker.left.equalTo(playPauseBtn.snp.right).offset(10)
            maker.width.height.equalTo(25)
        }
        
        
        let timeLabelWidth = ceil(("00:00:00" as NSString).boundingRect(with: CGSize(width: 100, height: 100), options: [], attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12)], context: nil).size.width)
        
        
        startTimeLabel.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(bottomView)
            maker.width.equalTo(timeLabelWidth)
            maker.left.equalTo(nextBtn.snp.right)
        }
        
        sliderView.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(bottomView)
            maker.left.equalTo(nextBtn.snp.right).offset(timeLabelWidth + 10)
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
            maker.width.height.equalTo(25)
        }
    }
    
    private func setTopView() {
        topView = UIView()
        addSubview(topView)
        topView.backgroundColor = UIColor.clear
        topGradientLayer = addGradientLayer(toView: topView, colors: [UIColor(red: 0, green: 0, blue: 0, alpha: 0.9).cgColor, UIColor.clear.cgColor])
        
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
    
    
    /// 布局渐变层
    override func layoutSubviews() {
        super.layoutSubviews()
        
        topGradientLayer.frame = topView.bounds
        bottomGradientLayer.frame = bottomView.bounds
    }
}
