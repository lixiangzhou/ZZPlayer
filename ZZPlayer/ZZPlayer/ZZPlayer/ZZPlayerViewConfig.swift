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
    var leftIcon = ZZPlayerViewTopConfigButton(image:  zz_bundleImage("zz_player_play_back_full"),
                                               leftPadding: 5,
                                               rightPadding: 20,
                                               size: CGSize(width: 30, height: 30),
                                               offsetY: 0)
}

struct ZZPlayerViewBottomConfig {
    var hidden = false
    var height: CGFloat = 30
    
    var background = ZZPlayerViewTopConfigBackground.gradientLayer(UIColor.clear, UIColor(red: 0, green: 0, blue: 0, alpha: 0.9))
    
    var playPauseBtn = ZZPlayerViewTopConfigButton(image: zz_bundleImage("zz_player_play"),
                                                   leftPadding: 10,
                                                   rightPadding: 10,
                                                   size: CGSize(width: 25,
                                                                height: 25),
                                                   offsetY: 0)
    var playPauseBtnPlayImg = zz_bundleImage("zz_player_play")
 
    var nextBtn = ZZPlayerViewTopConfigButton(image: zz_bundleImage("zz_player_skip_next"),
                                              leftPadding: 10,
                                              rightPadding: 0,
                                              size: CGSize(width: 25, height: 25),
                                              offsetY: 0)
    
    var fullScreenBtn = ZZPlayerViewTopConfigButton(image:  zz_bundleImage("zz_player_fullscreen"),
                                                    leftPadding: 5,
                                                    rightPadding: 10,
                                                    size: CGSize(width: 25, height: 25),
                                                    offsetY: 0)
    
    var startTimeLabel = ZZPlayerViewTopConfigLabel(font: UIFont.systemFont(ofSize: 12),
                                                    color: .white,
                                                    leftPadding: 0,
                                                    rightPadding: 5,
                                                    offsetY: 0)
    
    var totalTimeLabel = ZZPlayerViewTopConfigLabel(font: UIFont.systemFont(ofSize: 12),
                                                    color: .white,
                                                    leftPadding: 5,
                                                    rightPadding: 0,
                                                    offsetY: 0)
    
    var progressView = ZZPlayerViewTopConfigProgress(trackTintColor: UIColor(white: 1, alpha: 0.5),
                                                     progressTintColor: UIColor(white: 1, alpha: 0.7),
                                                     height: 2)
    
    var slider = ZZPlayerViewTopConfigSlider(thumbImage: zz_bundleImage("zz_player_slider"),
                                             minimumTrackTintColor: UIColor(red: 45 / 255.0, green: 186 / 255.0, blue: 247 / 255.0, alpha: 1), maximumTrackTintColor: UIColor.clear, leftPadding: 5, rightPadding: 0, offsetY: 0)
}

struct ZZPlayerViewConfig {
    let top = ZZPlayerViewTopConfig()
    let bottom = ZZPlayerViewBottomConfig()
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
