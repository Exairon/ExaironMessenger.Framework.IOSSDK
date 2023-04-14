//
//  ChatViewController.swift
//  ExaironMessenger.Framework.IOSSDK
//
//  Created by Exairon on 7.04.2023.
//

import UIKit
import MobileCoreServices
import SocketIO

class ChatViewController: UIViewController {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var senderView: UIView!
    @IBOutlet weak var messageStackView: UIStackView!
    @IBOutlet weak var messageScrollView: UIScrollView!
    @IBOutlet weak var bgView: UIView!

    @IBOutlet weak var plusButton: UILabel!
    @IBOutlet weak var senderButton: UILabel!
    @IBOutlet weak var messageInput: UITextView!
    let placeholderLabel = UILabel()
    var statusBarBackgroundColor: UIColor?
    var previousStatusBarStyle: UIStatusBarStyle?
    var disconnectTime: Int64? = nil

    var socket: SocketIOClient? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
            view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        let fontURL = Bundle(for: Exairon.self).url(forResource: "OpenSans-Regular", withExtension: "ttf")
        CTFontManagerRegisterFontsForURL(fontURL! as CFURL, .process, nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)

        
        let color = WidgetSettings.shared.data?.color
        let header = HeaderView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        let headerMargins = headerView.layoutMarginsGuide
        header.headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(header.headerView)
        headerView.backgroundColor = UIColor(hexString: color?.headerColor ?? "#FFFFFF")
        setConstraint(view: header.headerView, margins: headerMargins)
        bgView.backgroundColor = UIColor(hexString: color?.headerColor ?? "#FFFFFF")

