//
//  CGRect+ZZExtension.swift
//  ZZSwiftTool
//
//  Created by lixiangzhou on 2017/3/10.
//  Copyright © 2017年 lixiangzhou. All rights reserved.
//

import UIKit

public extension CGSize {
    
    /// CGSize 乘法
    ///
    /// - parameter size:   参与计算的CGSize
    /// - parameter factor: 乘数因子
    ///
    /// - returns: 乘法计算结果
    static func * (size: CGSize, factor: CGFloat) -> CGSize {
        return CGSize(width: size.width * factor, height: size.height * factor)
    }
    
    /// CGSize 除法
    ///
    /// - parameter size:   参与计算的CGSize
    /// - parameter factor: 除数因子
    ///
    /// - returns: 除法计算结果
    static func / (size: CGSize, factor: CGFloat) -> CGSize {
        return CGSize(width: size.width / factor, height: size.height / factor)
    }
    
    /// CGSize 加法
    ///
    /// - parameter size:   参与计算的CGSize
    /// - parameter factor: 加数因子
    ///
    /// - returns: 加法计算结果
    static func + (size: CGSize, factor: CGFloat) -> CGSize {
        return CGSize(width: size.width + factor, height: size.height + factor)
    }
    
    /// CGSize 减法
    ///
    /// - parameter size:   参与计算的CGSize
    /// - parameter factor: 减数因子
    ///
    /// - returns: 减法计算结果
    static func - (size: CGSize, factor: CGFloat) -> CGSize {
        return CGSize(width: size.width - factor, height: size.height - factor)
    }
}


public extension CGRect {
    var zz_x: CGFloat {
        return origin.x
    }
    
    var zz_y: CGFloat {
        return origin.y
    }
}

