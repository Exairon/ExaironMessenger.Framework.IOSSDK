//
//  TextMessageView.swift
//  ExaironFramework
//
//  Created by Exairon on 23.03.2023.
//

import UIKit

class TextMessageView: UIView {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var textView: UIView!
    var text: String!
    var sender: String!
    
    init(frame: CGRect, text: String, sender: String) {
        super.init(frame: frame)
        self.text = text
        self.sender = sender
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func initialView() {
        let color = WidgetSettings.shared.data?.color
        var textColor: String!
        var backColor: String!

        if sender == "bot_uttered" {
            textColor = color?.botMessageFontColor ?? "#FFFFFF"
            backColor = color?.botMessageBackColor ?? "#9500c2"
        } else {
            textColor = color?.userMessageFontColor ?? "#FFFFFF"
            backColor = color?.userMessageBackColor ?? "#9500c2"
        }
        textLabel.font = UIFont(name: "OpenSans-Regular", size: textLabel.font.pointSize)
        textLabel.text = convertHtmlStringToText(text: text ?? "")
        textLabel.textColor = UIColor(hexString: textColor)
        textView.backgroundColor = UIColor(hexString: backColor)
        textView.layer.cornerRadius = 10
        textView.layer.masksToBounds = true

        
        let margins = mainView.layoutMarginsGuide
        if sender == "bot_uttered" {
            textView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 10).isActive = true
        } else {
            textView.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -10).isActive = true
        }

    }
    
    func convertHtmlStringToText(text: String) -> String {
        //return text
        return text.replacingOccurrences(of: "&lt;", with: "<").replacingOccurrences(of: "&nbsp;", with: " ").replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
    
    func commonInit() {
        let bundle = Bundle(for: Exairon.self)
        let viewFromXib = bundle.loadNibNamed("TextMessageView", owner: self, options: nil)![0] as! UIView
        viewFromXib.frame = self.bounds
        addSubview(viewFromXib)
        initialView()
    }

}
