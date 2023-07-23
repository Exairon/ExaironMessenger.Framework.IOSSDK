//
//  State.swift
//  ExaironFramework
//
//  Created by Exairon on 22.03.2023.
//

import Foundation
import MapKit

// MARK: - State
struct State {
    static var shared = State()
    var avatarUrl: String?
    var widgetMessage: WidgetMessage?
    var willBack: Bool = false
    var navigationController: UINavigationController? = nil
    var storyboard: UIStoryboard? = nil
    var tempMessage: Message? = nil
    var oldMessages: [Message] = []
    var isChatOpen: Bool = false
    var isFormOpen: Bool = false
    var customerSessions: [CustomerSession] = []
    var messageArray: [Message] = [] {
        willSet(newVariableValue) {
            writeMessage(messages: newVariableValue)
            if newVariableValue.count > 0 {
                let newMessageView = getMessageView(message: newVariableValue[newVariableValue.count - 1])
                let timeView = getTimeView(message: newVariableValue[newVariableValue.count - 1])
                if newMessageView != nil {
                    addMessageToStackView!(newMessageView!, timeView, newVariableValue[newVariableValue.count - 1].type)
                }
            }
        }
        didSet(oldVariableValue) {
            //print("Eski değer: \(oldVariableValue)")
        }
    }
}
