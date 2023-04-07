//
//  AudioMessageView.swift
//  ExaironFramework
//
//  Created by Exairon on 24.03.2023.
//

import UIKit
import AVKit
import AVFoundation

class AudioMessageView: UIView {

    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var slider: UISlider!
    
    var audioPlayer: AVPlayer?
    var audioUrl: String!
    var sender: String!
    var isPlaying: Bool = false
    
    let playIcon: UIImage! = UIImage(named: "play.png")
    let pauseIcon: UIImage! = UIImage(named: "pause.jpg")

    
    init(frame: CGRect, audioUrl: String, sender: String) {
        super.init(frame: frame)
        self.audioUrl = audioUrl
        self.sender = sender
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func updateSlider() {
        let currentDuration : CMTime = audioPlayer?.currentItem?.currentTime() ?? CMTime(seconds: 0, preferredTimescale: CMTimeScale(1000))
        let currentSeconds : Float64 = CMTimeGetSeconds(currentDuration)
        slider.value = Float(currentSeconds)
    }
    
    @IBAction func audioButtonTapped(_ sender: UIButton) {
        slider.maximumValue = Float(self.audioPlayer?.currentItem?.duration.seconds ?? 1)
        if !isPlaying {
            self.audioPlayer?.play()
            self.audioButton.setTitle("▐▐", for: .normal)
            self.audioPlayer?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 100), queue: DispatchQueue.main) { (CMTime) -> Void in
                let time : Float64 = CMTimeGetSeconds(self.audioPlayer!.currentTime());
                self.slider.value = Float(time)
                if ((self.slider.value + 0.2) >= self.slider.maximumValue) || ((self.slider.value - 0.2) >= self.slider.maximumValue) {
                    self.audioButton.setTitle("▶", for: .normal)
                    self.resetAudioDuration()
                }
            }
        } else {
            audioButton.setTitle("▶", for: .normal)
            self.audioPlayer?.pause()
        }
        isPlaying.toggle()
    }
    
    func resetAudioDuration() {
        self.audioPlayer?.pause()
        isPlaying.toggle()
        self.audioPlayer?.pause()

        self.audioPlayer?.currentItem?.seek(to: CMTime(seconds: 0, preferredTimescale: CMTimeScale(1000)))
    }
    
    @IBAction func audioSlider(_ sender: UISlider) {
        if Float(self.audioPlayer?.currentItem?.duration.seconds ?? 1) != slider.maximumValue {
            slider.maximumValue = Float(self.audioPlayer?.currentItem?.duration.seconds ?? 1)
        }
        self.audioPlayer?.currentItem?.seek(to: CMTime(seconds: Double(slider.value), preferredTimescale: CMTimeScale(1000)), completionHandler: nil)
    }
    
    func initialView() {
        if let url = URL(string: audioUrl) {
            self.audioPlayer = AVPlayer(url: url)
            self.slider.value = 0
        }
        audioButton.setTitle("▶", for: .normal)
        audioButton.addTarget(self, action: #selector(audioButtonTapped(_:)), for: .touchUpInside)
        slider.addTarget(self, action: #selector(audioSlider(_:)), for: .valueChanged)

        let margins = self
        if sender == "bot_uttered" {
            audioView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 0).isActive = true
        } else {
            audioView.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 0).isActive = true
        }
    }
    
    func commonInit() {
        let bundle = Bundle(for: Exairon.self)
        let viewFromXib = bundle.loadNibNamed("AudioMessageView", owner: self, options: nil)![0] as! UIView
        viewFromXib.frame = self.bounds
        addSubview(viewFromXib)
        initialView()
    }

}
