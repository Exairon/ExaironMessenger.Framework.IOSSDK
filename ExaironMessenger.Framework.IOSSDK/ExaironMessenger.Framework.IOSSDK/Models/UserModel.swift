//
//  UserModel.swift
//  ExaironFramework
//
//  Created by Exairon on 21.03.2023.
//

import Foundation

class User: Encodable, Decodable {
    public static let shared = User()
    var name: String? = nil
    var surname: String? = nil
    var email: String? = nil
    var phone: String? = nil
    var user_unique_id: String? = nil
}
