//
//  HeaderView.swift
//  ExaironFramework
//
//  Created by Exairon on 22.03.2023.
//

import UIKit

class HeaderView: UIView {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var descriptionView: UILabel!
    @IBOutlet weak var closeButton: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func initialView() {
        let color = WidgetSettings.shared.data?.color
        let messages = State.shared.widgetMessage
        let avatarUrl = State.shared.avatarUrl ?? ""
        headerView.backgroundColor = UIColor(hexString: color?.headerColor ?? "#FFFFFF")
        titleView.textColor = UIColor(hexString: color?.headerFontColor ?? "#000000")
        descriptionView.textColor = UIColor(hexString: color?.headerFontColor ?? "#000000")
        closeButton.textColor = UIColor(hexString: color?.headerFontColor ?? "#000000")
    
        titleView.text = messages?.headerTitle ?? ""
        descriptionView.text = messages?.headerMessage ?? ""
        logoImageView.downloaded(from: avatarUrl)
        
        titleView.font = UIFont(name: "OpenSans-Regular", size: titleView.font.pointSize)
        descriptionView.font = UIFont(name: "OpenSans-Regular", size: descriptionView.font.pointSize)
    }

    func commonInit() {
        let bundle = Bundle(for: Exairon.self)
        let viewFromXib = bundle.loadNibNamed("HeaderView", owner: self, options: nil)![0] as! UIView
        viewFromXib.frame = self.bounds
        addSubview(viewFromXib)
        initialView()
    }
}
