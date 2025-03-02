//
//  CatBreed.swift
//  TheCatDex
//
//  Created by Matheus Feola on 01/03/2025.
//

import Foundation

struct CatBreed: Codable, Identifiable, Equatable {
    let id: String
    let name: String?
    let origin: String
    let temperament: String
    let description: String
    let image: CatImage?
    let isFavourite: Bool?
}

struct CatImage: Codable,Identifiable, Equatable {
    let id: String
    let width: Int
    let height: Int
    let url: String
}
