//
//  UIColor+ZZExtension.swift
//  ZZSwiftTool
//
//  Created by lixiangzhou on 17/3/12.
//  Copyright © 2017年 lixiangzhou. All rights reserved.
//

import UIKit

public extension UIColor {
    
    /// 快速创建颜色
    ///
    /// - parameter red:   红
    /// - parameter green: 绿
    /// - parameter blue:  蓝
    /// - parameter alpha: 透明度
    convenience init(red: Int, green: Int, blue: Int, alphaValue: CGFloat = 1.0) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alphaValue)
    }
    
    /// 16进制rgb颜色值生成对应UIColor
    ///
    /// - parameter stringHexValue: 16进制颜色值, 可包含前缀0x,#，颜色值可以是 RGB  RGBA  RRGGBB  RRGGBBAA
    convenience init?(stringHexValue: String) {
        
        var hexValue = stringHexValue.zz_trim.uppercased()
        if hexValue.hasPrefix("#") {
            hexValue = hexValue.substring(from: hexValue.index(hexValue.startIndex, offsetBy: 1))
        } else if hexValue.hasPrefix("0X") {
            hexValue = hexValue.substring(from: hexValue.index(hexValue.startIndex, offsetBy: 2))
        }
        let len = hexValue.characters.count
        // RGB  RGBA    RRGGBB  RRGGBBAA
        if len != 3 && len != 4 && len != 6 && len != 8 {
            return nil
        }
        
        var resultHexValue: UInt32 = 0
        guard Scanner(string: hexValue).scanHexInt32(&resultHexValue) else {
            return nil
        }
        
        var divisor: CGFloat = 255
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        if len == 3 {
            divisor = 15
            r = CGFloat((resultHexValue & 0xF00) >> 8) / divisor
            g = CGFloat((resultHexValue & 0x0F0) >> 4) / divisor
            b = CGFloat( resultHexValue & 0x00F) / divisor
            a = 1
        } else if len == 4 {
            divisor = 15
            r = CGFloat((resultHexValue & 0xF000) >> 12) / divisor
            g = CGFloat((resultHexValue & 0x0F00) >> 8) / divisor
            b = CGFloat((resultHexValue & 0x00F0) >> 4) / divisor
            a = CGFloat(resultHexValue & 0x000F) / divisor
        } else if len == 6 {
            r = CGFloat((resultHexValue & 0xFF0000) >> 16) / divisor
            g = CGFloat((resultHexValue & 0x00FF00) >> 8) / divisor
            b = CGFloat(resultHexValue & 0x0000FF) / divisor
            a = 1
        } else if len == 8 {
            r = CGFloat((resultHexValue & 0xFF000000) >> 24) / divisor
            g = CGFloat((resultHexValue & 0x00FF0000) >> 16) / divisor
            b = CGFloat((resultHexValue & 0x0000FF00) >> 8) / divisor
            a = CGFloat(resultHexValue & 0x000000FF) / divisor
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    
    /// 随机色
    static var zz_random: UIColor {
        let red = arc4random() % 256
        let green = arc4random() % 256
        let blue = arc4random() % 256
        
        return UIColor(red: Int(red), green: Int(green), blue: Int(blue))
    }
    
    
    /// 返回颜色的rgba值
    var rgbaValue: String? {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            let red = Int(r * 255)
            let green = Int(g * 255)
            let blue = Int(b * 255)
            let alpha = Int(a * 255)
            /* 进制转换
                String(value: T, radix: Int)    value的radix表现形式
                Int(String, radix: Int)     Int(value, radix:radix) value 是 radix 进制，转成10进制
             */
            let value = (red << 24) + (green << 16) + (blue << 8) + alpha
            return String(value, radix: 16)
        }
        
        return nil
    }
    
    var rgbValue: String? {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        
        if getRed(&r, green: &g, blue: &b, alpha: nil) {
            let red = Int(r * 255)
            let green = Int(g * 255)
            let blue = Int(b * 255)
            /* 进制转换
             String(value: T, radix: Int)    value的radix表现形式
             Int(String, radix: Int)     Int(value, radix:radix) value 是 radix 进制，转成10进制
             */
            let value = (red << 16) + (green << 8) + blue
            return String(value, radix: 16)
        }
        
        return nil
    }
    
    
    /// 返回颜色的rgba值
    var rgbaHexStringValue: (red: String, green: String, blue: String, alpha: String)? {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            let red = String(Int(r * 255), radix: 16)
            let green = String(Int(g * 255), radix: 16)
            let blue = String(Int(b * 255), radix: 16)
            let alpha = String(Int(a * 255), radix: 16)
            
            return (red: red, green: green, blue: blue, alpha: alpha)
        }
        
        return nil
    }
    
    
    /// 返回颜色的rgba值，0-255
    var rgbaIntValue: (red: Int, green: Int, blue: Int, alpha: Int)? {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            let red = Int(r * 255)
            let green = Int(g * 255)
            let blue = Int(b * 255)
            let alpha = Int(a * 255)
            
            return (red: red, green: green, blue: blue, alpha: alpha)
        }
        
        return nil
    }
}
