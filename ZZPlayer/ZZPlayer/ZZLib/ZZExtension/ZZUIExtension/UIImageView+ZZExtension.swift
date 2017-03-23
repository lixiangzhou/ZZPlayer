//
//  UIImageView+ZZExtension.swift
//  ZZSwiftTool
//
//  Created by lixiangzhou on 17/3/12.
//  Copyright © 2017年 lixiangzhou. All rights reserved.
//

import UIKit

public enum UIImageViewCircleMode {
    case drawing, doubleImage
}

/// 缓存图片
private var cachedImage = [String: UIImage]()

public extension UIImageView {
    
    /// 创建一个可以设置中心原图的UIImageView
    ///
    /// - parameter frame:     frame
    /// - parameter image:     显示的图片
    /// - parameter isCircle:  是否圆形
    /// - parameter backColor: 背景色
    /// - parameter mode:      显示模式：drawing 异步回执模式；doubleImage 双图模式
    convenience init(frame: CGRect, image: UIImage?, isCircle: Bool = false, backColor: UIColor? = UIColor.white, mode: UIImageViewCircleMode = .doubleImage) {
        self.init(frame: frame)
        
        let size = frame.size
        if mode == .drawing {
            image?.zz_asyncDrawImage(size: size, isCircle: isCircle, backColor: backColor, finished: { (img) in
                self.image = img
            })
        } else if mode == .doubleImage {
            let size = frame.size
            let key = "" + size.width.description + size.height.description + (backColor != nil ? backColor!.description : UIColor.clear.description)
            
            var corverImg = cachedImage[key]
            
            if corverImg == nil && isCircle {
                corverImg = UIImage.zz_clearCircleImage(inSize: size, backColor: backColor)
            }
            
            self.image = image
            
            let coverView = UIImageView(frame: CGRect(origin: CGPoint.zero, size: size))
            coverView.image = corverImg
            addSubview(coverView)
        }
    }
}
