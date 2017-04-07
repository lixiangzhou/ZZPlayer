//
//  UILabel+ZZExtension.swift
//  ZZSwiftTool
//
//  Created by lixiangzhou on 17/3/12.
//  Copyright © 2017年 lixiangzhou. All rights reserved.
//

import UIKit


public extension UILabel {
    
    /// 快速穿件Label
    ///
    /// - parameter text:      text
    /// - parameter fontSize:  字体大小
    /// - parameter textColor: 字体颜色
    ///
    /// - returns: Label
    convenience init(text: String = "", fontSize: CGFloat = 12, textColor: UIColor? = UIColor.darkGray, textAlignment: NSTextAlignment = .left) {
        self.init()
        
        font = UIFont.systemFont(ofSize: fontSize)
        self.textColor = textColor
        self.text = text
        self.textAlignment = textAlignment
        
        sizeToFit()
    }
}
