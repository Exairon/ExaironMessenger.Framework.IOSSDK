//
//  ButtonView.swift
//  ExaironFramework
//
//  Created by Exairon on 24.03.2023.
//

import UIKit

class ButtonView: UIView {

    @IBOutlet weak var buttonView: UIButton!
    @IBOutlet weak var buttonUIView: UIView!
    @IBOutlet weak var buttonMainView: UIView!
    
    var button: QuickReply?
    var responseType: String?

    init(frame: CGRect, button: QuickReply, responseType: String) {
        super.init(frame: frame)
        self.button = button
        self.responseType = responseType
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        if button?.type == "postback" {
            sendMessage(message: button?.title ?? "", payload: button?.payload)
        } else {
            if let url = URL(string: button?.url ?? "") {
                UIApplication.shared.open(url)
            }
        }
    }
    
    func initialView() {
        let color = WidgetSettings.shared.data?.color
        buttonUIView.backgroundColor = UIColor(hexString: color?.buttonBackColor ?? "#1E1E1E")
        buttonView.tintColor = UIColor(hexString: color?.buttonFontColor ?? "#FFFFFF")
        buttonView.setTitle(button?.title, for: .normal)
        buttonUIView.layer.borderWidth = 1
        buttonUIView.layer.borderColor = UIColor(hexString: color?.buttonFontColor ?? "#FFFFFF").cgColor
        buttonUIView.layer.cornerRadius = 20
        if responseType == "carousel" {
            buttonMainView.backgroundColor = UIColor(hexString: "#E4E4E7")
        }
        buttonView.titleLabel?.font = UIFont(name: "OpenSans-Regular", size: buttonView.titleLabel?.font.pointSize ?? 16)
    }
    
    func commonInit() {
        let bundle = Bundle(for: Exairon.self)
        let viewFromXib = bundle.loadNibNamed("ButtonView", owner: self, options: nil)![0] as! UIView
        viewFromXib.frame = self.bounds
        addSubview(viewFromXib)
        initialView()
    }

}
