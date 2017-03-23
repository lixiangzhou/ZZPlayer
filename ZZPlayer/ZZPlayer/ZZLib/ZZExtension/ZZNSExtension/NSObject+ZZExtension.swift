//
//  NSObject+ZZExtension.swift
//  ZZSwiftTool
//
//  Created by lixiangzhou on 17/3/12.
//  Copyright © 2017年 lixiangzhou. All rights reserved.
//

import Foundation


public extension NSObject {
    
    /// 快速字典转模型（使用系统的方式）
    ///
    /// - parameter dict: 属性 和 属性值 字典
    ///
    /// - returns: 模型
    convenience init(dict: [String: Any]) {
        self.init()
        setValuesForKeys(dict)
    }
}

public extension NSObject {
    
    
    /// 快速字典转模型（使用系统的方式）
    ///
    /// - parameter dict: 属性 和 属性值 字典
    ///
    /// - returns: 模型
    static func zz_toModel(dict: [String: AnyObject]) -> AnyObject {
        let model = self.init()
        model.setValuesForKeys(dict)
        return model
    }
    
    
    /// 快速字典转模型（使用系统的方式）
    ///
    /// - parameter dictArray: 需要转模型的字典数组
    ///
    /// - returns: 转成功的模型数组
    static func zz_toModelArray(dictArray: [[String: AnyObject]]) -> [AnyObject]? {
        var models = [AnyObject]()
        
        for dict in dictArray {
            let model = zz_toModel(dict: dict)
            models.append(model)
        }
        
        return models
    }
    
    
    /// 对象的 属性 和 属性值
    var zz_peopertyValues: [String: Any]? {
        
        var propertyValues = [String : Any]()
        guard let properties = zz_properties else {
            return nil
        }
        
        for pName in properties {
            let pValue = self.value(forKey: pName)
            propertyValues[pName] = pValue ?? NSNull()
        }
        //        return dictionaryWithValues(forKeys: properties) as? [String: Any]
        return propertyValues.count == 0 ? nil : propertyValues
    }
    
    /// 对象的所有属性
    var zz_properties: [String]? {
        var count: UInt32 = 0
        
        guard let properties = class_copyPropertyList(type(of: self), &count) else {
            return nil
        }
        
        var propertyValues = [String]()
        
        for i in 0..<count {
            guard let property = properties[Int(i)] else {
                continue
            }
            guard let pCname = property_getName(property) else {
                continue
            }
            guard let pName = NSString(cString: pCname, encoding: String.Encoding.utf8.rawValue) as? String else {
                continue
            }
            
            propertyValues.append(pName)
        }
        return propertyValues
    }
    
    
    /// 打印对象的所有属性
    func zz_printPeopertyValues() {
        guard let peopertyValues = zz_peopertyValues else{
            print("\(type(of: self)) 未找到属性值对")
            return
        }
        print("----------------\(type(of: self))----------------")
        print(peopertyValues as NSDictionary)
    }
}
