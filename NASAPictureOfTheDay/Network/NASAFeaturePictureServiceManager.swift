//
//  NASAFeaturePictureServiceManager.swift
//  NASAPictureOfTheDay
//
//  Created by Leelajyothi Ramala on 26/02/22.
//

import Foundation

enum FetchPictureDetailsError: Error {
    case urlInvalid
    case fetchDetailsFailed
    
}

protocol NASAFeaturePictureDetailsAPIProvider {
    func fetchPictureDetails(forTheDate date: String) async throws -> PictureDetails
}

struct NASAFeaturePictureDetailsAPIManager: NASAFeaturePictureDetailsAPIProvider {
    let router = Router()
    
    func fetchPictureDetails(forTheDate date: String) async throws -> PictureDetails {
        let urlString = APIKey.apod.urlString
        let queryParams = [URLQueryItem(name: "api_key", value: "18Q6AGbbLMECDBuLYZ48aHCGL8oaqc0EfMCfVs9C"), URLQueryItem(name: "date", value: date)]
        guard let url = URL(string: urlString.appendQueryParams(queryParams)) else {
            throw FetchPictureDetailsError.urlInvalid
        }
        
        return try await self.router.fetchData(fromTheURL: url, ofType: PictureDetails.self)
    }
}

struct TestNASAFeaturePictureDetailsAPIManager: NASAFeaturePictureDetailsAPIProvider {
    let router = Router()

    func fetchPictureDetails(forTheDate date: String) async throws -> PictureDetails {
        if let url = Bundle.main.url(forResource: "APOD", withExtension: "json") {
            return try await self.router.fetchData(fromTheURL: url, ofType: PictureDetails.self)
        } else {
            throw FetchPictureDetailsError.urlInvalid
        }
    }
}
 
