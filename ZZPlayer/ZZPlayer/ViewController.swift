//
//  ViewController.swift
//  ZZPlayer
//
//  Created by lixiangzhou on 2017/3/23.
//  Copyright © 2017年 lixiangzhou. All rights reserved.
//

import UIKit
import AVFoundation

class VideoModel: NSObject, ZZPlayerItemModel {
    var title: String?
    var videoUrlString: String?
}

class ViewController: UIViewController {

    var playerView: ZZPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print(NSNotification.Name.AVPlayerItemDidPlayToEndTime.rawValue)
        
        playerView = view.zz_add(subview: ZZPlayerView(frame: CGRect(x: 20, y: 20, width: view.zz_width - 40, height: (view.zz_width - 40) * 3 / 4))) as! ZZPlayerView
        
//        playerView.playerItemModels = [VideoModel(dict: ["title": "测试标题", "videoUrlString": "http://baobab.wdjcdn.com/14562919706254.mp4"]),
//                                      VideoModel(dict: ["title": "测试标题", "videoUrlString": "http://baobab.wdjcdn.com/14525705791193.mp4"])]
        
        playerView.playerItemModels = [VideoModel(dict: ["title": "测试标题", "videoUrlString": "http://baobab.wdjcdn.com/14562919706254.mp4"])]
        playerView.backgroundColor = UIColor.black


    }

//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        playerView.playerItemModel = VideoModel(dict: ["title": "测试标题", "videoUrlString": "http://baobab.wdjcdn.com/14525705791193.mp4"])
//    }


}

