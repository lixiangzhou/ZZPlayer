//
//  UIDevice+ZZExtension.swift
//  ZZSwiftTool
//
//  Created by lixiangzhou on 2017/3/21.
//  Copyright © 2017年 lixiangzhou. All rights reserved.
//

import UIKit

public let zz_device = UIDevice.current

/// 具体参照： https://www.theiphonewiki.com/wiki/Models
fileprivate let zz_deviceVersion: (identifier: String, version: ZZDeviceVersion) = {
    
    var systemInfo = utsname()
    uname(&systemInfo)
    let identifier = String(validatingUTF8: NSString(bytes: &systemInfo.machine, length: Int(_SYS_NAMELEN), encoding: String.Encoding.ascii.rawValue)!.utf8String!) ?? "unknown"
    
    switch identifier {
        /*** iPhone ***/
    case "iPhone3,1", "iPhone3,2", "iPhone3,3":      return (identifier: identifier, version:ZZDeviceVersion.iPhone_4)
    case "iPhone4,1", "iPhone4,2", "iPhone4,3":      return (identifier: identifier, version:ZZDeviceVersion.iPhone_4S)
    case "iPhone5,1", "iPhone5,2":                   return (identifier: identifier, version:ZZDeviceVersion.iPhone_5)
    case "iPhone5,3", "iPhone5,4":                   return (identifier: identifier, version:ZZDeviceVersion.iPhone_5C)
    case "iPhone6,1", "iPhone6,2":                   return (identifier: identifier, version:ZZDeviceVersion.iPhone_5S)
    case "iPhone7,2":                                return (identifier: identifier, version:ZZDeviceVersion.iPhone_6)
    case "iPhone7,1":                                return (identifier: identifier, version:ZZDeviceVersion.iPhone_6_Plus)
    case "iPhone8,1":                                return (identifier: identifier, version:ZZDeviceVersion.iPhone_6S)
    case "iPhone8,2":                                return (identifier: identifier, version:ZZDeviceVersion.iPhone_6S_Plus)
    case "iPhone8,4":                                return (identifier: identifier, version:ZZDeviceVersion.iPhone_SE)
    case "iPhone9,1", "iPhone9,3":                   return (identifier: identifier, version:ZZDeviceVersion.iPhone_7)
    case "iPhone9,2", "iPhone9,4":                   return (identifier: identifier, version:ZZDeviceVersion.iPhone_7_Plus)
        
        /*** iPad ***/
    case "iPad1,1":                                  return (identifier: identifier, version:ZZDeviceVersion.iPad)
    case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4": return (identifier: identifier, version:ZZDeviceVersion.iPad_2)
    case "iPad3,1", "iPad3,2", "iPad3,3":            return (identifier: identifier, version:ZZDeviceVersion.iPad_3)
    case "iPad3,4", "iPad3,5", "iPad3,6":            return (identifier: identifier, version:ZZDeviceVersion.iPad_4)
    case "iPad4,1", "iPad4,2", "iPad4,3":            return (identifier: identifier, version:ZZDeviceVersion.iPad_Air)
    case "iPad5,3", "iPad5,4":                       return (identifier: identifier, version:ZZDeviceVersion.iPad_Air_2)
    case "iPad2,5", "iPad2,6", "iPad2,7":            return (identifier: identifier, version:ZZDeviceVersion.iPad_Mini)
    case "iPad4,4", "iPad4,5", "iPad4,6":            return (identifier: identifier, version:ZZDeviceVersion.iPad_Mini_2)
    case "iPad4,7", "iPad4,8", "iPad4,9":            return (identifier: identifier, version:ZZDeviceVersion.iPad_Mini_3)
    case "iPad5,1", "iPad5,2":                       return (identifier: identifier, version:ZZDeviceVersion.iPad_Mini_4)
    case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8": return (identifier: identifier, version:ZZDeviceVersion.iPad_Pro)
        
        /*** iPod ***/
    case "iPod1,1":                                  return (identifier: identifier, version:ZZDeviceVersion.iPodTouch_1)
    case "iPod2,1":                                  return (identifier: identifier, version:ZZDeviceVersion.iPodTouch_2)
    case "iPod3,1":                                  return (identifier: identifier, version:ZZDeviceVersion.iPodTouch_3)
    case "iPod4,1":                                  return (identifier: identifier, version:ZZDeviceVersion.iPodTouch_4)
    case "iPod5,1":                                  return (identifier: identifier, version:ZZDeviceVersion.iPodTouch_5)
    case "iPod7,1":                                  return (identifier: identifier, version:ZZDeviceVersion.iPodTouch_6)
        
        /*** Simulator ***/
    case "i386", "x86_64":                           return (identifier: identifier, version:ZZDeviceVersion.simulator)
        
    default:                                         return (identifier: identifier, version:ZZDeviceVersion.unknown)
    }
}()

