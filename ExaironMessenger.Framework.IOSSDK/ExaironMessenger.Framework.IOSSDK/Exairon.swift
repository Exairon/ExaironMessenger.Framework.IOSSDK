//
//  Exairon.swift
//  ExaironMessenger.Framework.IOSSDK
//
//  Created by Exairon on 7.04.2023.
//

import Foundation

public class Exairon {
    public static let shared = Exairon()
    public var channelId: String = ""
    public var src: String = ""
    public var language: String = "tr"
    public var name: String? = nil
    public var surname: String? = nil
    public var phone: String? = nil
    public var email: String? = nil
    public var user_unique_id: String? = nil
}

