//
//  ApiService.swift
//  StoryboardService
//
//  Created by Exairon on 20.03.2023.
//

import Foundation

class ApiService {
    public static let shared = ApiService()
    let preferences = UserDefaults.standard

    func getWidgetSettingsApiCall(completion: @escaping (Result<WidgetSettings, ApiErrors>)->Void) {
        guard let url = URL(string: "\(Exairon.shared.src)/api/v1/channels/widgetSettings/\(Exairon.shared.channelId)") else{
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let data = data, error == nil else { return completion(.failure(.NotFound)) }
            guard let widgetSettings = try? JSONDecoder().decode(WidgetSettings.self, from: data) else { return completion(.failure(.DataNotProcessing)) }
            completion(.success(widgetSettings))
        }.resume()
    }
    
    func getNewMessagesApiCall(timestamp: String, conversationId: String, completion: @escaping (Result<MissingMessageResponse, ApiErrors>)->Void) {
        guard let url = URL(string: "\(Exairon.shared.src)/api/v1/messages/getNewMessages/\(timestamp)/\(conversationId)") else{
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let data = data, error == nil else { return completion(.failure(.NotFound)) }
            guard let missingMessageRes = try? JSONDecoder().decode(MissingMessageResponse.self, from: data) else { return completion(.failure(.DataNotProcessing)) }
            completion(.success(missingMessageRes))
        }.resume()
    }
    
    func uploadFileApiCall(conversationId: String, filename: String, mimeType: String, fileData: Data, completion: @escaping (Result<FileUploadResponse, ApiErrors>)->Void) {
        var multipart = MultipartRequest()
        guard let url = URL(string: "\(Exairon.shared.src)/uploads/chat") else{
            return
        }
        for field in [
            "sessionId": conversationId,
        ] {
            multipart.add(key: field.key, value: field.value)
        }
        multipart.add(
            key: "uploadedFileForChat",
            fileName: filename,
            fileMimeType: mimeType,
            fileData: fileData
        )
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue(multipart.httpContentTypeHeadeValue, forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = multipart.httpBody

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let data = data, error == nil else { return completion(.failure(.NotFound)) }
            guard let fileUploadResponse = try? JSONDecoder().decode(FileUploadResponse.self, from: data) else { return completion(.failure(.DataNotProcessing)) }
            completion(.success(fileUploadResponse))
        }.resume()
    }
}

public extension Data {

    mutating func append(
        _ string: String,
        encoding: String.Encoding = .utf8
    ) {
        guard let data = string.data(using: encoding) else {
            return
        }
        append(data)
    }
}

enum ApiErrors: Error{
    case UrlError
    case NotFound
    case DataNotProcessing
}
