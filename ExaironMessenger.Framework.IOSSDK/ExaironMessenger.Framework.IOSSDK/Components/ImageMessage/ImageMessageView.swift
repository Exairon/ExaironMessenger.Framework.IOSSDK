//
//  ImageMessage.swift
//  ExaironFramework
//
//  Created by Exairon on 23.03.2023.
//

import UIKit

class ImageMessageView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var mainView: UIView!
    
    var imageUrl: String = ""
    var sender: String = ""
    
    init(frame: CGRect, imageUrl: String, sender: String) {
        super.init(frame: frame)
        self.imageUrl = imageUrl
        self.sender = sender
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func initialView() {
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.downloaded(from: imageUrl)
        let margins = mainView.layoutMarginsGuide
        let viewMargins = view.layoutMarginsGuide
        if sender == "bot_uttered" {
            view.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 0).isActive = true
            imageView.leadingAnchor.constraint(equalTo: viewMargins.leadingAnchor).isActive = true
        } else {
            view.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 0).isActive = true
            imageView.trailingAnchor.constraint(equalTo: viewMargins.trailingAnchor).isActive = true
        }
    }
    
    func commonInit() {
        let bundle = Bundle(for: Exairon.self)
        let viewFromXib = bundle.loadNibNamed("ImageMessageView", owner: self, options: nil)![0] as! UIView
        viewFromXib.frame = self.bounds
        addSubview(viewFromXib)
        initialView()
    }
}
