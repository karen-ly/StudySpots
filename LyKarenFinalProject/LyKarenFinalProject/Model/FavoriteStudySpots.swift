//
//  FavoriteStudySpots.swift
//  LyKarenFinalProject
//
//  Created by Karen Ly on 11/30/22.
//

import Foundation

// Helper class to contain favorite study spots to easily use Firebase Decodable
struct FavoriteStudySpots : Codable {
    var favStudySpots: [StudySpot]
}
