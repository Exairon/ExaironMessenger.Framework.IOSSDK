//
//  SocketMessageModel.swift
//  ExaironFramework
//
//  Created by Exairon on 21.03.2023.
//

import Foundation
import SocketIO

struct SocketMessage : SocketData {
    let channel_id: String
    let message: String
    let session_id: String
    let userToken: String
    let user: Dictionary<String, String>
    
    func socketRepresentation() -> SocketData {
        return ["channel_id": channel_id, "message": message, "session_id": session_id, "userToken": userToken, "user": user]
    }
}

struct SocketFileMessage : SocketData {
    let channel_id: String
    let message: Dictionary<String, String>
    let session_id: String
    let userToken: String
    let user: Dictionary<String, String>
    
    func socketRepresentation() -> SocketData {
        return ["channel_id": channel_id, "message": message, "session_id": session_id, "userToken": userToken, "user": user]
    }
}

struct SocketLocationMessage : SocketData {
    let channel_id: String
    let message: Dictionary<String, Dictionary<String, Double>>
    let session_id: String
    let userToken: String
    let user: Dictionary<String, String>
    
    func socketRepresentation() -> SocketData {
        return ["channel_id": channel_id, "message": message, "session_id": session_id, "userToken": userToken, "user": user]
    }
}
