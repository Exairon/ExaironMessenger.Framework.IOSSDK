//
//  BannerView.swift
//  ExaironMessengerFramework.IOSSDK
//
//  Created by Exairon on 22.03.2023.
//

import UIKit

class BannerView: UIView {
    
    @IBOutlet weak var exa_logoView: UIImageView!
    @IBOutlet weak var bannerView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func initialView() {
        exa_logoView.downloaded(from: "\(Exairon.shared.src)/assets/images/logo-sm.png")
        
    }

    func commonInit() {
        let bundle = Bundle(for: Exairon.self)
        let viewFromXib = bundle.loadNibNamed("BannerView", owner: self, options: nil)![0] as! UIView
        viewFromXib.frame = self.bounds
        addSubview(viewFromXib)
        initialView()
    }
    

}
