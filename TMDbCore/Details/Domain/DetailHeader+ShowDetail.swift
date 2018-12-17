//
//  DetailHeader+ShowDetail.swift
//  TMDbCore
//
//  Created by Hector Aguado on 17/12/2018.
//  Copyright © 2018 Guille Gonzalez. All rights reserved.
//

import Foundation

extension DetailHeader {
    init(show: ShowDetail) {
        title = show.title
        posterPath = show.posterPath
        backdropPath = show.backdropPath
        
        let year = (show.releaseDate?.year).map { String($0) }
        let duration = "\(show.numberOfSeasons) seasons"
        
        metadata = [year, duration].compactMap { $0 }.joined(separator: " - ")
    }
}
