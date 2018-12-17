//
//  ShowDetail.swift
//  TMDbCore
//
//  Created by Hector Aguado on 17/12/2018.
//  Copyright © 2018 Guille Gonzalez. All rights reserved.
//

import Foundation

struct ShowDetail: Decodable {
    let backdropPath: String?
    let identifier: Int64
    let overview: String?
    let posterPath: String?
    let releaseDate: Date?
    let numberOfSeasons: Int
    let title: String
    let credits: Credits?
    
    private enum CodingKeys: String, CodingKey {
        case backdropPath = "backdrop_path"
        case identifier = "id"
        case overview
        case posterPath = "poster_path"
        case releaseDate = "first_air_date"
        case numberOfSeasons = "number_of_seasons"
        case title = "name"
        case credits
    }
}
