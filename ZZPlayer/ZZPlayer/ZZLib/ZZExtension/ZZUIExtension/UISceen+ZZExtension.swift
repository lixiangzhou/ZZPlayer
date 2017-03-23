//
//  UISceen+ZZExtension.swift
//  ZZSwiftTool
//
//  Created by lixiangzhou on 2017/3/10.
//  Copyright © 2017年 lixiangzhou. All rights reserved.
//

import UIKit

public let zz_screen = UIScreen.main

public extension UIScreen {
    /// 屏幕高度
    static var zz_height: CGFloat {
        return zz_screen.bounds.height
    }
    
    /// 屏幕宽度
    static var zz_width: CGFloat {
        return zz_screen.bounds.width
    }
    
    /// 设备的 scale
    static var zz_scale: CGFloat {
        return zz_screen.scale
    }
    
    /// 屏幕亮度
    static var zz_brightness: CGFloat {
        set {
            zz_screen.brightness = newValue
        }
        
        get {
            return zz_screen.brightness
        }
    }
}