        let tapClose = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.closeButtonPressed))
        header.closeButton.isUserInteractionEnabled = true
        header.closeButton.addGestureRecognizer(tapClose)
        
        let tapBack = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.backButtonPressed))
        header.backButton.isUserInteractionEnabled = true
        header.backButton.addGestureRecognizer(tapBack)
        
        //messageInput.placeholder = State.shared.widgetMessage?.placeholder ?? ""
        messageInput.backgroundColor = UIColor(hexString: "#1E1E1E10")
        messageInput.layer.cornerRadius = 10
        messageInput.addSubview(placeholderLabel)
        placeholderLabel.text = State.shared.widgetMessage?.placeholder ?? ""
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.font = messageInput.font
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin = CGPoint(x: 5, y: messageInput.font!.pointSize / 2)
        
        // Set the text view delegate
        messageInput.delegate = self
        
        addMessageToStackView = addNewMessageToStack
        senderButton.layer.cornerRadius = 20
        senderButton.clipsToBounds = true
        
        let tapSender = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.sendMessageClicked))
        senderButton.isUserInteractionEnabled = true
        senderButton.addGestureRecognizer(tapSender)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.openFileBottomSheet))
        plusButton.isUserInteractionEnabled = true
        plusButton.addGestureRecognizer(tap)
        //plusButton.titleLabel?.font = .systemFont(ofSize: 50.0, weight: .medium)

        State.shared.navigationController = self.navigationController
        State.shared.storyboard = self.storyboard

        if State.shared.oldMessages.count > 0 {
            State.shared.messageArray = []
            for message in State.shared.oldMessages {
                State.shared.messageArray.append(message)
            }
            State.shared.oldMessages = []
        }
        
        scrollView = messageScrollView
        stackView = messageStackView
        chatsenderView = senderView
        
        if WidgetSettings.shared.data?.showAttachments == false {
            plusButton.widthAnchor.constraint(equalToConstant: 0).isActive = true
            plusButton.heightAnchor.constraint(equalToConstant: 0).isActive = true
            
        }
        
        if WidgetSettings.shared.triggerRules?.count ?? 0 > 0 {
            if State.shared.messageArray.count == 0 && WidgetSettings.shared.triggerRules?[0].enabled == true {
                sendMessage(message: WidgetSettings.shared.triggerRules?[0].text ?? "", ruleMessage: true)
            }
        }
        listenNewMessages()
        listenFinishSession()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        messageScrollView.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            if #available(iOS 13.0, *) {
                let statusBar = UIView(frame: (UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame)!)
                statusBarBackgroundColor = statusBar.backgroundColor
                statusBar.backgroundColor = UIColor(hexString: WidgetSettings.shared.data?.color.headerColor ?? "#FF0000")
                UIApplication.shared.keyWindow?.addSubview(statusBar)
            } else {
                guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBar") as? UIView else { return }
                statusBarBackgroundColor = statusBar.backgroundColor
                statusBar.backgroundColor = UIColor(hexString: WidgetSettings.shared.data?.color.headerColor ?? "#FF0000")
            }
        }
        
        /*
        if let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
            statusBar.backgroundColor = UIColor(hexString: WidgetSettings.shared.data?.color.headerColor ?? "#FF0000")
        }*/
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        State.shared.isChatOpen = false
        do {
            if #available(iOS 13.0, *) {
                let statusBar = UIView(frame: (UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame)!)
                statusBar.backgroundColor = nil
                UIApplication.shared.keyWindow?.addSubview(statusBar)
            } else {
                guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBar") as? UIView else { return }
                statusBar.backgroundColor = statusBarBackgroundColor
            }
        }
        /*
        if let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
            statusBar.backgroundColor = nil
        }*/
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func appDidEnterBackground() {
        disconnectTime = Int64(NSDate().timeIntervalSince1970 * 1000)
    }

    @objc func appWillEnterForeground() {
        let conversationId = readStringStorage(key: "conversationId") ?? ""
        let timestamp = String(State.shared.messageArray.last?.timeStamp ?? Int64(NSDate().timeIntervalSince1970 * 1000))
        /*getNewMessages(timestamp: timestamp, conversationId: conversationId) { messages in
            for message in messages.data {
                DispatchQueue.main.async {
                    State.shared.messageArray.append(message)
                }
            }
        }*/
    }
    
    var anchor: NSLayoutConstraint?
    
    @objc func keyboardWillHide(notification: NSNotification) {
        view.endEditing(true)
        UIView.animate(withDuration: 0.3) {
            self.anchor?.isActive = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let bottomOffset = CGPoint(x: 0, y: self.messageScrollView.contentSize.height - self.messageScrollView.bounds.size.height)
                self.messageScrollView.setContentOffset(bottomOffset, animated: true)
            }
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            UIView.animate(withDuration: 0.3) {
                let margins = self.view.layoutMarginsGuide
                if self.anchor == nil {
                    self.anchor = self.senderView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant:  CGFloat(-1 * keyboardRectangle.height))
                }
                self.anchor?.isActive = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    let bottomOffset = CGPoint(x: 0, y: self.messageScrollView.contentSize.height - self.messageScrollView.bounds.size.height)
                    self.messageScrollView.setContentOffset(bottomOffset, animated: true)
                }
            }
        }
    }

    @IBAction func openFileBottomSheet(_ sender: Any) {
        let alert = UIAlertController(title: Localization().locale(key: "chatActions"), message: "", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: Localization().locale(key: "camera"), style: .default, handler: { action in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            self.present(picker, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: Localization().locale(key: "gallery"), style: .default, handler: { action in
            // GALLERY
           let picker = UIImagePickerController()
           picker.sourceType = .photoLibrary
           picker.delegate = self
            self.present(picker, animated: true)
        }))

        alert.addAction(UIAlertAction(title: Localization().locale(key: "file"), style: .default, handler: { action in
            // DOCUMENT
            let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypePDF as String], in: .import)
            documentPicker.delegate = self
            self.present(documentPicker, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: Localization().locale(key: "location"), style: .default, handler: { action in
            let bundle = Bundle(for: Exairon.self)
            let storyboard = UIStoryboard(name: "LocationView", bundle: bundle)
            let controller = storyboard.instantiateViewController(withIdentifier: "locationViewController") as! LocationViewController
            self.present(controller, animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: Localization().locale(key: "cancel"), style: .destructive, handler: { action in
            alert.dismiss(animated: true)
        }))

        present(alert, animated: true, completion: nil)
        
    }
    
    func addNewMessageToStack(messageView: UIView, timeView: UIView, messageType: String?) {
        DispatchQueue.main.async {
            self.messageStackView?.addArrangedSubview(messageView)
            self.messageStackView?.addArrangedSubview(timeView)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let bottomOffset = CGPoint(x: 0, y: self.messageScrollView.contentSize.height - self.messageScrollView.bounds.size.height)
                self.messageScrollView.setContentOffset(bottomOffset, animated: true)
            }
        }
    }
    
    
    @objc func backButtonPressed () {
        if self.navigationController != nil {
            if let navigationController = self.navigationController {
                let viewControllers = navigationController.viewControllers
                let targetIndex = viewControllers.count - (State.shared.isFormOpen ? 4 : 3)
                State.shared.isFormOpen = false
                if targetIndex >= 0 && targetIndex < viewControllers.count {
                    let targetViewController = viewControllers[targetIndex]
                    navigationController.popToViewController(targetViewController, animated: true)
                }
            }
        }
    }
    
    @objc func closeButtonPressed () {
        if State.shared.messageArray.last?.type == "survey" {
            return
        }
        // create the alert
        let alert = UIAlertController(title: Localization.init().locale(key: "sessionFinishMessage"), message: "", preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: Localization.init().locale(key: "cancel"), style: UIAlertAction.Style.default, handler: nil))

        // add an action (button)
        alert.addAction(UIAlertAction(title: Localization.init().locale(key: "yes"), style: UIAlertAction.Style.destructive, handler: {action in
            finishSession()
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func sendMessageClicked(_ sender: Any) {
        let cleanedText = messageInput.text.trimmingCharacters(in: .whitespacesAndNewlines)

        if !cleanedText.isEmpty {
            sendMessage(message: messageInput.text!)
            messageInput.text = ""
        }
    }
        
    func addMessageFromSocket(data: [Any]) {
        do {
            let dat = try JSONSerialization.data(withJSONObject:data)
            let res = try JSONDecoder().decode([Message].self,from:dat)
            var botMessage = res[0]
            botMessage.timeStamp = Int64(NSDate().timeIntervalSince1970 * 1000)
            botMessage.sender = "bot_uttered"
            State.shared.messageArray.append(botMessage)
          }
          catch {
                print(error)
          }
    }
    
    func listenNewMessages() {
        socket = SocketService.shared.getSocket()
        //sendMessage(message: "carousel")
        socket?.off("bot_uttered")
        socket?.off("system_uttered")
        socket?.off("disconnect")
        socket?.off("connect")
        socket?.on("bot_uttered") {data, ack in
            self.addMessageFromSocket(data: data)
        }
        socket?.on("system_uttered") {data, ack in
            self.addMessageFromSocket(data: data)
        }
        socket?.on("disconnect") {data, ack in
            self.disconnectTime = Int64(NSDate().timeIntervalSince1970 * 1000)
        }
        socket?.on("connect") { data, ack in
            let conversationId = readStringStorage(key: "conversationId") ?? ""
            let sessionRequestObj = SessionRequest(session_id: conversationId, channelId: Exairon.shared.channelId)
            var timestamp: String = self.disconnectTime != nil ? String(self.disconnectTime!) : String(State.shared.messageArray.last?.timeStamp ?? Int64(NSDate().timeIntervalSince1970 * 1000))
            let _timestamp = (Int64(timestamp) ?? Int64(NSDate().timeIntervalSince1970 * 1000)) + 1
            timestamp = String(_timestamp)
            SocketService.shared.socketEmit(eventName: "session_request", object: sessionRequestObj)
            getNewMessages(timestamp: timestamp, conversationId: conversationId) { messages in
                for message in messages.data {
                    DispatchQueue.main.async {
                        State.shared.messageArray.append(message)
                    }
                }
            }
        }
    }
    
    func setConstraint(view: UIView, margins: UILayoutGuide) {
        view.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
        view.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
    }

}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        if let data = image.jpegData(compressionQuality: 0.1) {
            sendFileMessage(filename: "\(UUID().uuidString).jpeg", mimeType: "image/jpeg", fileData: data)
        }
    }
}

extension ChatViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let fileUrl = urls.first else { return }
        do {
            let resources = try fileUrl.resourceValues(forKeys:[.fileSizeKey])
            if resources.fileSize ?? 0 <= 1000000 {
                let fileData = try Data(contentsOf: fileUrl)
                let mimeType = fileUrl.relativeString.mimeType()
                sendFileMessage(filename: fileUrl.lastPathComponent, mimeType: mimeType, fileData: fileData)
            }
            
        } catch {
            print(error)
        }
    }
}

extension ChatViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}
