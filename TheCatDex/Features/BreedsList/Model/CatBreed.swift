//
//  CatBreed.swift
//  TheCatDex
//
//  Created by Matheus Feola on 01/03/2025.
//

import Foundation
import SwiftData

@Model
class CatBreed: Codable, Identifiable, Equatable {
    @Attribute(.unique)
    var id: String
    var name: String?
    var origin: String
    var temperament: String
    var lifeSpan: String
    var breedDescription: String
    var image: CatImage?
    var isFavourite: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case origin
        case temperament
        case lifeSpan = "life_span"
        case breedDescription = "description"
        case image
        case isFavourite
    }
    
    init(id: String, name: String?, origin: String, temperament: String, lifeSpan: String, breedDescription: String, image: CatImage?, isFavourite: Bool?) {
        self.id = id
        self.name = name
        self.origin = origin
        self.temperament = temperament
        self.lifeSpan = lifeSpan
        self.breedDescription = breedDescription
        self.image = image
        self.isFavourite = isFavourite
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        origin = try container.decode(String.self, forKey: .origin)
        temperament = try container.decode(String.self, forKey: .temperament)
        lifeSpan = try container.decode(String.self, forKey: .lifeSpan)
        breedDescription = try container.decode(String.self, forKey: .breedDescription)
        image = try container.decodeIfPresent(CatImage.self, forKey: .image)
        isFavourite = try container.decodeIfPresent(Bool.self, forKey: .isFavourite)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(origin, forKey: .origin)
        try container.encode(temperament, forKey: .temperament)
        try container.encode(lifeSpan, forKey: .lifeSpan)
        try container.encode(breedDescription, forKey: .breedDescription)
        try container.encode(image, forKey: .image)
        try container.encode(isFavourite, forKey: .isFavourite)
    }
}

extension CatBreed {
    static func == (lhs: CatBreed, rhs: CatBreed) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.origin == rhs.origin &&
        lhs.temperament == rhs.temperament &&
        lhs.lifeSpan == rhs.lifeSpan &&
        lhs.breedDescription == rhs.breedDescription &&
        lhs.image == rhs.image &&
        lhs.isFavourite == rhs.isFavourite
    }
}

@Model
class CatImage: Codable,Identifiable, Equatable {
    var id: String
    var width: Int
    var height: Int
    var url: String
    
    enum CodingKeys: CodingKey {
        case id
        case width
        case height
        case url
    }
    
    init(id: String, width: Int, height: Int, url: String) {
        self.id = id
        self.width = width
        self.height = height
        self.url = url
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        width = try container.decode(Int.self, forKey: .width)
        height = try container.decode(Int.self, forKey: .height)
        url = try container.decode(String.self, forKey: .url)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
        try container.encode(url, forKey: .url)
    }
}
