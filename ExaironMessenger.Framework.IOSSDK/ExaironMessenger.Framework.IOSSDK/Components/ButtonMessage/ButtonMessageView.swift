//
//  ButtonMessageView.swift
//  ExaironFramework
//
//  Created by Exairon on 24.03.2023.
//

import UIKit

class ButtonMessageView: UIView {

    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var buttonMessageView: UILabel!
    @IBOutlet weak var buttonListView: UIStackView!
    var buttonMessage: String = ""
    var buttons: [QuickReply] = []
    
    init(frame: CGRect, buttonMessage: String, buttons: [QuickReply]) {
        super.init(frame: frame)
        self.buttonMessage = buttonMessage
        self.buttons = buttons
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func initialView() {
        let color = WidgetSettings.shared.data?.color
        buttonMessageView.textColor = UIColor(hexString: color?.botMessageFontColor ?? "#FFFFFF")
        messageView.backgroundColor = UIColor(hexString: color?.botMessageBackColor ?? "#9500C2")
        messageView.layer.cornerRadius = 10
        messageView.layer.masksToBounds = true
        buttonMessageView.text = buttonMessage
        buttonMessageView.font = UIFont(name: "OpenSans-Regular", size: buttonMessageView.font.pointSize)
        for button in buttons {
            let btn = ButtonView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), button: button, responseType: "button")
            buttonListView.addArrangedSubview(btn)
        }
        
    }
    
    func commonInit() {
        let bundle = Bundle(for: Exairon.self)
        let viewFromXib = bundle.loadNibNamed("ButtonMessageView", owner: self, options: nil)![0] as! UIView
        viewFromXib.frame = self.bounds
        addSubview(viewFromXib)
        initialView()
    }

}
