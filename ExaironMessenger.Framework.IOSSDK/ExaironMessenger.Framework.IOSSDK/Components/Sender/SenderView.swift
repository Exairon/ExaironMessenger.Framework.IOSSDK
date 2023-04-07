//
//  SenderView.swift
//  ExaironFramework
//
//  Created by Exairon on 22.03.2023.
//

import UIKit

class SenderView: UIView {

    @IBOutlet weak var senderView: UIView!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var senderButton: UIButton!
    @IBOutlet weak var messageInput: UITextField!
    var messageStackView: UIStackView?
    
    
    init(frame: CGRect, messageStackView: UIStackView) {
        super.init(frame: frame)
        self.messageStackView = messageStackView
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func initialView() {
        // senderButton.layer.zPosition = 1000
        messageInput.placeholder = State.shared.widgetMessage?.placeholder ?? ""
        messageInput.backgroundColor = UIColor(hexString: "#1E1E1E10")
        messageInput.layer.cornerRadius = 10

    }

    func commonInit() {
        let bundle = Bundle(for: Exairon.self)
        let viewFromXib = bundle.loadNibNamed("SenderView", owner: self, options: nil)![0] as! UIView
        viewFromXib.frame = self.bounds
        addSubview(viewFromXib)
        initialView()
    }

}
