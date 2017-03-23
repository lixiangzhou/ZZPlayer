//
//  ZZButton.swift
//  ZZSwiftTool
//
//  Created by lixiangzhou on 17/3/12.
//  Copyright © 2017年 lixiangzhou. All rights reserved.
//

import UIKit

/// 可以调整图片位置的按钮
open class ZZImagePositionButton: UIButton {
    
    enum ZZImagePosition {
        case left, right
        case none // 默认，不调整左中右的间距
    }
    
    
    private var leftPadding: CGFloat = 0
    private var middlePadding: CGFloat = 0
    private var rightPadding: CGFloat = 0
    private var imgPosition: ZZImagePosition = .none
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        if imgPosition == .left {
            self.imageView?.zz_x = leftPadding
            self.titleLabel?.zz_x = (self.imageView?.zz_width ?? 0) + leftPadding + middlePadding
            self.titleLabel?.zz_width = self.zz_width - (self.imageView?.zz_width ?? 0) - leftPadding - middlePadding - rightPadding
            
        } else if imgPosition == .right {
            self.titleLabel?.zz_x = leftPadding
            let imgX = self.zz_width - (self.imageView?.zz_width ?? 0) - rightPadding
            self.imageView?.zz_x = imgX
            self.titleLabel?.zz_width = imgX - leftPadding - middlePadding
            
            
        }
        
    }
    
    convenience init(title: String? = nil,
                     titleSize: CGFloat = 12,
                     titleColor: UIColor = UIColor.darkText,
                     imageName: String? = nil,
                     hilightedImageName: String? = nil,
                     selectedImageName: String? = nil,
                     backgroundImageName: String? = nil,
                     hilightedBackgroundImageName: String? = nil,
                     selectedBackgroundImageName: String? = nil,
                     backgroundColor: UIColor? = nil,
                     target: Any? = nil,
                     action: Selector? = nil,
                     imgPosition: ZZImagePosition = .none,
                     leftPadding: CGFloat = 0,
                     middlePadding: CGFloat = 0,
                     rightPadding: CGFloat = 0) {
        
        self.init(title: title,
                  titleSize: titleSize,
                  titleColor: titleColor,
                  imageName: imageName,
                  hilightedImageName: hilightedImageName,
                  selectedImageName: selectedImageName,
                  backgroundImageName: backgroundImageName,
                  hilightedBackgroundImageName: hilightedBackgroundImageName,
                  selectedBackgroundImageName: selectedBackgroundImageName,
                  backgroundColor: backgroundColor,
                  target: target,
                  action: action)
        
        self.imgPosition = imgPosition
        self.leftPadding = leftPadding
        self.rightPadding = rightPadding
        self.middlePadding = middlePadding
        
        if imgPosition != .none {
            self.zz_width += leftPadding + rightPadding + middlePadding
        }
    }
}
