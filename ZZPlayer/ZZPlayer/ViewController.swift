//
//  ViewController.swift
//  ZZPlayer
//
//  Created by lixiangzhou on 2017/3/23.
//  Copyright © 2017年 lixiangzhou. All rights reserved.
//

import UIKit
import AVFoundation

class VideoModel: NSObject, ZZPlayerItemResource {
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
        
        
        playerView = ZZPlayerView(frame: CGRect(x: 20, y: 20, width: view.frame.width - 40, height: (view.frame.height - 40) * 3 / 4))
        var config = playerView.configHorizontal
        config.top.title.font = UIFont.systemFont(ofSize: 16)
        config.top.height = 60
        config.top.icon.size = CGSize(width: 50, height: 50)
        config.bottom.height = 55
        
        playerView.configHorizontal = config
        playerView.autoPlay = false
        view.addSubview(playerView)

        playerView.snp.makeConstraints { (maker) in
            maker.top.left.right.equalTo(self.view)
            maker.width.equalTo(self.view.snp.width)
            maker.height.equalTo(self.view.snp.width).multipliedBy(UIScreen.main.bounds.width / UIScreen.main.bounds.height)
        }
        
        playerView.playerItemResources = [
            VideoModel(title: "测试标题", videoUrlString: "http://baobab.wdjcdn.com/14525705791193.mp4"),
            VideoModel(title: "测试标题2", videoUrlString: "http://baobab.wdjcdn.com/14525705791193.mp4")]
//        playerView.backgroundColor = UIColor.black


    }



}

