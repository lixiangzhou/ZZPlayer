//
//  UIAlertController+ZZExtension.swift
//  ZZSwiftTool
//
//  Created by lixiangzhou on 2017/3/10.
//  Copyright © 2017年 lixiangzhou. All rights reserved.
//

import UIKit

public extension UIAlertController {
    
    /// 快捷弹窗，Alert 样式或者 ActionSheet样式
    ///
    /// - parameter fromController: 弹窗所在的控制器
    /// - parameter style:          弹窗样式，UIAlertControllerStyle.alert 或者 UIAlertControllerStyle.actionSheet
    /// - parameter title:          title
    /// - parameter message:        message
    /// - parameter action1Title:   第一个按钮的title
    /// - parameter action1Style:   第一个按钮的样式 UIAlertActionStyle (default, destructive, cancel)
    /// - parameter action1Handler: 第一个按钮触发的操作
    /// - parameter action2Title:   第二个按钮的title
    /// - parameter action2Style:   第二个按钮的样式 UIAlertActionStyle (default, destructive, cancel)
    /// - parameter action2Handler: 第二个按钮触发的操作
    /// - parameter completion:     弹窗消失执行的操作
    ///
    /// - returns: 弹窗对象 UIAlertController
    static func zz_show(fromController: UIViewController, style: UIAlertControllerStyle = .alert, title: String? = nil, message: String? = nil,
                            action1Title: String, action1Style: UIAlertActionStyle = .default, action1Handler:((UIAlertAction) -> Void)? = nil,
                            action2Title: String? = nil, action2Style: UIAlertActionStyle = .default, action2Handler: (@escaping(UIAlertAction) -> Void), completion: (() -> Void)? = nil) -> UIAlertController {
        
        let alertVc = UIAlertController(title: title, message: message, preferredStyle: style)
        
        alertVc.addAction(UIAlertAction(title: action1Title, style: action1Style, handler: action1Handler))
        
        if let action2Title = action2Title {
            alertVc.addAction(UIAlertAction(title: action2Title, style: action2Style, handler: action2Handler))
        }
        
        fromController.present(alertVc, animated: true, completion: completion)
        return alertVc
    }
}
