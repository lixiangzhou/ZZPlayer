//
//  ViewController.swift
//  ZZPlayer
//
//  Created by lixiangzhou on 2017/3/23.
//  Copyright © 2017年 lixiangzhou. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class VideoModel: NSObject, ZZPlayerItemModel {
    var title: String?
    var videoUrlString: String?
    
    init(title: String, videoUrlString: String) {
        self.title = title
        self.videoUrlString = videoUrlString
    }
}

class ViewController: UIViewController {

    var playerView: ZZPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        view.backgroundColor = UIColor.black
//        let progressView = ZZPlayerVolumeProgressView()
//        progressView.progress = 0.5
//        view.addSubview(progressView)
        
//        let pv = MPVolumeView(frame: CGRect(x: 20, y: 20, width: 100, height: 100))
//        print(pv.subviews)
//        pv.backgroundColor = UIColor.red
//        view.addSubview(pv)
        
        
        playerView = ZZPlayerView(frame: CGRect(x: 20, y: 20, width: view.frame.width - 40, height: (view.frame.height - 40) * 3 / 4))
        view.addSubview(playerView)

        playerView.snp.makeConstraints { (maker) in
            maker.top.left.right.equalTo(self.view)
            maker.width.equalTo(self.view.snp.width)
            maker.height.equalTo(self.view.snp.width).multipliedBy(UIScreen.main.bounds.width / UIScreen.main.bounds.height)
        }
        
//        playerView.playerItemModels = [VideoModel(dict: ["title": "测试标题", "videoUrlString": "http://baobab.wdjcdn.com/14562919706254.mp4"]),
//                                      VideoModel(dict: ["title": "测试标题", "videoUrlString": "http://baobab.wdjcdn.com/14525705791193.mp4"])]

        
        playerView.playerItemModels = [VideoModel(title: "测试标题", videoUrlString: "http://baobab.wdjcdn.com/14525705791193.mp4")]
//        playerView.backgroundColor = UIColor.black


    }



}

