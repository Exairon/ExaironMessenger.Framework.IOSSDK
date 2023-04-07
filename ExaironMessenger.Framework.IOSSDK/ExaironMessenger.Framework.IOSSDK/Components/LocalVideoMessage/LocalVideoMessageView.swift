//
//  LocalVideoMessageView.swift
//  ExaironFramework
//
//  Created by Exairon on 23.03.2023.
//

import UIKit
import AVKit

class LocalVideoMessageView: UIView {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var view: UIView!
    
    var videoUrlString: String = ""
    var player: AVPlayer? = nil
    var playerController = AVPlayerViewController()

    init(frame: CGRect, videoUrlString: String) {
        super.init(frame: frame)
        self.videoUrlString = videoUrlString
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func initialView() {
        let videoURL = URL(string: videoUrlString)
        player = AVPlayer(url: videoURL!)
        playerController.player = player
        playerController.view.frame.size.width = view.frame.size.width
        playerController.view.frame.size.height = view.frame.size.height
        view.addSubview(playerController.view)
    }
    
    func commonInit() {
        let bundle = Bundle(for: Exairon.self)
        let viewFromXib = bundle.loadNibNamed("LocalVideoMessageView", owner: self, options: nil)![0] as! UIView
        viewFromXib.frame = self.bounds
        addSubview(viewFromXib)
        initialView()
    }

}
