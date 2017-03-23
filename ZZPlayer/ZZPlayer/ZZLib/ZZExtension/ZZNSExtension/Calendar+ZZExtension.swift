//
//  Calendar+ZZExtension.swift
//  ZZSwiftTool
//
//  Created by lixiangzhou on 2017/3/10.
//  Copyright © 2017年 lixiangzhou. All rights reserved.
//

import Foundation

public let zz_calendar = Calendar.current

public extension Calendar {
    

    /// 遍历时间，可以获取需要的时间
    ///
    /// - parameter date:         获取的起始时间
    /// - parameter components:   时间组件
    /// - parameter policy:       匹配策略
    /// - parameter direction:    搜索方向
    /// - parameter usingClosure: 每次获取到时间都会调用的闭包
    func zz_enumerateDates(fromDate date: Date, matching components: DateComponents, matchingPolicy policy: Calendar.MatchingPolicy = .strict, direction: Calendar.SearchDirection = .forward, usingClosure closure: (Date?, Bool, inout Bool) -> Void) {
        zz_calendar.enumerateDates(startingAfter: date, matching: components, matchingPolicy: policy, repeatedTimePolicy: Calendar.RepeatedTimePolicy.first, direction: direction, using: closure)
    }
    
    
    
    /// 找到下一个符合时间组件和匹配规则的时间
    ///
    /// - parameter date:               获取的起始时间
    /// - parameter components:         时间组件
    /// - parameter matchingPolicy:     匹配策略
    /// - parameter direction:          搜索方向
    ///
    /// - returns: 匹配的时间
    func zz_nextDate(after date: Date, matching components: DateComponents, matchingPolicy policy: Calendar.MatchingPolicy = .strict, direction: Calendar.SearchDirection = .forward) -> Date? {
        return zz_calendar.nextDate(after: date, matching: components, matchingPolicy: policy, repeatedTimePolicy: .first, direction: direction)
    }
}
