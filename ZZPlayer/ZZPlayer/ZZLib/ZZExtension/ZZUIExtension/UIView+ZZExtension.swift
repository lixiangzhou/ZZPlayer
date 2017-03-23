//
//  UIView+ZZExtension.swift
//  ZZSwiftTool
//
//  Created by lixiangzhou on 2017/3/10.
//  Copyright © 2017年 lixiangzhou. All rights reserved.
//

import UIKit

public extension UIView {
    
    /// view所在的UIViewController
    var zz_controller: UIViewController? {
        var responder = next
        while responder != nil {
            if responder!.isKind(of: UIViewController.self) {
                return responder as? UIViewController
            }
            responder = responder?.next
        }
        return nil
    }
    
    
    /// 移除所有子控件
    func zz_removeAllSubviews() {
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
}

public extension UIView {
    /// 设置圆形
     func zz_setCircle() {
        zz_setCorner(radius: min(bounds.width, bounds.height) * 0.5, masksToBounds: true)
    }
    
    /// 设置圆角
    func zz_setCorner(radius: CGFloat, masksToBounds: Bool) {
        layer.cornerRadius = radius
        layer.masksToBounds = masksToBounds
    }
    
    
    /// 设置边宽及颜色
    ///
    /// - parameter color: 边框颜色
    /// - parameter width: 边框宽度
    func zz_setBorder(color: UIColor, width: CGFloat) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
}

public extension UIView {
    
    /// 添加子控件
    ///
    /// - parameter subview: 子控件
    ///
    /// - returns: 添加的子控件
    func zz_add(subview: UIView) -> UIView {
        addSubview(subview)
        return subview
    }
    
    
    /// 添加子控件
    ///
    /// - parameter subview: 子控件
    /// - parameter frame:   子控件的frame
    ///
    /// - returns: 添加的子控件
    func zz_add(subview: UIView, frame: CGRect) -> UIView {
        addSubview(subview)
        subview.frame = frame
        return subview
    }
    
}

public extension UIView {
    
    /// nib 加载控件
    ///
    /// - parameter nibName: nib 文件名
    ///
    /// - returns: nib 文件中对应的第一个对象
    static func zz_loadFrom(nibName: String) -> UIView? {
        return UINib(nibName: nibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as? UIView
    }
    
    /// nib 加载控件，nib 文件名和View类名一致
    static func zz_loadFromNib() -> UIView? {
        let nibName = NSStringFromClass(self.classForCoder()).components(separatedBy: ".").last!
        return UINib(nibName: nibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as? UIView
    }
}

public extension UIView {
    /// view生成的对应的图片
    func zz_snapshotImage() -> UIImage {
        return zz_cropImage(inRect: bounds)
    }
    
    
    /// 在指定区域截取图像
    ///
    /// - parameter inRect: 截取图像的区域
    ///
    /// - returns: 截取的图像
    func zz_cropImage(inRect: CGRect) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 0)
        UIRectClip(inRect)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

public extension UIView {
    var zz_x: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            frame.origin.x = newValue
        }
    }
    
    var zz_y: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            frame.origin.y = newValue
        }
    }
    
    var zz_width: CGFloat {
        get {
            return frame.width
        }
        set {
            frame.size.width = newValue
        }
    }
    
    var zz_height: CGFloat {
        get {
            return frame.height
        }
        set {
            frame.size.height = newValue
        }
    }
}

