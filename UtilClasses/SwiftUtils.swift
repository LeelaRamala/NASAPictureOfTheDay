//
//  SwiftUtils.swift
//  NASAPictureOfTheDay
//
//  Created by Leelajyothi Ramala on 26/02/22.
//

import Foundation
import UIKit

extension String {
    func appendQueryParams(_ params: [URLQueryItem]) -> String {
        var url = URLComponents(string: self)
        url?.queryItems = params
        
        guard let urlString = url?.string else {
            assert(false, "server url with query params is nil.")
            return ""
        }
       
        return urlString
    }
}

struct ImageDownloader {
    static private let router = Router()

    static func fetchImage(fromURL url: URL) async throws -> Data {
        let fileCachePath = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
        
        if let data = try? Data(contentsOf: fileCachePath) {
            return data
        } else {
            let downloadedData = try await self.downloadData(fromURL: url, to: fileCachePath)
            return downloadedData
        }
    }
    
    static func downloadData(fromURL url: URL, to file: URL) async throws -> Data {
        let dataUrl = try await self.router.fetchImageData(fromURL: url)
        
        if FileManager.default.fileExists(atPath: file.path) {
            try FileManager.default.removeItem(at: file)
        }
        
        try FileManager.default.copyItem(at: dataUrl, to: file)
        
        return try Data(contentsOf: dataUrl)
    }
}

extension Date {
    var stringFormat: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
}
