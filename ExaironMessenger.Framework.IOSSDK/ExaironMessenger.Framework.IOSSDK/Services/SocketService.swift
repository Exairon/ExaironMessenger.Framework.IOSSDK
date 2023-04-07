//
//  SocketService.swift
//  ExaironFramework
//
//  Created by Exairon on 21.03.2023.
//

import Foundation
import SocketIO

class SocketService {
    public static let shared = SocketService()
    var manager: SocketManager? = nil
    
    func setSocketManager() {
        manager = SocketManager(socketURL: URL(string: Exairon.shared.src)!, config: [.log(false), .path("/socket")])
    }
    
    func connect(completion: @escaping (_ success: Bool) -> Void) {
        if manager != nil {
            completion(true)
        } else {
            setSocketManager()
            if (manager != nil) {
                let socket = manager?.defaultSocket
                socket?.on(clientEvent: .connect) {data, ack in
                    completion(true)
                }
                socket?.connect()
            }
        }
    }

    func socketEmit(eventName: String, object: SocketData) {
        if (manager != nil) {
            let socket = manager?.defaultSocket
            socket?.emit(eventName, object)
        }
        
    }

    func getSocket() -> SocketIOClient? {
        if manager != nil {
            return manager?.defaultSocket
        } else {
            manager = SocketManager(socketURL: URL(string: Exairon.shared.src)!, config: [.log(false), .path("/socket")])
            return manager?.defaultSocket
        }
    }
}
