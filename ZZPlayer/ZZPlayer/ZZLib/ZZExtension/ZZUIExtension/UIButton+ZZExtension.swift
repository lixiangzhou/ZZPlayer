//
//  UIButton+ZZExtension.swift
//  ZZSwiftTool
//
//  Created by lixiangzhou on 17/3/12.
//  Copyright © 2017年 lixiangzhou. All rights reserved.
//

import UIKit

public extension UIButton {
    
    /// 快速创建按钮
    ///
    /// - parameter title:                        title
    /// - parameter fontSize:                    字体大小
    /// - parameter titleColor:                   字体颜色
    /// - parameter imageName:                    图片名
    /// - parameter hilightedImageName:           高亮图片名
    /// - parameter selectedImageName:            选中图片名
    /// - parameter backgroundImageName:          背景图名
    /// - parameter hilightedBackgroundImageName: 高亮背景图名
    /// - parameter selectedBackgroundImageName:  选中背景图名
    /// - parameter backgroundColor:              背景色
    /// - parameter target:                       target
    /// - parameter action:                       action
    ///
    /// - returns: <#return value description#>
    convenience init(title: String? = nil,
                     fontSize: CGFloat = 12,
                     titleColor: UIColor = UIColor.darkText,
                     imageName: String? = nil,
                     hilightedImageName: String? = nil,
                     selectedImageName: String? = nil,
                     backgroundImageName: String? = nil,
                     hilightedBackgroundImageName: String? = nil,
                     selectedBackgroundImageName: String? = nil,
                     backgroundColor: UIColor? = nil,
                     target: Any? = nil,
                     action: Selector? = nil) {
        
        self.init(type: .custom)
        
        setTitle(title, for: .normal)
        
        titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        setTitleColor(titleColor, for: .normal)
        self.backgroundColor = backgroundColor
        
        // 图片
        if let imageName = imageName, let image = UIImage(named: imageName) {
            setImage(image, for: .normal)
            
            if let hImage = UIImage(named: imageName + "_highlighted") {
                setImage(hImage, for: .highlighted)
            }
            
            if let sImage = UIImage(named: imageName + "_selected") {
                setImage(sImage, for: .selected)
            }
        }
        // 高亮图片
        if let hilightedImageName = hilightedImageName, let hilightedImage = UIImage(named: hilightedImageName) {
            setImage(hilightedImage, for: .highlighted)
        }
        // 选中图片
        if let selectedImageName = selectedImageName, let selectedImage = UIImage(named: selectedImageName) {
            setImage(selectedImage, for: .selected)
        }
        
        // 背景图片
        if let backgroundImageName = backgroundImageName, let backgroundImage = UIImage(named: backgroundImageName) {
            setBackgroundImage(backgroundImage, for: .normal)
            
            if let hbImage = UIImage(named: backgroundImageName + "_highlighted") {
                setBackgroundImage(hbImage, for: .highlighted)
            }
            
            if let sbImage = UIImage(named: backgroundImageName + "_selected") {
                setBackgroundImage(sbImage, for: .selected)
            }
        }
        
        // 高亮背景图片
        if let hilightedBackgroundImageName = hilightedBackgroundImageName, let hilightedBackgroundImage = UIImage(named: hilightedBackgroundImageName) {
            setBackgroundImage(hilightedBackgroundImage, for: .highlighted)
        }
        
        // 选中背景图片
        if let selectedBackgroundImageName = selectedBackgroundImageName, let selectedBackgroundImage = UIImage(named: selectedBackgroundImageName) {
            setBackgroundImage(selectedBackgroundImage, for: .selected)
        }
        
        // 添加事件
        if let target = target, let action = action {
            addTarget(target, action: action, for: .touchUpInside)
        }
        
        sizeToFit()
    }
}
