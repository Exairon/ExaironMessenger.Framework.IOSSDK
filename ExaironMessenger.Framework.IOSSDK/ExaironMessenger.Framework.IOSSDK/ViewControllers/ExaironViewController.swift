//
//  ExaironViewController.swift
//  ExaironMessenger.Framework.IOSSDK
//
//  Created by Exairon on 7.04.2023.
//

import UIKit

public class ExaironViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var splashIconView: UIImageView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        splashIconView.image = UIImage(named:"exa_splash.png")
        SocketService.shared.connect { connection in
            let socket = SocketService.shared.getSocket()
            socket?.off(clientEvent: .connect)
            if connection {
                ApiService.shared.getWidgetSettingsApiCall(){ widgetSettings in
                    switch(widgetSettings) {
                    case .failure(let error):
                        print(error)
                    case .success(let data):
                        State.shared.avatarUrl = Exairon.shared.src + "/uploads/channels/" + (data.data?.avatar ?? "")

                        for _message in data.data?.messages ?? [] {
                            if(_message.lang == Exairon.shared.language) {
                                State.shared.widgetMessage = _message
                            }
                        }
                        if (State.shared.widgetMessage == nil) {
                            State.shared.widgetMessage = data.data?.messages[0]
                        }
                        WidgetSettings.shared.status = data.status
                        WidgetSettings.shared.data = data.data
                        WidgetSettings.shared.geo = data.geo
                        WidgetSettings.shared.triggerRules = data.triggerRules
                        
                        
                        let oldConversationId = readStringStorage(key: "conversationId")

                        if oldConversationId == nil || oldConversationId == "" {
                            if data.data?.showUserForm == false || self.checkCustomerValues(formFields: data.data?.formFields) {
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
                                        self.changePage(identifier: "chatViewController")
                                    }
                                }
                            } else {
                                self.changePage(identifier: "formViewController")
                            }
                        } else {
                            self.sessionRequest() { socketResponse in
                                DispatchQueue.main.async {
                                    let userInfo = readUserInfo()
                                    User.shared.name = Exairon.shared.name != nil && Exairon.shared.name != "" ? Exairon.shared.name : userInfo?.name
                                    User.shared.surname = Exairon.shared.surname != nil && Exairon.shared.surname != "" ? Exairon.shared.surname : userInfo?.surname
                                    User.shared.email = Exairon.shared.email != nil && Exairon.shared.email != "" ? Exairon.shared.email : userInfo?.email
                                    User.shared.phone = Exairon.shared.phone != nil && Exairon.shared.phone != "" ? Exairon.shared.phone : userInfo?.phone
                                    User.shared.user_unique_id = Exairon.shared.user_unique_id != nil && Exairon.shared.user_unique_id != "" ? Exairon.shared.user_unique_id : userInfo?.user_unique_id
                                    writeUserInfo()
                                    var messages = readMessage()

                                    if (oldConversationId == socketResponse && messages.count > 0) {
                                        let timestamp = String(messages[messages.count - 1].timeStamp ?? Int64(NSDate().timeIntervalSince1970 * 1000))
                                        let conversationId = readStringStorage(key: "conversationId") ?? ""
                                        getNewMessages(timestamp: timestamp, conversationId: conversationId) { newMessages in
                                            if newMessages == nil {
                                                self.changePage(identifier: "chatViewController")
                                                return
                                            }
                                            for message in newMessages!.data {
                                                messages.append(message)
                                            }
                                            State.shared.oldMessages = messages
                                            self.changePage(identifier: "chatViewController")
                                        }
                                    }
                                    else {
                                        self.changePage(identifier: "chatViewController")
                                    }
                                }
                            }
                        }
                    }
                }
            
            }
        }
    }
    
    
    @objc func dismissFrameworkNavigationController() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
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
        let conversationId = readStringStorage(key: "conversationId")
        let sessionRequestObj = SessionRequest(session_id: conversationId, channelId: Exairon.shared.channelId)
        SocketService.shared.socketEmit(eventName: "session_request", object: sessionRequestObj)
        let socket = SocketService.shared.getSocket()
        socket?.once("session_confirm") {data, ack in
            guard let socketResponse = data[0] as? String else {
                return
            }
            if socketResponse != conversationId {
                writeMessage(messages: [])
            }
            writeStringStorage(value: socketResponse, key: "conversationId")
            completion(socketResponse)
        }
    }
}
