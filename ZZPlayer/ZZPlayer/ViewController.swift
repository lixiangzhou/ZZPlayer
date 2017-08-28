//
//  ViewController.swift
//  ZZPlayer
//
//  Created by lixiangzhou on 2017/3/23.
//  Copyright © 2017年 lixiangzhou. All rights reserved.
//

import   UIKit
import AVFoundation

class VideoModel: NSObject, ZZPlayerItemResource {
    var placeholderImage: UIImage?
    var placeholderImageUrl: String?
    var title: String
    var videoUrlString: String
    var seekTo: TimeInterval = 30
    
    init(title: String, videoUrlString: String) {
        self.title = title
        self.videoUrlString = videoUrlString
    }
}

class ViewController: UIViewController {

    var datas = [VideoModel]()
    
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView(frame: view.bounds)
        view.addSubview(tableView)
        tableView.register(ZZPlayerCell.self, forCellReuseIdentifier: "ID")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 280
        
        tableView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
        
        let vm = VideoModel(title: "测试标题", videoUrlString: "http://baobab.wdjcdn.com/14525705791193.mp4")

        datas = Array<VideoModel>(repeating: vm, count: 10)
        
        ZZPlayerView.shared.configVertical.statusBarStyle = .default
        ZZPlayerView.shared.configHorizontal.statusBarStyle = .lightContent
    }

    override var shouldAutorotate: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ZZPlayerView.shared.config.statusBarStyle
    }
    
    override var prefersStatusBarHidden: Bool {
        return ZZPlayerView.shared.config.statusBarHidden
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ZZPlayerView.shared.reset()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ID", for: indexPath) as! ZZPlayerCell
        cell.resource = datas[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(DetailViewController(), animated: true)
    }
}

class ZZPlayerCell: UITableViewCell {
    
    var playClosure: (()->())?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        let imgView = UIImageView(image: UIImage(named: "cell_bg"))
        imgView.isUserInteractionEnabled = true
        imgView.tag = 101
        contentView.addSubview(imgView)
        imgView.snp.makeConstraints { (maker) in
            maker.top.left.right.equalToSuperview()
            maker.bottom.equalToSuperview().offset(-10)
        }
        imgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(play)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var resource: VideoModel?
    
    @objc private func play() {
//        playClosure?()
        ZZPlayerView.shared.play(resource: resource!, inCell: self, withPlayerContainerTag: 101)
    }
}

