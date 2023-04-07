//
//  FileUploadResponseModel.swift
//  ExaironFramework
//
//  Created by Exairon on 21.03.2023.
//

import Foundation

// MARK: - FileUploadResponse
struct FileUploadResponse: Codable {
    var status: String
    var data: FileReponseData
}

// MARK: - FileReponseData
struct FileReponseData: Codable {
    var url: String
    var mimeType: String
    var originalname: String
}
