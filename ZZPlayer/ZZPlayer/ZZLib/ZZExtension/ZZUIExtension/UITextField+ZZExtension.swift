//
//  UITextField+ZZExtension.swift
//  ZZSwiftTool
//
//  Created by lixiangzhou on 2017/3/17.
//  Copyright © 2017年 lixiangzhou. All rights reserved.
//

import UIKit

public extension UITextField {
    
    
    /// 选中所有文字
    func zz_selectAllText() {
        guard let range = textRange(from: beginningOfDocument, to: endOfDocument) else {
            return
        }
        selectedTextRange = range
    }
    
    
    /// 选中指定范围的文字
    ///
    /// - parameter selectedRange: 指定的范围
    func zz_set(selectedRange range: NSRange) {
        
        guard let start = position(from: beginningOfDocument, offset: range.location),
            let end = position(from: beginningOfDocument, offset: NSMaxRange(range)) else {
                return;
        }
        selectedTextRange = textRange(from: start, to: end)
    }
}