public enum ZZDeviceType: String {
    case iPhone
    case iPad
    case iPod
    case simulator
    case unknown
}

public enum ZZDeviceVersion: String {
    /*** iPhone ***/
    case iPhone_4
    case iPhone_4S
    case iPhone_5
    case iPhone_5C
    case iPhone_5S
    case iPhone_6
    case iPhone_6_Plus
    case iPhone_6S
    case iPhone_6S_Plus
    case iPhone_SE
    case iPhone_7
    case iPhone_7_Plus
    
    /*** iPad ***/
    case iPad
    case iPad_2
    case iPad_Mini
    case iPad_3
    case iPad_4
    case iPad_Air
    case iPad_Mini_2
    case iPad_Air_2
    case iPad_Mini_3
    case iPad_Mini_4
    case iPad_Pro
    
    /*** iPod ***/
    case iPodTouch_1
    case iPodTouch_2
    case iPodTouch_3
    case iPodTouch_4
    case iPodTouch_5
    case iPodTouch_6
    
    /*** Simulator ***/
    case simulator
    
    /*** Unknown ***/
    case unknown
}

public extension UIDevice {
    
    /// 是否iPad
    var zz_isPad: Bool {
        return zz_type == .iPad
    }
    
    /// 是否iPhone
    var zz_isPhone: Bool {
        return zz_type == .iPhone
    }
    
    /// 是否iPod
    var zz_isPod: Bool {
        return zz_type == .iPod
    }
    
    /// 是否Simulator
    var zz_isSimulator: Bool {
        return zz_type == .simulator
    }
    
    /// 设备类型
    var zz_type: ZZDeviceType {
        let identifier = zz_deviceVersion.identifier
        if identifier.contains("iPhone") {
            return .iPhone
        } else if identifier.contains("iPad") {
            return .iPad
        } else if identifier.contains("iPod") {
            return .iPod
        } else if identifier == "i386" || identifier == "x86_64" {
            return .simulator
        } else {
            return .unknown
        }
    }
    
    /// 设备版本
    var zz_version: ZZDeviceVersion {
        return zz_deviceVersion.version
    }
    
    /// 设备 identifier
    var zz_identifier: String {
        return zz_deviceVersion.identifier
    }
    
    /// 是否可打电话
    var zz_canMakePhoneCall: Bool {
        return zz_application.canOpenURL(URL(string: "tel://")!)
    }
    
    /// 设备 uuid
    var zz_uuidString: String? {
        return zz_device.identifierForVendor?.uuidString
    }
    
    /// 获取磁盘大小(字节)，获取失败返回-1
    var zz_systemSize: Double {
        guard let attr = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()) else {
            return -1
        }
        
        guard let space = attr[FileAttributeKey.systemSize] as? Double else {
            return -1
        }
        
        return space
    }
    
    /// 获取磁盘可用大小(字节)，获取失败返回-1
    var zz_systemFreeSize: Double {
        guard let attr = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()) else {
            return -1
        }
        
        guard let space = attr[FileAttributeKey.systemFreeSize] as? Double else {
            return -1
        }
        
        return space
    }
}
