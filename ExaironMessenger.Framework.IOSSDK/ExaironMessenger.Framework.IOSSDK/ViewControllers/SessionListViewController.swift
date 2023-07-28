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
        let widgetSettings = WidgetSettings.shared.data
        headerView.backgroundColor = UIColor(hexString: widgetSettings?.color.headerColor ?? "#1E1E1E")
        messageLabelView.text = Localization.init().locale(key: "messages")
        messageLabelView.textColor = UIColor(hexString: widgetSettings?.color.headerFontColor ?? "#FFFFFF")
        exaironLogoView.downloaded(from: "\(Exairon.shared.src)/assets/images/logo.png")
        newSessionButtonView.setTitle(Localization().locale(key: "startNewSession"), for: .normal)
        
        if State.shared.customerSessions.contains(where: { session in
            session.status != "closed"
        }) {
            newSessionButtonView.isHidden = true
        }
        
        if widgetSettings?.whiteLabelWidget == true {
            exaironLogoView.isHidden = true
        }
        
        newSessionButtonView.addTarget(self, action: #selector(newSessionStart), for: .touchUpInside)
        
        for session in State.shared.customerSessions {
            DispatchQueue.main.async {
                let frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                let sessionView = SessionListView(frame: frame, sessionController: self, customerSession: session)
                self.sessionStackView?.addArrangedSubview(sessionView)
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    let bottomOffset = CGPoint(x: 0, y: self.sessionScrollView.contentSize.height - self.sessionScrollView.bounds.size.height)
                    self.sessionScrollView.setContentOffset(bottomOffset, animated: true)
                }
            }
        }
    }
    
    @objc func newSessionStart() {
        State.shared.isNewSession = true
        State.shared.isClosedSession = false
        State.shared.selectedConversationId = nil
        if WidgetSettings.shared.data?.showUserForm == false || self.checkCustomerValues(formFields: WidgetSettings.shared.data?.formFields) {
            SocketService.shared.connect { connection in
                let socket = SocketService.shared.getSocket()
                socket?.off(clientEvent: .connect)
                if connection {
                    self.sessionRequest() { socketResponse in
                        DispatchQueue.main.async {
                            let userToken: String = readStringStorage(key: "userToken") ?? UUID().uuidString
                            let userInfo = readUserInfo()
                            writeStringStorage(value: userToken, key: "userToken")
                            User.shared.name = Exairon.shared.name != nil && Exairon.shared.name != "" ? Exairon.shared.name : userInfo?.name
                            User.shared.surname = Exairon.shared.surname != nil && Exairon.shared.surname != "" ? Exairon.shared.surname : userInfo?.surname
                            User.shared.email = Exairon.shared.email != nil && Exairon.shared.email != "" ? Exairon.shared.email : userInfo?.email
                            User.shared.phone = Exairon.shared.phone != nil && Exairon.shared.phone != "" ? Exairon.shared.phone : userInfo?.phone
                            User.shared.user_unique_id = Exairon.shared.user_unique_id != nil && Exairon.shared.user_unique_id != "" ? Exairon.shared.user_unique_id : userInfo?.user_unique_id
                            writeUserInfo()
                            State.shared.oldMessages = []
                            State.shared.messageArray = []
                            writeMessage(messages: State.shared.messageArray)

                            self.changePage(identifier: "chatViewController")
                        }
                    }
                }
                
            }
        } else {
            self.changePage(identifier: "formViewController")
        }

    }
    
    func checkCustomerValues(formFields: FormFields?) -> Bool {
        let userInfo = readUserInfo()
        if formFields == nil {
            return false
        }
        
        let checkName = !formFields!.showNameField || !(Exairon.shared.name == nil || Exairon.shared.name == "") || !(userInfo?.name == nil || userInfo?.name == "")
        let checkSurname = !formFields!.showSurnameField || !(Exairon.shared.surname == nil || Exairon.shared.surname == "") || !(userInfo?.surname == nil || userInfo?.surname == "")
        let checkEmail = !formFields!.showEmailField || !(Exairon.shared.email == nil || Exairon.shared.email == "") || !(userInfo?.email == nil || userInfo?.email == "")
        let checkPhone = !formFields!.showPhoneField || !(Exairon.shared.phone == nil || Exairon.shared.phone == "") || !(userInfo?.phone == nil || userInfo?.phone == "")
        return checkName && checkSurname && checkEmail && checkPhone
    }
    
    func changePage(identifier: String) {
            DispatchQueue.main.async {
                var viewController: UIViewController? = nil
                switch(identifier) {
                case "chatViewController":
                    viewController = self.storyboard?.instantiateViewController(withIdentifier: identifier) as! ChatViewController
                    break
                case "formViewController":
                    viewController = self.storyboard?.instantiateViewController(withIdentifier: identifier) as! FormViewController
                    break
                case "sessionListViewController":
                    viewController = self.storyboard?.instantiateViewController(withIdentifier: identifier) as! SessionListViewController
                    break
                default: break
                }
                if viewController != nil {
                    if !State.shared.isChatOpen {
                        self.navigationController?.pushViewController(viewController!, animated: true)
                    }
                    State.shared.isChatOpen = true
                }
            }
            
        }
        
        func sessionRequest(completion: @escaping (_ success: String) -> Void) {
            let sessionRequestObj = SessionRequest(session_id: "", channelId: Exairon.shared.channelId, channel_id: Exairon.shared.channelId)
            SocketService.shared.socketEmit(eventName: "session_request", object: sessionRequestObj)
            let socket = SocketService.shared.getSocket()
            socket?.once("session_confirm") {data, ack in
                guard let socketResponse = data[0] as? String else {
                    return
                }
                writeMessage(messages: [])
                writeStringStorage(value: socketResponse, key: "conversationId")
                completion(socketResponse)
            }
        }
}
