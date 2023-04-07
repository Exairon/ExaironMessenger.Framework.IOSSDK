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
   let channelId: String

   func socketRepresentation() -> SocketData {
       return ["session_id": session_id, "channelId": channelId]
   }
}
