//
//  Data+ZZExtension.swift
//  ZZSwiftTool
//
//  Created by lixiangzhou on 2017/3/22.
//  Copyright © 2017年 lixiangzhou. All rights reserved.
//

import Foundation

public extension Data {
    /// data 的utf8字符串
    var zz_utf8String: String? {
        return String(data: self, encoding: .utf8)
    }
    
}
