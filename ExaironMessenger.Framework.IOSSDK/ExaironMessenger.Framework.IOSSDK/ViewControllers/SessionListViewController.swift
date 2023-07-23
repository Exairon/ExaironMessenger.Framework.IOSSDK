//
//  SessionListViewController.swift
//  ExaironMessenger.Framework.IOSSDK
//
//  Created by Exairon on 21.07.2023.
//

import UIKit

class SessionListViewController: UIViewController {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var sessionStackView: UIStackView!
    @IBOutlet weak var sessionScrollView: UIScrollView!
    @IBOutlet weak var messageLabelView: UILabel!
    @IBOutlet weak var newSessionButtonView: UIButton!
    @IBOutlet weak var exaironLogoView: UIImageView!
    
    override func viewDidLoad() {
        let color = WidgetSettings.shared.data?.color
        headerView.backgroundColor = UIColor(hexString: color?.headerColor ?? "#1E1E1E")
        messageLabelView.text = Localization.init().locale(key: "messages")
        messageLabelView.textColor = UIColor(hexString: color?.headerFontColor ?? "#FFFFFF")
        exaironLogoView.downloaded(from: "\(Exairon.shared.src)/assets/images/logo.png")
        newSessionButtonView.setTitle(Localization().locale(key: "startNewSession"), for: .normal)
        
        for session in State.shared.customerSessions {
            DispatchQueue.main.async {
                let frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                let sessionView = SessionListView(frame: frame, avatar: session.assignedTo.avatar, lastMessageText: session.lastMessage.text ?? Localization().locale(key: "unsupportedMessage"), isClosed: session.status == "closed")
                self.sessionStackView?.addArrangedSubview(sessionView)
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    let bottomOffset = CGPoint(x: 0, y: self.sessionScrollView.contentSize.height - self.sessionScrollView.bounds.size.height)
                    self.sessionScrollView.setContentOffset(bottomOffset, animated: true)
                }
            }
        }
        
        
    }

}
