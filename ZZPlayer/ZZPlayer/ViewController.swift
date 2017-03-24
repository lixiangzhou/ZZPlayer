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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(NSNotification.Name.AVPlayerItemDidPlayToEndTime.rawValue)
        
        let playerView = view.zz_add(subview: ZZPlayerView(frame: CGRect(x: 20, y: 20, width: view.zz_width - 40, height: (view.zz_width - 40) * 3 / 4))) as! ZZPlayerView
        
        playerView.playerItemModel = VideoModel(dict: ["title": "测试标题", "videoUrlString": "http://baobab.wdjcdn.com/1455782903700jy.mp4"])
        playerView.backgroundColor = UIColor.black


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

