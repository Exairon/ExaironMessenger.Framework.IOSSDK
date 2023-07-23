//
//  CustomerSession.swift
//  ExaironMessenger.Framework.IOSSDK
//
//  Created by Exairon on 21.07.2023.
//

import Foundation

// MARK: - CustomerSession
struct CustomerSession: Codable {
    let _id: String
    let lastMessage: Message
    let status: String
    let assignedTo: Operator
    let conversationId: String
}

