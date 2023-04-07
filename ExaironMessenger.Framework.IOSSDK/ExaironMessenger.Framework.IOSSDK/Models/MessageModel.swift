//
//  MessageModel.swift
//  ExaironFramework
//
//  Created by Exairon on 21.03.2023.
//

import Foundation

// MARK: - Messages
struct Messages: Codable {
    var messages: [Message]
}

// MARK: - Message
struct Message: Codable, Hashable {
    var sender: String
    var type: String
    var timeStamp: Int64? = nil
    var location: Location? = nil
    var text: String? = nil
    var attachment: Attachment? = nil
    var custom: Custom? = nil
    var quick_replies: [QuickReply]? = nil
    var ruleMessage: Bool? = false
}

// MARK: - Location
struct Location: Codable, Hashable {
    var latitude: Double
    var longitude: Double
}

// MARK: - Time
struct Time: Codable, Hashable {
    var timestamp: Int64
}

// MARK: - Attachment
struct Attachment: Codable, Hashable {
    var type: String? = nil
    var payload: Payload? = nil
}

// MARK: - Payload
struct Payload: Codable, Hashable {
    var src: String? = nil
    var videoType: String? = nil
    var mimeType: String? = nil
    var originalname: String? = nil
    var elements: [Element]? = nil
}

// MARK: - Element
struct Element: Codable, Hashable {
    var image_url: String? = nil
    var subtitle: String? = nil
    var title: String? = nil
    var buttons: [QuickReply]? = nil
}

// MARK: - QuickReply
struct QuickReply: Codable, Hashable {
    var content_type: String? = nil
    var payload: String? = nil
    var title: String? = nil
    var type: String? = nil
    var url: String? = nil
}

// MARK: - Custom
struct Custom: Codable, Hashable {
    var data: CustomData? = nil
}

// MARK: -CustomData
struct CustomData: Codable, Hashable {
    var attachment: Attachment? = nil
}
