//
//  ZZPlayerViewConfig.swift
//  ZZPlayer
//
//  Created by lixiangzhou on 2017/8/24.
//  Copyright © 2017年 lixiangzhou. All rights reserved.
//

import UIKit

struct ZZPlayerViewTopConfig {
    
    var hidden = false
    var height: CGFloat = 40
    
    /// 背景
    var background = ZZPlayerViewTopConfigBackground.gradientLayer(UIColor(red: 0, green: 0, blue: 0, alpha: 0.9), UIColor.clear)
    
    /// 标题设置
    var title = ZZPlayerViewTopConfigLabel(font: UIFont.systemFont(ofSize: 14),
                                           color: .white,
                                           leftPadding: 5,
                                           rightPadding: 20,
                                           offsetY: 0)
    
    /// 左边图标设置
    var icon = ZZPlayerViewTopConfigButton(image: zz_bundleImage("zz_player_play_back_full"),
                                               leftPadding: 5,
                                               rightPadding: 20,
                                               size: CGSize(width: 30, height: 30),
                                               offsetY: 0)
}

struct ZZPlayerViewBottomConfig {
    var hidden = false
    var height: CGFloat = 30
    
    /// 背景
    var background = ZZPlayerViewTopConfigBackground.gradientLayer(UIColor.clear, UIColor(red: 0, green: 0, blue: 0, alpha: 0.9))
    
    /// 暂停、播放按钮设置
    var playPause = ZZPlayerViewTopConfigButton(image: zz_bundleImage("zz_player_play"),
                                                   leftPadding: 10,
                                                   rightPadding: 10,
                                                   size: CGSize(width: 25,
                                                                height: 25),
                                                   offsetY: 0)
    
    /// 播放图标
    var playPausePlayImg = zz_bundleImage("zz_player_play")
    
    /// 暂停图标
    var playPausePauseImg = zz_bundleImage("zz_player_pause")
 
    
    /// 下一首按钮设置
    var next = ZZPlayerViewTopConfigButton(image: zz_bundleImage("zz_player_skip_next"),
                                              leftPadding: 10,
                                              rightPadding: 0,
                                              size: CGSize(width: 25, height: 25),
                                              offsetY: 0)
    var hideNext = true
    
    /// 全屏按钮设置
    var fullScreen = ZZPlayerViewTopConfigButton(image:  zz_bundleImage("zz_player_fullscreen"),
                                                    leftPadding: 5,
                                                    rightPadding: 10,
                                                    size: CGSize(width: 25, height: 25),
                                                    offsetY: 0)
    
    var fullScreenImg = zz_bundleImage("zz_player_fullscreen")
    var fullScreenBackImg = zz_bundleImage("zz_player_shrinkscreen")
    
    /// 开始时间（实时时间）设置
    var startTime = ZZPlayerViewTopConfigLabel(font: UIFont.systemFont(ofSize: 12),
                                                    color: .white,
                                                    leftPadding: 0,
                                                    rightPadding: 5,
                                                    offsetY: 0)
    
    /// 总时间设置
    var totalTime = ZZPlayerViewTopConfigLabel(font: UIFont.systemFont(ofSize: 12),
                                                    color: .white,
                                                    leftPadding: 5,
                                                    rightPadding: 0,
                                                    offsetY: 0)
    
    /// 缓存进度设置
    var progressView = ZZPlayerViewTopConfigProgress(trackTintColor: UIColor(white: 1, alpha: 0.5),
                                                     progressTintColor: UIColor(white: 1, alpha: 0.7),
                                                     height: 2)
    
    /// 播放进度设置
    var slider = ZZPlayerViewTopConfigSlider(thumbImage: zz_bundleImage("zz_player_slider"),
                                             minimumTrackTintColor: UIColor(red: 45 / 255.0, green: 186 / 255.0, blue: 247 / 255.0, alpha: 1), maximumTrackTintColor: UIColor.clear, leftPadding: 5, rightPadding: 5, offsetY: 0)
}

struct ZZPlayerViewCenterConfig {
    var width: CGFloat = 100
    
    /// 时间设置
    var timeFont = UIFont.systemFont(ofSize: 12)
    var timeColor = UIColor.white
    var timeTopInset: CGFloat = 5
    var timeBottomInset: CGFloat = 5
    
    
    /// 快进、快退设置
    var iconTopInset: CGFloat = 5
    var iconSize = CGSize(width: zz_bundleImage("zz_player_quickback")!.size.width / zz_bundleImage("zz_player_quickback")!.size.height * 30,
                          height: 30)
    
    var forwardImage = zz_bundleImage("zz_player_quickforward")
    var backImage = zz_bundleImage("zz_player_quickback")
}

struct ZZPlayerViewConfig {
    var top = ZZPlayerViewTopConfig()
    var bottom = ZZPlayerViewBottomConfig()
    var center = ZZPlayerViewCenterConfig()
    
    
    /// 控制层显示时长设置
    var autoHideControlDuration: TimeInterval = 4
    var animateDuration: TimeInterval = 0.5
}

enum ZZPlayerViewTopConfigBackground {
    case image(UIImage)
    case gradientLayer(UIColor, UIColor)
}

struct ZZPlayerViewTopConfigLabel {
    var font = UIFont.systemFont(ofSize: 14)
    var color = UIColor.white
    var leftPadding: CGFloat = 5
    var rightPadding: CGFloat = 20
    var offsetY: CGFloat = 0
}

struct ZZPlayerViewTopConfigProgress {
    var trackTintColor = UIColor(white: 1, alpha: 0.5)
    var progressTintColor = UIColor(white: 1, alpha: 0.7)
    
    var height: CGFloat = 2
}

struct ZZPlayerViewTopConfigSlider {
    var thumbImage = zz_bundleImage("zz_player_slider")
    var minimumTrackTintColor = UIColor(red: 45 / 255.0, green: 186 / 255.0, blue: 247 / 255.0, alpha: 1)
    var maximumTrackTintColor = UIColor.clear
    
    var leftPadding: CGFloat = 5
    var rightPadding: CGFloat = 20
    var offsetY: CGFloat = 0
}

struct ZZPlayerViewTopConfigButton {
    var image = zz_bundleImage("zz_player_play_back_full")
    var leftPadding: CGFloat = 5
    var rightPadding: CGFloat = 20
    var size = CGSize(width: 30, height: 30)
    var offsetY: CGFloat = 0
}


func zz_bundleImage(_ imgName: String) -> UIImage? {
    return UIImage(named: zz_bundleImageName(imgName))
}

func zz_bundleImageName(_ imgName: String) -> String {
    return "ZZPlayer.bundle/" + imgName
}
