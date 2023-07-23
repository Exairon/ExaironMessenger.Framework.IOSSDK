//
//  CustomerSessionResponse.swift
//  ExaironMessenger.Framework.IOSSDK
//
//  Created by Exairon on 21.07.2023.
//

import Foundation

// MARK: - CustomerSessionResponse
struct CustomerSessionResponse: Codable {
    let status: String
    let data: [CustomerSession]
}

