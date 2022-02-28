//
//  PictureDetails.swift
//  NASAPictureOfTheDay
//
//  Created by Leelajyothi Ramala on 26/02/22.
//

import Foundation

struct PictureDetails: Decodable {
    let title: String
    let date: String
    let explanation: String
    let url: String
    let mediaType: String
    
    enum CodingKeys: String, CodingKey {
        case mediaType = "media_type"
        case title = "title"
        case date = "date"
        case explanation = "explanation"
        case url = "url"
    }
}

struct ErrorDetails: Decodable {
    let code: Int
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case message = "msg"
    }
}
