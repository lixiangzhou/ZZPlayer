//
//  Locale+ZZExtension.swift
//  ZZSwiftTool
//
//  Created by lixiangzhou on 2017/3/20.
//  Copyright © 2017年 lixiangzhou. All rights reserved.
//

import Foundation

public extension Locale {
    
    /// 国际化语言
    ///
    /// - parameter identifier: 国家的 identifier. 比如中国 zh，英国 en
    /// - parameter key:        国际化的key
    /// - parameter value:      如果根据key找不到对应的值，或者key为nil，则返回此value
    /// - parameter table:      国际化列表，如果为nil 或 空字符串，则使用 Localizable.strings
    ///
    /// - returns: 对应国家的国际化值
    ///            如果 identifier 对应的国际化文件或bundle不存在，value 非空 返回 value，否则返回 "";
    ///            如果key为nil 或未找到，value 非空 返回 value，否则返回 "";
    static func zz_localizedString(withIdentifier identifier: String, forKey key: String, value: String? = nil, table: String? = nil) -> String {
        guard let path = Bundle.main.path(forResource: identifier + ".lproj", ofType: nil) else {
            print("\(identifier) 对应的bundle 的路径不存在")
            return value ?? ""
        }
        if let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: key, value: value, table: table)
        }
        print("\(identifier) 对应的bundle 不存在")
        return value ?? ""
    }
}
