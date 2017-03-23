//
//  String+ZZExtension.swift
//  ZZSwiftTool
//
//  Created by lixiangzhou on 2017/3/10.
//  Copyright © 2017年 lixiangzhou. All rights reserved.
//

import UIKit

public extension String {
    /// 去掉空白字符串
    var zz_trim: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

public extension String {
    
    /// 根据格式获取字符串的Date对象
    ///
    /// 常用格式：
    /// G:          公元时代，例如AD公元
    ///
    /// yy:         年的后2位
    ///
    /// yyyy:       完整年
    ///
    /// MM:         月，显示为1-12,带前置0
    ///
    /// MMM:        月，显示为英文月份简写,如 Jan
    ///
    /// MMMM:       月，显示为英文月份全称，如 Janualy
    ///
    /// dd:         日，2位数表示，如02
    ///
    /// d:          日，1-2位显示，如2，无前置0
    ///
    /// EEE:        简写星期几，如Sun
    ///
    /// EEEE:       全写星期几，如Sunday
    ///
    /// aa:         上下午，AM/PM
    ///
    /// H:          时，24小时制，0-23
    ///
    /// HH:         时，24小时制，带前置0
    ///
    /// h:          时，12小时制，无前置0
    ///
    /// hh:         时，12小时制，带前置0
    ///
    /// m:          分，1-2位
    ///
    /// mm:         分，2位，带前置0
    ///
    /// s:          秒，1-2位
    ///
    /// ss:         秒，2位，带前置0
    ///
    /// S:          毫秒
    ///
    /// Z：          GMT（时区）
    /// - parameter format: 时间格式
    ///
    /// - returns: 指定格式的时间对象
    func zz_date(withDateFormat format: String) -> Date? {
        zz_dateFormatter.dateFormat = format
        return zz_dateFormatter.date(from: self)
    }
    
    
    /// 获取字符串的size
    ///
    /// - parameter size:       限制大小
    /// - parameter fontSize:   字体大小
    ///
    /// - returns: 字符串的size
    func zz_size(withLimitSize size: CGSize, fontSize: CGFloat) -> CGSize {
        let size = (self as NSString).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: fontSize)], context: nil).size
        return CGSize(width: ceil(size.width), height: ceil(size.height))
    }
    
    /// 获取字符串的size
    ///
    /// - parameter size:       限制大小
    /// - parameter fontSize:   字体大小
    ///
    /// - returns: 字符串的size
    func zz_size(withLimitWidth width: CGFloat, fontSize: CGFloat) -> CGSize {
        return zz_size(withLimitSize: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), fontSize: fontSize)
    }
    
    /// 获取字符串的size
    ///
    /// - parameter size:       限制大小
    /// - parameter fontSize:   字体大小
    ///
    /// - returns: 字符串的size
    func zz_size(withLimitHeight height: CGFloat, fontSize: CGFloat) -> CGSize {
        return zz_size(withLimitSize: CGSize(width: CGFloat.leastNormalMagnitude, height: height), fontSize: fontSize)
    }
}
