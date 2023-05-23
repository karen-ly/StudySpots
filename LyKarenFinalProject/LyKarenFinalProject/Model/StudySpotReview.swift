//
//  StudySpotReview.swift
//  LyKarenFinalProject
//
//  Created by Karen Ly on 11/27/22.
//
//  Name: Karen Ly
//  Email: karenly@usc.edu

import Foundation

// Represents a study spot review
struct StudySpotReview : Codable {
    let userId: String
    let studySpot: StudySpot
    let description: String
    let isFavorite: Bool
    let imageURL: String
}
