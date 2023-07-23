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
    
    var session: CustomerSession!
    var sessionController: SessionListViewController!
    
    init(frame: CGRect, sessionController: SessionListViewController ,customerSession: CustomerSession) {
        super.init(frame: frame)
        self.session = customerSession
        self.sessionController = sessionController
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.addGestureRecognizer(tapGesture)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        print(session.conversationId)
        State.shared.selectedConversationId = session.conversationId
        State.shared.isClosedSession = session.status == "closed"
        DispatchQueue.main.async {
            let viewController = self.sessionController.storyboard?.instantiateViewController(withIdentifier: "chatViewController") as! ChatViewController
            self.sessionController.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func initialView() {
        let color = WidgetSettings.shared.data?.color

        imageView.downloaded(from:  Exairon.shared.src + "/uploads/channels/" + session.assignedTo.avatar.replacingOccurrences(of: "svg", with: "png"))
        lastMessageLabelView.text = convertHtmlStringToText(text: session.lastMessage.text ?? Localization().locale(key: "unsupportedMessage"))
        customerNameLabelView.text = "Enes Toprak"
        iconView.text = session.status == "closed" ? "►" : "•"
        iconView.textColor = session.status == "closed" ? UIColor(hexString: color?.headerColor ?? "#00FF57") : UIColor(hexString: "#00FF57")

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
