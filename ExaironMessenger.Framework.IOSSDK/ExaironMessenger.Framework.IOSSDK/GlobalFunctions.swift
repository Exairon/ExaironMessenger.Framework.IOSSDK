//
//  GlobalFunctions.swift
//  ExaironMessenger.Framework.IOSSDK
//
//  Created by Exairon on 7.04.2023.
//

import Foundation
import MapKit

var scrollView: UIScrollView?
var stackView: UIStackView?
var chatsenderView: UIView?
var addMessageToStackView: ((UIView, UIView, String?) -> Void)? = nil

func getMessageView(message: Message) -> UIView? {
    var messageType: String!
    if message.ruleMessage == true {
        return nil
    }
    var view: UIView!
    if message.location != nil {
        messageType = "location"
    } else {
        messageType = message.type
    }
    switch messageType {
    case "text":
        view = TextMessageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), text: message.text ?? "", sender: message.sender)
    case "image":
        view = ImageMessageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), imageUrl: message.attachment?.payload?.src ?? "", sender: message.sender)
    case "video":
        view = getVideoView(message: message)
    case "document":
        view = DocumentMessageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), originalName: message.custom?.data?.attachment?.payload?.originalname ?? "", sender: message.sender, documentUrl: message.custom?.data?.attachment?.payload?.src ?? "")
    case "audio":
        view = AudioMessageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), audioUrl: message.custom?.data?.attachment?.payload?.src ?? "", sender: message.sender)
    case "location":
        let coordinate = CLLocationCoordinate2DMake(message.location?.latitude ?? 0 ,message.location?.longitude ?? 0)
        view = LocationMessageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), coordinate: coordinate, sender: message.sender)
    case "carousel":
        view = CarouselMessageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), cards: message.attachment?.payload?.elements ?? [])
    case "button":
        view = ButtonMessageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), buttonMessage: message.text ?? "", buttons: message.quick_replies ?? [])
    case "survey":
        view = SurveyView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    default:
        view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }
    return view
}

func getTimeView(message: Message) -> UIView {
    let timeView = MessageTimeView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), time: message.timeStamp ?? 0, sender: message.sender)
    return timeView
}

func getUserMap() -> Dictionary<String, String> {
    return ["name": User.shared.name ?? "",
            "surname": User.shared.surname ?? "",
            "email": User.shared.email ?? "",
            "phone": User.shared.phone ?? "",
            "user_unique_id": User.shared.user_unique_id ?? ""]
}

func sendMessage(message: String, payload: String? = nil, ruleMessage: Bool? = false) {
    let newMessage = Message(sender: "user_uttered", type: "text", timeStamp: Int64(NSDate().timeIntervalSince1970 * 1000), text: message, ruleMessage: ruleMessage)
    State.shared.messageArray.append(newMessage)

    let user = getUserMap()
    let messageString: String = payload ?? message
    let sendMessageModel = SocketMessage(channel_id: Exairon.shared.channelId, message: messageString, session_id: readStringStorage(key: "conversationId") ?? "", userToken: readStringStorage(key: "userToken") ?? "", user: user)
    SocketService.shared.socketEmit(eventName: "user_uttered", object: sendMessageModel)
}

func sendFileMessage(filename: String, mimeType: String, fileData: Data) {
    let conversationId: String = readStringStorage(key: "conversationId") ?? ""
    ApiService.shared.uploadFileApiCall(conversationId: conversationId, filename: filename, mimeType: mimeType, fileData: fileData) {result in
        switch result {
        case .failure(let error):
            print(error)
        case .success(let data):
            let file = ["document": data.data.url,
                        "mimeType": data.data.mimeType,
                        "originalname": data.data.originalname]
            let user = getUserMap()
            let sendMessageModel = SocketFileMessage(channel_id: Exairon.shared.channelId, message: file, session_id: readStringStorage(key: "conversationId") ?? "", userToken: readStringStorage(key: "userToken") ?? "", user: user)
            var attachment: Attachment?
            var custom: Custom?
            var messageType = "image"
            let timeStamp = Int64(NSDate().timeIntervalSince1970 * 1000)
            
            if mimeType.contains("image") {
                let payload = Payload(src: data.data.url, originalname: data.data.originalname)
                attachment = Attachment(payload: payload)
            } else {
                let payload = Payload(src: data.data.url, originalname: data.data.originalname)
                let documentAttachment = Attachment(payload: payload)
                let customData = CustomData(attachment: documentAttachment)
                custom = Custom(data: customData)
                messageType = "document"
            }
            
            let newMessage = Message(sender: "user_uttered", type: messageType, timeStamp: timeStamp, attachment: attachment, custom: custom)
            
            SocketService.shared.socketEmit(eventName: "user_uttered", object: sendMessageModel)

            DispatchQueue.main.async {
                State.shared.messageArray.append(newMessage)
            }
        }
    }
}

