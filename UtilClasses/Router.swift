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

protocol APIProvider {
    func handleJsonResponse<T: Decodable>(_ response: Data, ofType type: T.Type) throws -> JSONResult<T>
}


extension APIProvider {
     func handleJsonResponse<T: Decodable>(_ response: Data, ofType type: T.Type) -> JSONResult<T> {
        let jsonDecoder = JSONDecoder()
        
        if let result = try? jsonDecoder.decode(T.self, from: response) {
            return JSONResult.success(result)
        } else if let errorResponse = try? jsonDecoder.decode(ErrorDetails.self, from: response) {
            return JSONResult.failure(errorResponse)
        } else {
            return JSONResult.parserError
        }
    }
}


struct Router {
    private let urlSession = URLSession.shared
    private let decoder = JSONDecoder()
    
    func fetchData(fromTheURL url: URL) async throws -> Data {
        let (data, _) = try await urlSession.data(from: url, delegate: nil)
        return data
    }
    
    func fetchImageData(fromURL url: URL) async throws -> URL {
        let (url, _) = try await urlSession.download(from: url, delegate: nil)
        return url
    }
}

enum JSONResult<Value> {
    case failure(ErrorDetails)
    case success(Value)
    case parserError
}
