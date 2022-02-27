//
//  Router.swift
//  NASAPictureOfTheDay
//
//  Created by Leelajyothi Ramala on 26/02/22.
//

import Foundation

enum APIKey: String {
    case baseURL = "https://api.nasa.gov/planetary"
    case apod = "/apod"
    
    var urlString: String {
        return "\(APIKey.baseURL.rawValue)\(self.rawValue)"
    }
}


struct Router {
    private let urlSession = URLSession.shared
    private let decoder = JSONDecoder()
    
    func fetchData<T: Decodable>(fromTheURL url: URL, ofType type: T.Type) async throws -> T {
        let (data, _) = try await urlSession.data(from: url, delegate: nil)
        let model = try decoder.decode(T.self, from: data)
        return model
    }
    
    func fetchImageData(fromURL url: URL) async throws -> URL {
        let (url, _) = try await urlSession.download(from: url, delegate: nil)
        return url
    }
}

