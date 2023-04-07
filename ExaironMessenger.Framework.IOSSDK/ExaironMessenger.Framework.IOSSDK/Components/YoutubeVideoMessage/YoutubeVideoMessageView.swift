//
//  YoutubeVideoMessageView.swift
//  ExaironFramework
//
//  Created by Exairon on 23.03.2023.
//

import UIKit
import youtube_ios_player_helper

class YoutubeVideoMessageView: UIView {

    @IBOutlet var youtubeVideoPlayerView: YTPlayerView!
    var videoId: String = ""
    
    init(frame: CGRect, src: String) {
        super.init(frame: frame)
        let array = src.components(separatedBy: "/")
        self.videoId = array[array.count - 1]
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func initialView() {
        youtubeVideoPlayerView.load(withVideoId: videoId)
    }
    
    func commonInit() {
        let bundle = Bundle(for: Exairon.self)
        let viewFromXib = bundle.loadNibNamed("YoutubeVideoMessageView", owner: self, options: nil)![0] as! UIView
        viewFromXib.frame = self.bounds
        addSubview(viewFromXib)
        initialView()
    }

}
