//
//  Address.swift
//  LyKarenFinalProject
//
//  Created by Karen Ly on 11/27/22.
//
//  Name: Karen Ly
//  Email: karenly@usc.edu

import Foundation

// Represents address format
struct Address : Codable {
    let street: String
    let city: String
    let state: String
    let zipCode: String
    
    // Returns prettily formatted address string
    func getAddress() -> String {
        return "\(street), \(city), \(state) \(zipCode)"
    }
}
