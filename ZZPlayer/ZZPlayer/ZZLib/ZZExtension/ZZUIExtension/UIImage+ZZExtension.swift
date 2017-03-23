//
//  UIImage+ZZExtension.swift
//  ZZSwiftTool
//
//  Created by lixiangzhou on 2017/3/10.
//  Copyright © 2017年 lixiangzhou. All rights reserved.
//

import UIKit

/// 用于缓存圆形边框
private var cacheImageBg = [String: UIImage]()

public extension UIImage {
    
    /// 截取图片的一部分
    ///
    /// - parameter inRect: 指定截取图片的区域
    ///
    /// - returns: 截取的图片
    func zz_crop(inRect rect: CGRect) -> UIImage? {
        let scale = UIScreen.zz_scale
        let dotRect = CGRect(x: rect.zz_x * scale, y: rect.zz_y * scale, width: rect.width * scale, height: rect.height * scale)
        
        guard let cgimg = cgImage?.cropping(to: dotRect) else {
            return nil
        }
        
        return UIImage(cgImage: cgimg, scale: scale, orientation: .up)
    }
    
    
    /// 根据颜色生成指定大小的方图
    ///
    /// - parameter color:     图片颜色
    /// - parameter imageSize: 图片大小
    ///
    /// - returns: 生成的图片
    static func zz_image(withColor color: UIColor, imageSize: CGFloat = 0.5) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: imageSize, height: imageSize), false, 0.0)
        
        color.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
        
        let result = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return result
    }
    
    
    /// 异步回执图片，主线程返回图片
    ///
    /// - parameter size:      图片的大小
    /// - parameter isCircle:  是否圆形图
    /// - parameter backColor: 图片的北京色
    /// - parameter finished:  回调返回图片的闭包
    func zz_asyncDrawImage(size: CGSize, isCircle: Bool = false, backColor: UIColor? = UIColor.white, finished: @escaping (_ image: UIImage) -> ()) {
        DispatchQueue.global().async {
            
            let key = "" + size.width.description + size.height.description + (backColor != nil ? backColor!.description : UIColor.clear.description)
            
            var backImg = cacheImageBg[key]
            
            let rect = CGRect(origin: CGPoint.zero, size: size)
            
            if backImg == nil && isCircle {
                
                backImg = UIImage.zz_clearCircleImage(inSize: size)
                
                cacheImageBg[key] = backImg
            }
            
            UIGraphicsBeginImageContextWithOptions(size, backColor != nil, 0.0)
            
            self.draw(in: rect)
            
            backImg?.draw(in: rect)
            
            let result = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            
            DispatchQueue.main.async {
                finished(result)
            }
        }
    }
    
    
    /// 根据指定大小和边部颜色生成一张中间是透明圆形的图片
    ///
    /// - parameter size:      图片大小，根据该大小设置中间
    /// - parameter backColor: 透明圆形与矩形四边之间的颜色
    ///
    /// - returns: 中间是透明圆形的图片
    class func zz_clearCircleImage(inSize size: CGSize, backColor: UIColor? = UIColor.white) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        let rect = CGRect(origin: CGPoint.zero, size: size)
        if let backColor = backColor {
            backColor.setFill()
            UIRectFill(rect)
        }
        
        // 透明圆
        let path = UIBezierPath(ovalIn: rect)
        path.addClip()
        UIColor.clear.setFill()
        UIRectFill(rect)
        
        let result = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return result
    }
}
