//
//  ZZPlayerView.swift
//  ZZPlayer
//
//  Created by lixiangzhou on 2017/3/23.
//  Copyright © 2017年 lixiangzhou. All rights reserved.
//

import UIKit
import MediaPlayer
import SnapKit
import Kingfisher

class ZZPlayerView: UIView {
    
    public static let shared = ZZPlayerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 3 / 4))
    
    /// 初始化
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
        
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
        
        if rootView.isEqual(superview) == false {
            self.containerView = superview
        }
    }
    
     deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - 属性 Public
    /// 屏幕方向模式
    var orientationMode = ZZPlayerOrientationMode.any
    
    /// 布局配置
    private var _config: ZZPlayerViewConfig!
    var config: ZZPlayerViewConfig {
        set {
            switch orientationMode {
            case .any:
                _config = newValue
            case .portrait:
                _config = configVertical
            case .landscapeRight, .landscapeLeft:
                _config = configHorizontal
            }
            updateTop()
            updateMid()
            updateBottom()

            layoutIfNeeded()
        }
        get {
            switch orientationMode {
            case .any:
                return _config ?? configVertical
            case .portrait:
                return configVertical
            case .landscapeRight, .landscapeLeft:
                return configHorizontal
            }
        }
    }
    
    /// 竖屏配置
    var configVertical = ZZPlayerViewConfig()
    
    /// 横屏配置
    var configHorizontal = ZZPlayerViewConfig()
    
    /// 播放的资源
    var playerItemResource: ZZPlayerItemResource? {
        didSet {
            guard let playerItemResource = playerItemResource else {
                player?.playerItemResource = nil
                validResource = false
                titleLabel.text = ""
                sliderView.value = 0
                startTimeLabel.text = "00:00"
                totalTimeLabel.text = "00:00"
                return
            }
            validResource = true
            
            titleLabel.text = playerItemResource.title
            
            if player == nil {
                player = ZZPlayer.shared
                player?.delegate = self
                insertSubview(player!, at: 0)
                player?.snp.makeConstraints { (maker) in
                    maker.edges.equalTo(self)
                }
            }
            
            player!.playerItemResource = playerItemResource
            
            backgroundImageView.kf.setImage(
                with: URL(string: playerItemResource.placeholderImageUrl ?? ""),
                placeholder: playerItemResource.placeholderImage)
            
            playPauseBtn.setImage(config.autoPlay ? config.bottom.playPausePauseImg : config.bottom.playPausePlayImg, for: .normal)
        }
    }
    /// 播放的资源数组
    var playerItemResources: [ZZPlayerItemResource]? {
        didSet {
            guard let playerItemResource = playerItemResources?.first else { return }
            
            self.playerItemResource = playerItemResource
        }
    }
    
    /// 返回操作
    var backAction: (() -> ())?
    
    
    // MARK: - Private
    /// 是否全屏
    private var isFullScreen = false
    
    /// 播放器
    private var player: ZZPlayer?
    
    /// 是否显示控制条
    private var isControlShowing = true
    
    // 屏幕滑动调整播放进度相关
    private var panStartLocation = CGPoint.zero
    
    /// 播放总时间
    private var totalTime: CGFloat = 0
    
    /// pan手势开始时间
    private var panStartTime: CGFloat = 0
    
    /// 因手势暂停播放
    private var pausedForPanGesture = true
    
    /// pan手势是否横向
    private var panHorizontal = true
    
    /// pan手势是音量
    private var panVolume = true
    
    /// 开始音量
    private var startVolumeValue: Float = 0
    
    /// 开始屏幕亮度
    private var startBrightnessValue: CGFloat = 0
    
    /// 播放器所在的父View
    private var containerView: UIView!
    
    /// 应用的rootView
    private var rootView: UIView {
        return UIApplication.shared.keyWindow!.rootViewController!.view
    }
    
    /// 播放器所在的控制器
    private var controller: UIViewController? {
        var responder = next
        while responder != nil && (responder! is UIViewController == false) {
            responder = responder!.next
        }
        return responder as? UIViewController
    }
    
    /// 在Cell中播放时，播放器父View的tag值
    private var playerContainerTag = 0
    
    /// 在Cell中播放时，播放器所在的Cell
    private var playerInCell: UIView?
    
    /// 在Cell中播放时，播放器所在的UITableView或UICollectionView
    private var playerScrollView: UIScrollView?
    
    /// 在Cell中播放时，停止播放的原因
    private var playerPausedInCellReason = ZZCellPlayerStopReason.cellRectEdgeLeaveScrollView
    
    /// 资源是否有效
    private var validResource = true
    
    // MARK: - UI 属性
    
    /// 顶部背景图
    private let topBackgroundView = UIImageView()
    
    /// 顶部返回
    private var backBtn: UIButton!
    
    /// 标题
    private var titleLabel: UILabel!
    
    
    // MARK: -
    /// 底部
    
    private let bottomBackgroundView = UIImageView()
    
    /// 播放、暂停按钮
    private var playPauseBtn: UIButton!

    /// 全屏按钮
    private var fullScreenBtn: UIButton!
    
    /// 下一首按钮
    private var nextBtn: UIButton!

    /// 缓冲进度条
    private let progressView = UIProgressView()
    
    /// 播放进度条
    private let sliderView = UISlider()
    
    /// 开始时间
    private var startTimeLabel: UILabel!
    
    /// 总时间
    private var totalTimeLabel: UILabel!
    
    // MARK: -
    // 顶部底部的透明层
    
    /// 顶部渐变层
    private var topGradientLayer: CAGradientLayer!
    
    /// 底部渐变层
    private var bottomGradientLayer: CAGradientLayer!
    
    // MARK: -
    
    /// 滑动屏幕时 播放进度控制
    
    /// pan手势控制快进、快退的View
    private let panPlayingStateView = UIView()
    
    /// pan手势控制快进、快退的图标
    private var panPlayingStateImgView: UIImageView!
    
    /// pan手势控制快进、快退的时间
    private var panPlayingStateTimeLabel: UILabel!
    
    /// 缓冲加载
    private var loadingView = UIActivityIndicatorView(style: .whiteLarge)
    
    // MARK: -
    // 滑动屏幕时 音量/亮度控制
    private var volumeSlider: UISlider = {
        var slider: UISlider?
        for sub in MPVolumeView().subviews {
            if sub is UISlider {
                slider = sub as? UISlider
                break
            }
        }
        return slider!
    }()
    
    // MARK: -
    
    /// 顶部View
    private let topView = UIView()
    
    /// 底部View
    private let bottomView = UIView()
    
    /// 背景
    private let backgroundImageView = UIImageView()
    
    enum ZZCellPlayerStopReason {
        case cellRectNotInScrollView
        case cellRectEdgeLeaveScrollView
    }
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
        print(#function, state)
        if state == .readyToPlay {
            if config.autoPlay == false {
                DispatchQueue.main.async {
                    self.player?.pauseByUser()
                }
            } else {
                DispatchQueue.main.async {
                    self.play()
                }
                
                hideControlLater()
            }
            self.player?.seekTo(time: Float(self.playerItemResource!.seekTo))
        }
        
        let needLoading = state == .buffering || (state == .idle && player.currentPlayerItem != nil) || state == .readyToPlay
        needLoading ? loadingView.startAnimating() : loadingView.stopAnimating()
        
    }
    
    func playerDidPlayToEnd(_ player: ZZPlayer) {
        if let playerItemResources = playerItemResources,
            playerItemResources.count > 1 {
            if config.repeatMultipleItems && config.repeatSingleItem == false {
                // 多个视频播放结束
                guard let index = playerItemResources.firstIndex(where: { (item) -> Bool in
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
            } else {
                playToEnd(player: player)
            }
        } else {    // 单个视频播放结束
            playToEnd(player: player)
        }
    }
}

// MARK: - 辅助
extension ZZPlayerView {
    /// 播放结束时
    private func playToEnd(player: ZZPlayer) {
        startTimeLabel.text = "00:00"
        
        if config.repeatSingleItem {
            let resource = self.playerItemResource
            self.playerItemResource = resource
            if config.showControlWhenPlayEnd {
                showControlLaterHide()
            }
        } else {
            player.seekTo(time: 0)
            if config.showControlWhenPlayEnd {
                showControl()
            }
            pause()
        }
    }
    
    // MARK: - 屏幕方向改变
    ///
    @objc private func orientationChanged() {
        let orientation = UIDevice.current.orientation
        let currentOrientation = UIDeviceOrientation.init(rawValue: UIApplication.shared.statusBarOrientation.rawValue)!
        
        if orientation == .faceUp ||
            orientation == .faceDown ||
            orientation == .unknown ||
            orientation == .portraitUpsideDown ||
            orientation == currentOrientation {
            return
        }
        
        switch (orientationMode, orientation) {
        case (.portrait, .portrait), (.landscapeLeft, .landscapeLeft), (.landscapeRight, .landscapeRight), (.any, _):
            toOrientation(orientation)
        default:
            break
        }
    }
    
    private func toOrientation(_ orientation: UIDeviceOrientation) {
        if containerView == nil { return }
        
        self.isFullScreen = orientation != .portrait
        
        switch orientation {
        case .portrait:
            config = configVertical
            fullScreenBtn.setImage(config.bottom.fullScreenImg, for: .normal)
            
            containerView.addSubview(self)
            
            snp.remakeConstraints({ (maker) in
                maker.edges.equalTo(containerView)
            })
            
            UIView.animate(withDuration: 0.25, animations: {
                self.transform = .identity
                self.layoutIfNeeded()
            })
            UIApplication.shared.statusBarOrientation = .portrait
        case .landscapeLeft, .landscapeRight:
            let currentOrientation = UIDeviceOrientation.init(rawValue: UIApplication.shared.statusBarOrientation.rawValue)!
            
            config = configHorizontal
            fullScreenBtn.setImage(config.bottom.fullScreenBackImg, for: .normal)
            
            if currentOrientation == .portrait {
                rootView.addSubview(self)
                snp.remakeConstraints({ (maker) in
                    maker.width.equalTo(UIScreen.main.bounds.height)
                    maker.height.equalTo(UIScreen.main.bounds.width)
                    maker.center.equalTo(UIApplication.shared.keyWindow!)
                })
            }
            
            self.transform = .identity
            
            UIView.animate(withDuration: 0.25, animations: {
                self.transform = CGAffineTransform(rotationAngle: .pi * 0.5 * (orientation == .landscapeLeft ? 1 : -1))
                self.layoutIfNeeded()
            })
            
            UIApplication.shared.statusBarOrientation = UIInterfaceOrientation(rawValue: orientation.rawValue)!
        default: break
        }
        DispatchQueue.main.async {
            self.controller?.setNeedsStatusBarAppearanceUpdate()
        }
        showControlLaterHide()
    }
    
    // MARK: - 控制层的显示隐藏
    private func showControlLaterHide() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideControl), object: nil)
        UIView.animate(withDuration: config.animateDuration, animations: {
            self.showStatusBar()
            self.topView.alpha = 1
            self.bottomView.alpha = 1
            }) { (_) in
                self.isControlShowing = true
                self.hideControlLater()
        }
    }
    
    private func showControl() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideControl), object: nil)
        UIView.animate(withDuration: config.animateDuration, animations: {
            self.showStatusBar()
            self.topView.alpha = 1
            self.bottomView.alpha = 1
        }) { (_) in
            self.isControlShowing = true
        }
    }
    
    /// 隐藏控制条
    @objc private func hideControl() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideControl), object: nil)
        UIView.animate(withDuration: config.animateDuration, animations: {
            self.hideStatusBar()
            self.topView.alpha = 0
            self.bottomView.alpha = 0
        }) { (_) in
            self.isControlShowing = false
        }
    }
    
    /// 稍后隐藏控制条
    private func hideControlLater() {
        perform(#selector(hideControl), with: nil, afterDelay: config.autoHideControlDuration)
    }
    
    /// 显示状态栏
    private func showStatusBar() {
        switch config.statusBarShowMode {
        case .alwaysShow:
            config.statusBarHidden = false
        case .alwaysHide:
            config.statusBarHidden = true
        case .showHide:
            config.statusBarHidden = false
        }
        controller?.setNeedsStatusBarAppearanceUpdate()
    }
    
    /// 隐藏状态栏
    private func hideStatusBar() {
        switch config.statusBarShowMode {
        case .alwaysShow:
            config.statusBarHidden = false
        case .alwaysHide:
            config.statusBarHidden = true
        case .showHide:
            config.statusBarHidden = true
        }
        controller?.setNeedsStatusBarAppearanceUpdate()
    }
    
    /// 转换时间
    private func transform(time: Int) -> String {
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
    private func beginPanHorizontal(location: CGPoint) {
        if config.quickProgressControlEnabled == false || validResource == false {
            return
        }
        guard let player = player, let playerItem = player.currentPlayerItem else { return }
        
        showControlLaterHide()
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideControl), object: nil)
        
        if player.isPaused {
            pausedForPanGesture = false
        } else {
            pausedForPanGesture = true
            player.pauseByUser()
        }
        
        self.totalTime = CGFloat(CMTimeGetSeconds(playerItem.duration))
        self.panStartTime = CGFloat(CMTimeGetSeconds(playerItem.currentTime()))
        UIView.animate(withDuration: 0.25, animations: {
            self.panPlayingStateView.alpha = 1
        })
    }
    
    
    /// 处理横向手势
    private func panHorizontal(location: CGPoint) {
        if config.quickProgressControlEnabled == false || validResource == false {
            return
        }
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
            panPlayingStateImgView.image = config.center.forwardImage
        } else {
            panPlayingStateImgView.image = config.center.backImage
        }
        
        panPlayingStateTimeLabel.text = transform(time: time) + " / " + transform(time: Int(self.totalTime))
        
        player?.seekTo(time: Float(time))
    }
    
    
    /// 横向手势结束
    private func endHorizontal() {
        if config.quickProgressControlEnabled == false || validResource == false {
            return
        }
        if pausedForPanGesture {
            play_pause()
        }
        
        hideControlLater()
        
        UIView.animate(withDuration: config.animateDuration, animations: {
            self.panPlayingStateView.alpha = 0
        })
    }

    
    // MARK: - 滑动控制音量/亮度
    
    /// 开始纵向手势
    private func beginPanVertical(location: CGPoint) {
        panVolume = location.x < bounds.midX
        if panVolume {
            if config.volumeControlEnabled {
                startVolumeValue = volumeSlider.value
            }
        } else {
            if config.brightnessControlEnabled {
                startBrightnessValue = UIScreen.main.brightness
            }
        }
    }
    
    /// 处理纵向手势
    private func panVertical(location: CGPoint) {
        let offsetY = panStartLocation.y - location.y
        let offsetProgress = offsetY / bounds.height
        
        if panVolume {
            if config.volumeControlEnabled {
                var newValue = startVolumeValue + Float(offsetProgress)
                newValue = max(newValue, 0)
                newValue = min(newValue, 1)
                volumeSlider.value = newValue
            }
        } else {
            if config.brightnessControlEnabled {
                var newValue = startBrightnessValue + offsetProgress
                newValue = max(newValue, 0)
                newValue = min(newValue, 1)
                
                UIScreen.main.brightness = newValue
            }
        }
    }
}