/*@objc func checkAction(sender : UITapGestureRecognizer) {
    /*present(playerController, animated: true, completion: {
        self.player.play()
    })*/
    let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction(sender:)))
    view.addGestureRecognizer(gesture)
}*/

func getVideoView(message: Message) -> UIView {
    var view: UIView!
    switch message.attachment?.payload?.videoType {
    case "local":
        view = LocalVideoMessageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), videoUrlString: message.attachment?.payload?.src ?? "")
    case "youtube":
        view = YoutubeVideoMessageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), src: message.attachment?.payload?.src ?? "")
    /*case "vimeo":
        VimeoVideoMessageView(src: message.attachment?.payload?.src ?? "")*/
    default:
        view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }
    return view
}

func finishSession() {
    let sessionFinishRequest = SessionRequest(session_id: readStringStorage(key: "conversationId"), channelId: Exairon.shared.channelId)
    SocketService.shared.socketEmit(eventName: "finish_session", object: sessionFinishRequest)
}

func writeMessage(messages: [Message]){
    do {
        // Create JSON Encoder
        let encoder = JSONEncoder()
        // Encode Note
        let messagesss = Messages(messages: messages)
        let data = try encoder.encode(messagesss)
        UserDefaults.standard.set(data, forKey: "messages")
    } catch {
        print("Unable to Encode Note (\(error))")
    }
}

func readMessage() -> [Message] {
    var messages: [Message] = []
    if let data = UserDefaults.standard.data(forKey: "messages") {
        do {
            // Create JSON Decoder
            let decoder = JSONDecoder()
            // Decode data
            let messageData = try decoder.decode(Messages.self, from: data)
            messages = messageData.messages
        } catch {
            print("Unable to Decode Note (\(error))")
        }
    }
    return messages
}

func getNewMessages(timestamp: String, conversationId: String, completion: @escaping(_ messages: MissingMessageResponse) -> Void) {
    ApiService.shared.getNewMessagesApiCall(timestamp: timestamp, conversationId: conversationId) { result in
        switch result {
        case .failure(let error):
            print(error)
        case .success(let data):
            completion(data)
        }
    }
}

func sendSurvey(value: Int, comment: String) {
    let surveyResult = ["value": value,
                        "comment": comment] as [String : Any]
    let surveyRequest = SurveyRequest(channelId: Exairon.shared.channelId, session_id: readStringStorage(key: "conversationId") ?? "", surveyResult: surveyResult)
    SocketService.shared.socketEmit(eventName: "send_survey_result", object: surveyRequest)
    State.shared.oldMessages = []
    State.shared.messageArray = []
    writeStringStorage(value: "", key: "conversationId")
    State.shared.willBack = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        closeFramework()
    }
}

func listenFinishSession() {
    let socket = SocketService.shared.getSocket()
    socket?.off("session_finished")
    socket?.on("session_finished") {data, ack in
        if WidgetSettings.shared.data?.showSurvey != false {
            let time = Int64(NSDate().timeIntervalSince1970 * 1000)
            let surveyMessage = Message(sender: "bot_uttered", type: "survey", timeStamp: time)
            State.shared.messageArray.append(surveyMessage)
            chatsenderView?.alpha = 0
        } else {
            writeMessage(messages: [])
            writeStringStorage(value: "", key: "conversationId")
            State.shared.willBack = true
            closeFramework()
        }
    }
}

func closeFramework() {
    let viewController = State.shared.storyboard?.instantiateViewController(withIdentifier: "ExaironViewController") as! ExaironViewController
    State.shared.navigationController?.pushViewController(viewController, animated: true)
}

func writeStringStorage(value: String, key: String) {
    UserDefaults.standard.set(value, forKey: key)
}

func readStringStorage(key: String) -> String? {
    return UserDefaults.standard.string(forKey: key)
}
