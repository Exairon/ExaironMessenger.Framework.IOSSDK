//
//  SessionRequest.swift
//  ExaironFramework
//
//  Created by Exairon on 21.03.2023.
//

import Foundation
import SocketIO

struct SessionRequest : SocketData, Decodable, Encodable {
    let session_id: String?
    let channelId: String?
    var channel_id: String! = nil

    func socketRepresentation() -> SocketData {
        return ["session_id": session_id, "channelId": channelId, "channel_id": channel_id]
    }
}
