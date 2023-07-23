//
//  SessionListView.swift
//  ExaironMessenger.Framework.IOSSDK
//
//  Created by Exairon on 22.07.2023.
//

import Foundation
import UIKit

class SessionListView: UIView {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var customerNameLabelView: UILabel!
    @IBOutlet weak var lastMessageLabelView: UILabel!
    @IBOutlet weak var iconView: UILabel!
    
    var avatar: String!
    var lastMessageText: String!
    var isClosed: Bool!
    
    init(frame: CGRect, avatar: String, lastMessageText: String, isClosed: Bool) {
        super.init(frame: frame)
        self.avatar = Exairon.shared.src + "/uploads/channels/" + avatar.replacingOccurrences(of: "svg", with: "png")
        self.lastMessageText = convertHtmlStringToText(text: lastMessageText)
        self.isClosed = isClosed
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func initialView() {
        let color = WidgetSettings.shared.data?.color

        imageView.downloaded(from: avatar)
        lastMessageLabelView.text = lastMessageText ?? "Enes"
        customerNameLabelView.text = "Enes Toprak"
        iconView.text = isClosed ? "►" : "•"
        iconView.textColor = isClosed ? UIColor(hexString: color?.headerColor ?? "#00FF57") : UIColor(hexString: "#00FF57")

        borderView.backgroundColor = UIColor(hexString: color?.headerColor ?? "#00FF57")

    }
    
    func commonInit() {
        let bundle = Bundle(for: Exairon.self)
        let viewFromXib = bundle.loadNibNamed("SessionListView", owner: self, options: nil)![0] as! UIView
        viewFromXib.frame = self.bounds
        addSubview(viewFromXib)
        initialView()
    }
    
    func convertHtmlStringToText(text: String) -> String {
        //return text
        return text.replacingOccurrences(of: "&lt;", with: "<").replacingOccurrences(of: "&nbsp;", with: " ").replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
    
}