// MARK: - 功能方法
extension ZZPlayerView {
    func reset() {
        removeFromSuperview()
        player?.pausedByOtherReasons()
        self.playerItemResource = nil
    }
    
    // 返回
    @objc func back() {
        switch orientationMode {
        case .any:
            if isFullScreen {
                fullscreen()
            } else {
                backAction?()
            }
        case .portrait:
            backAction?()
        case .landscapeLeft, .landscapeRight:
            UIApplication.shared.statusBarOrientation = .portrait
            backAction?()
        }
        
        print(#function)
    }
    
    func play() {
        guard let player = player else { return }
        playPauseBtn.setImage(config.bottom.playPausePauseImg, for: .normal)
        player.play()
    }
    
    func pause() {
        guard let player = player else { return }
        playPauseBtn.setImage(config.bottom.playPausePlayImg, for: .normal)
        player.pauseByUser()
    }
    
    func pauseInCell() {
        reset()
        removeScrollViewObserver()
    }
    
    /// 暂停、播放
    @objc func play_pause() {
        guard let player = player else { return }
        showControlLaterHide()
        if !player.isPaused {
            pause()
        } else {
            play()
            hideControlLater()
        }
    }
    
    /// 下一首
    @objc func next_piece() {
        guard let playerItemResources = playerItemResources,
            playerItemResources.count > 1 else { return }
        
        guard let index = playerItemResources.firstIndex(where: { (item) -> Bool in
            return item.isEqual(playerItemResource)
        }) else {
            return
        }
        
        if index < playerItemResources.count - 1 {
            self.playerItemResource = playerItemResources[index + 1]
        }
    }
    
    
    /// 全屏
    @objc func fullscreen() {
        switch orientationMode {
        case .portrait:
            toOrientation(.portrait)
        case .landscapeRight:
            toOrientation(.landscapeRight)
        case .landscapeLeft:
            toOrientation(.landscapeLeft)
        case .any:
            if let player = player, !player.isPaused {
                hideControlLater()
            }
            if isFullScreen {
                toOrientation(.portrait)
            } else {
                let orientation = UIDevice.current.orientation
                switch orientation {
                case .landscapeLeft:
                    toOrientation(.landscapeRight)
                default:
                    toOrientation(.landscapeLeft)
                }
            }
        }
        
        print(#function)
    }
    
    
    /// 处理进度
    @objc private func playProgress(sender: UISlider) {
        guard let player = player else { return }
        showControlLaterHide()
        player.seekTo(time: sender.value)
    }
    
    
    /// 进度结束
    @objc private func playProgressLeave(sender: UISlider) {
        hideControlLater()
    }
    
    
    /// 点击手势，用来控制控制条的显示隐藏
    @objc private func tapAction() {
        isControlShowing ? hideControl() : showControlLaterHide()
    }
    
    
    /// 滑动手势，用来控制音量、亮度、快进、快退
    @objc private func panAction(pan: UIPanGestureRecognizer) {
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


// MARK: - Cell 中播放
extension ZZPlayerView {
    func play(resource: ZZPlayerItemResource, inCell cell: UIView, withPlayerContainerTag tag: Int, playerStopReason: ZZCellPlayerStopReason = .cellRectEdgeLeaveScrollView) {
        playerInCell = cell
        playerContainerTag = tag
        playerPausedInCellReason = playerStopReason
        
        playerItemResource = resource
        
        guard let playerContainerView = cell.viewWithTag(tag) else { return }
        
        playerContainerView.addSubview(self)
        
        self.snp.remakeConstraints({ (maker) in
            maker.edges.equalToSuperview()
        })
        
        removeScrollViewObserver()
        playerScrollView = scrollView
        playerScrollView?.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
    }
    
    private var scrollView: UIScrollView? {
        var view = playerInCell?.superview
        while view != nil && (view is UITableView == false) && (view is UICollectionView == false) {
            view = view?.superview
        }
        return view as? UIScrollView
    }
    
    private func removeScrollViewObserver() {
        if playerScrollView != nil {
            playerScrollView?.removeObserver(self, forKeyPath: "contentOffset", context: nil)
            playerScrollView = nil
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let scrollView = object as? UIScrollView,
            let superView = scrollView.superview,
            let cell = playerInCell {
            
            let scrollFrame = scrollView.frame
            let cellFrame = cell.convert(cell.bounds, to: superView)
            
            let cellY = cellFrame.origin.y
            let cellMaxY = cellFrame.maxY
            
            let scrollY = scrollFrame.origin.y
            let scrollMaxY = scrollFrame.maxY
            
            switch playerPausedInCellReason {
            case .cellRectEdgeLeaveScrollView:
                if cellMaxY < scrollY || cellY > scrollMaxY {
                    pauseInCell()
                }
            case .cellRectNotInScrollView:
                if cellY < scrollY || cellMaxY > scrollMaxY {
                    pauseInCell()
                }
            }
        }
    }
}


// MARK: - UI
extension ZZPlayerView {
    private func setupUI() {
        backgroundColor = UIColor.black
        
        setTopView()
        
        setBottomView()

        setMidView()
    }
    
    private func setMidView() {
        setPanPlayingStateView()
        
        loadingView.hidesWhenStopped = true
        addSubview(loadingView)
        loadingView.snp.makeConstraints { (maker) in
            maker.center.equalTo(self)
        }
    }
    
    private func setPanPlayingStateView() {
        addSubview(panPlayingStateView)
        panPlayingStateView.alpha = 0
        panPlayingStateView.backgroundColor = UIColor(white: 0, alpha: 0.75)
        
        panPlayingStateView.isHidden = config.center.hidden
        
        panPlayingStateTimeLabel = UILabel()
        panPlayingStateTimeLabel.text = "0 / 0"
        panPlayingStateTimeLabel.textColor = config.center.timeColor
        panPlayingStateTimeLabel.font = config.center.timeFont
        panPlayingStateTimeLabel.textAlignment = .center
        
        panPlayingStateImgView = UIImageView(image: config.center.forwardImage)
        
        
        panPlayingStateView.addSubview(panPlayingStateImgView)
        panPlayingStateView.addSubview(panPlayingStateTimeLabel)
        
        panPlayingStateView.snp.makeConstraints { (maker) in
            maker.centerX.equalTo(self)
            maker.centerY.equalTo(self).multipliedBy(0.8)
            maker.width.equalTo(config.center.width)
        }
        
        panPlayingStateImgView.snp.makeConstraints { (maker) in
            maker.top.equalTo(config.center.iconTopInset)
            maker.centerX.equalTo(panPlayingStateView)
            maker.size.equalTo(config.center.iconSize)
        }
        
        panPlayingStateTimeLabel.snp.makeConstraints { (maker) in
            maker.top.equalTo(panPlayingStateImgView.snp.bottom).offset(config.center.timeTopInset)
            maker.centerX.width.equalTo(panPlayingStateView)
            maker.bottom.equalTo(panPlayingStateView).offset(-config.center.timeBottomInset)
        }
    }
    
    private func setBottomView() {
        bottomView.backgroundColor = UIColor.clear
        bottomView.isHidden = config.bottom.hidden
        addSubview(bottomView)
        
        bottomView.isHidden = config.bottom.hidden
        
        bottomView.addSubview(bottomBackgroundView)
        switch config.bottom.background {
        case let .gradientLayer(c1, c2):
            bottomGradientLayer = addGradientLayer(toView: bottomView, colors: [c1.cgColor, c2.cgColor])
        case let .image(img):
            bottomBackgroundView.image = img
        }
        
        playPauseBtn = UIButton()
        playPauseBtn.setImage(config.bottom.playPause.image, for: .normal)
        
        nextBtn = UIButton()
        nextBtn.setImage(config.bottom.next.image, for: .normal)
        nextBtn.isHidden = config.bottom.hideNext
        
        fullScreenBtn = UIButton()
        fullScreenBtn.setImage(config.bottom.fullScreen.image, for: .normal)
        
        
        startTimeLabel = UILabel()
        startTimeLabel.textAlignment = .right
        startTimeLabel.text = "00:00"
        startTimeLabel.textColor = config.bottom.startTime.color
        startTimeLabel.font = config.bottom.startTime.font
        
        totalTimeLabel = UILabel()
        totalTimeLabel.text = "00:00"
        totalTimeLabel.textColor = config.bottom.totalTime.color
        totalTimeLabel.font = config.bottom.totalTime.font
        
        sliderView.setThumbImage(config.bottom.slider.thumbImage, for: .normal)
        sliderView.minimumTrackTintColor = config.bottom.slider.minimumTrackTintColor
        sliderView.maximumTrackTintColor = config.bottom.slider.maximumTrackTintColor
        sliderView.backgroundColor = UIColor.clear
        
        progressView.trackTintColor = config.bottom.progressView.trackTintColor
        progressView.progressTintColor = config.bottom.progressView.progressTintColor
        
        bottomView.addSubview(startTimeLabel)
        bottomView.addSubview(totalTimeLabel)
        bottomView.addSubview(playPauseBtn)
        bottomView.addSubview(fullScreenBtn)
        bottomView.addSubview(nextBtn)
        bottomView.addSubview(progressView)
        bottomView.addSubview(sliderView)
        
        playPauseBtn.addTarget(self, action: #selector(play_pause), for: .touchUpInside)
        nextBtn.addTarget(self, action: #selector(next_piece), for: .touchUpInside)
        fullScreenBtn.addTarget(self, action: #selector(fullscreen), for: .touchUpInside)
        sliderView.addTarget(self, action: #selector(playProgress), for: .valueChanged)
        sliderView.addTarget(self, action: #selector(playProgressLeave), for: [.touchUpOutside, .touchUpInside, .touchCancel])
        
        bottomView.addGestureRecognizer(UITapGestureRecognizer(target: nil, action: nil))
        
        bottomView.snp.makeConstraints { (maker) in
            maker.bottom.left.right.equalTo(self)
            maker.height.equalTo(config.bottom.height)
        }
        
        bottomBackgroundView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        
        playPauseBtn.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(bottomView).offset(config.bottom.playPause.offsetY)
            maker.left.equalTo(config.bottom.playPause.leftPadding)
            maker.size.equalTo(config.bottom.playPause.size)
        }
        
        if config.bottom.hideNext {
            startTimeLabel.snp.makeConstraints { (maker) in
                maker.centerY.equalTo(bottomView).offset(config.bottom.startTime.offsetY)
                maker.width.equalTo(timeWidth(font: config.bottom.startTime.font))
                maker.left.equalTo(playPauseBtn.snp.right).offset(config.bottom.startTime.leftPadding)
            }
        } else {
            nextBtn.snp.makeConstraints { (maker) in
                maker.centerY.equalTo(bottomView).offset(config.bottom.next.offsetY)
                maker.left.equalTo(playPauseBtn.snp.right).offset(config.bottom.next.leftPadding)
                maker.size.equalTo(config.bottom.next.size)
            }
            
            startTimeLabel.snp.makeConstraints { (maker) in
                maker.centerY.equalTo(bottomView).offset(config.bottom.startTime.offsetY)
                maker.width.equalTo(timeWidth(font: config.bottom.startTime.font))
                maker.left.equalTo(playPauseBtn.snp.right).offset(config.bottom.startTime.leftPadding + config.bottom.next.leftPadding + config.bottom.next.size.width)
            }
        }
        
        
        sliderView.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(bottomView).offset(config.bottom.slider.offsetY)
            maker.left.equalTo(startTimeLabel.snp.right).offset(config.bottom.slider.leftPadding)
            maker.right.equalTo(totalTimeLabel.snp.left).offset(-config.bottom.slider.rightPadding)
        }
        
        progressView.snp.makeConstraints { (maker) in
            maker.height.equalTo(config.bottom.progressView.height)
            maker.width.centerX.equalTo(sliderView)
            maker.centerY.equalTo(sliderView).offset(0.5)
        }
        
        totalTimeLabel.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(bottomView).offset(config.bottom.totalTime.offsetY)
            maker.width.equalTo(timeWidth(font: config.bottom.totalTime.font))
            maker.right.equalTo(fullScreenBtn.snp.left).offset(-config.bottom.totalTime.rightPadding)
        }
        
        fullScreenBtn.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(bottomView).offset(config.bottom.fullScreen.offsetY)
            maker.right.equalTo(-config.bottom.fullScreen.rightPadding)
            maker.size.equalTo(config.bottom.fullScreen.size)
        }
    }
    
    private func setTopView() {
        topView.backgroundColor = UIColor.clear
        topView.isHidden = config.top.hidden
        addSubview(topView)
        
        topView.addSubview(topBackgroundView)
        switch config.top.background {
        case let .gradientLayer(c1, c2):
            topGradientLayer = addGradientLayer(toView: topView, colors: [c1.cgColor, c2.cgColor])
        case let .image(img):
            topBackgroundView.image = img
        }
        
        backBtn = UIButton()
        backBtn.setImage(config.top.icon.image, for: .normal)
        
        titleLabel = UILabel()
        titleLabel.textColor = config.top.title.color
        titleLabel.font = config.top.title.font
        
        
        
        topView.addSubview(backBtn)
        topView.addSubview(titleLabel)
        
        backBtn.addTarget(self, action: #selector(back), for: .touchUpInside)
        
        topView.addGestureRecognizer(UITapGestureRecognizer(target: nil, action: nil))
        
        topView.snp.makeConstraints { (maker) in
            maker.top.left.right.equalTo(self)
            maker.height.equalTo(config.top.height)
        }
        
        topBackgroundView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        
        backBtn.snp.makeConstraints { (maker) in
            maker.left.equalTo(config.top.icon.leftPadding)
            maker.centerY.equalTo(topView).offset(config.top.icon.offsetY)
            maker.size.equalTo(config.top.icon.size)
        }
        
        titleLabel.snp.makeConstraints { (maker) in
            maker.left.equalTo(backBtn.snp.right).offset(config.top.title.leftPadding)
            maker.centerY.equalTo(topView).offset(config.top.title.offsetY)
            maker.right.equalTo(-config.top.title.rightPadding)
        }
    }
    
    
    // MARK: - 更新约束
    private func updateTop() {
        topView.isHidden = config.top.hidden
        
        switch config.top.background {
        case let .gradientLayer(c1, c2):
            topBackgroundView.isHidden = true
            if topGradientLayer == nil {
                topGradientLayer = addGradientLayer(toView: topView, colors: [c1.cgColor, c2.cgColor])
            } else {
                topGradientLayer.isHidden = false
                topGradientLayer.colors = [c1.cgColor, c2.cgColor]
            }
        case let .image(img):
            topGradientLayer?.isHidden = true
            topBackgroundView.isHidden = false
            topBackgroundView.image = img
        }
        
        backBtn.setImage(config.top.icon.image, for: .normal)
        titleLabel.textColor = config.top.title.color
        titleLabel.font = config.top.title.font
        
        topView.snp.updateConstraints { (maker) in
            maker.height.equalTo(config.top.height)
        }
        
        backBtn.snp.updateConstraints { (maker) in
            maker.left.equalTo(config.top.icon.leftPadding)
            maker.centerY.equalTo(topView).offset(config.top.icon.offsetY)
            maker.size.equalTo(config.top.icon.size)
        }
        
        titleLabel.snp.updateConstraints { (maker) in
            maker.left.equalTo(backBtn.snp.right).offset(config.top.title.leftPadding)
            maker.centerY.equalTo(topView).offset(config.top.title.offsetY)
            maker.right.equalTo(-config.top.title.rightPadding)
        }
    }
    
    private func updateMid() {
        
        panPlayingStateView.isHidden = config.center.hidden
        
        panPlayingStateTimeLabel.font = config.center.timeFont
        panPlayingStateTimeLabel.textColor = config.center.timeColor
        
        panPlayingStateView.snp.updateConstraints { (maker) in
            maker.width.equalTo(config.center.width)
        }
        
        panPlayingStateImgView.snp.updateConstraints { (maker) in
            maker.top.equalTo(config.center.iconTopInset)
            maker.size.equalTo(config.center.iconSize)
        }
        
        panPlayingStateTimeLabel.snp.updateConstraints { (maker) in
            maker.top.equalTo(panPlayingStateImgView.snp.bottom).offset(config.center.timeTopInset)
            maker.bottom.equalTo(panPlayingStateView).offset(-config.center.timeBottomInset)
        }

    }
    
    private func updateBottom() {
        bottomView.isHidden = config.bottom.hidden
        
        switch config.bottom.background {
        case let .gradientLayer(c1, c2):
            bottomBackgroundView.isHidden = true
            if bottomGradientLayer == nil {
                bottomGradientLayer = addGradientLayer(toView: bottomView, colors: [c1.cgColor, c2.cgColor])
            } else {
                bottomGradientLayer.isHidden = false
                bottomGradientLayer.colors = [c1.cgColor, c2.cgColor]
            }
        case let .image(img):
            bottomGradientLayer?.isHidden = true
            bottomBackgroundView.isHidden = false
            bottomBackgroundView.image = img
        }
        
        if let player = player {
            if player.isPaused {
                playPauseBtn.setImage(config.bottom.playPausePlayImg, for: .normal)
            } else {
                playPauseBtn.setImage(config.bottom.playPausePauseImg, for: .normal)
            }
        }
        
        nextBtn.setImage(config.bottom.next.image, for: .normal)
        nextBtn.isHidden = config.bottom.hideNext

        startTimeLabel.textColor = config.bottom.startTime.color
        startTimeLabel.font = config.bottom.startTime.font
        
        totalTimeLabel.textColor = config.bottom.totalTime.color
        totalTimeLabel.font = config.bottom.totalTime.font
        
        sliderView.setThumbImage(config.bottom.slider.thumbImage, for: .normal)
        sliderView.minimumTrackTintColor = config.bottom.slider.minimumTrackTintColor
        sliderView.maximumTrackTintColor = config.bottom.slider.maximumTrackTintColor
        
        progressView.trackTintColor = config.bottom.progressView.trackTintColor
        progressView.progressTintColor = config.bottom.progressView.progressTintColor

        bottomView.snp.updateConstraints { (maker) in
            maker.height.equalTo(config.bottom.height)
        }
        
        playPauseBtn.snp.updateConstraints { (maker) in
            maker.centerY.equalTo(bottomView).offset(config.bottom.playPause.offsetY)
            maker.left.equalTo(config.bottom.playPause.leftPadding)
            maker.size.equalTo(config.bottom.playPause.size)
        }
        
        if config.bottom.hideNext {
            startTimeLabel.snp.remakeConstraints { (maker) in
                maker.centerY.equalTo(bottomView).offset(config.bottom.startTime.offsetY)
                maker.width.equalTo(timeWidth(font: config.bottom.startTime.font))
                maker.left.equalTo(playPauseBtn.snp.right).offset(config.bottom.startTime.leftPadding)
            }
        } else {
            nextBtn.snp.remakeConstraints { (maker) in
                maker.centerY.equalTo(bottomView).offset(config.bottom.next.offsetY)
                maker.left.equalTo(playPauseBtn.snp.right).offset(config.bottom.next.leftPadding)
                maker.size.equalTo(config.bottom.next.size)
            }
            
            startTimeLabel.snp.remakeConstraints { (maker) in
                maker.centerY.equalTo(bottomView).offset(config.bottom.startTime.offsetY)
                maker.width.equalTo(timeWidth(font: config.bottom.startTime.font))
                maker.left.equalTo(playPauseBtn.snp.right).offset(config.bottom.startTime.leftPadding + config.bottom.next.leftPadding + config.bottom.next.size.width)
            }
        }
        
        sliderView.snp.updateConstraints { (maker) in
            maker.centerY.equalTo(bottomView).offset(config.bottom.slider.offsetY)
            maker.left.equalTo(startTimeLabel.snp.right).offset(config.bottom.slider.leftPadding)
            maker.right.equalTo(totalTimeLabel.snp.left).offset(-config.bottom.slider.rightPadding)
        }
        
        progressView.snp.updateConstraints { (maker) in
            maker.height.equalTo(config.bottom.progressView.height)
            maker.width.centerX.equalTo(sliderView)
            maker.centerY.equalTo(sliderView).offset(0.5)
        }
        
        switch orientationMode {
        case .any:
            fullScreenBtn.isHidden = false
            totalTimeLabel.snp.remakeConstraints { (maker) in
                maker.centerY.equalTo(bottomView).offset(config.bottom.totalTime.offsetY)
                maker.width.equalTo(timeWidth(font: config.bottom.totalTime.font))
                maker.right.equalTo(fullScreenBtn.snp.left).offset(-config.bottom.totalTime.rightPadding)
            }
            
            fullScreenBtn.snp.remakeConstraints { (maker) in
                maker.centerY.equalTo(bottomView).offset(config.bottom.fullScreen.offsetY)
                maker.right.equalTo(-config.bottom.fullScreen.rightPadding)
                maker.size.equalTo(config.bottom.fullScreen.size)
            }
        default:
            fullScreenBtn.isHidden = true
            
            totalTimeLabel.snp.remakeConstraints { (maker) in
                maker.centerY.equalTo(bottomView).offset(config.bottom.totalTime.offsetY)
                maker.width.equalTo(timeWidth(font: config.bottom.totalTime.font))
                maker.right.equalTo(-config.bottom.totalTime.rightPadding)
            }
            
            fullScreenBtn.snp.remakeConstraints { (maker) in
                maker.centerY.equalTo(bottomView).offset(config.bottom.fullScreen.offsetY)
                maker.right.equalTo(-config.bottom.fullScreen.rightPadding)
                maker.size.equalTo(config.bottom.fullScreen.size)
            }
        }
        
    }
    
    /// 添加渐变层
    private func addGradientLayer(toView: UIView, colors: [Any]?) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        toView.layer.addSublayer(gradientLayer)
        return gradientLayer
    }
    
    private func timeWidth(font: UIFont) -> CGFloat {
        return ceil(("00:00:00" as NSString).boundingRect(with: CGSize(width: Int.max, height: Int.max), options: [], attributes: [NSAttributedString.Key.font: font], context: nil).size.width)
    }
    
    /// 布局渐变层
    override func layoutSubviews() {
        super.layoutSubviews()
        
        topGradientLayer?.frame = topView.bounds
        bottomGradientLayer?.frame = bottomView.bounds
    }
}
