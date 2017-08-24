//
//  ZZPlayerItemResource.swift
//  ZZPlayer
//
//  Created by lixiangzhou on 2017/8/24.
//  Copyright © 2017年 lixiangzhou. All rights reserved.
//

import UIKit

/// 播放的 item 必须遵循的协议
@objc protocol ZZPlayerItemResource: NSObjectProtocol {
    var title: String? { get set }
    var videoUrlString: String? { get set }
    @objc optional var placeholderImage: UIImage? { get set }
    @objc optional var placeholderImageUrl: String?  { get set }
    @objc optional var resolutions: [String: String]?  { get set }
}
