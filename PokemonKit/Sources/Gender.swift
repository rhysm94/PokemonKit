//
//  Gender.swift
//  PokemonKit
//
//  Created by Rhys Morgan on 10/11/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

/// Pokémon genders
public enum Gender: Codable, Hashable {
    case hasGender(Gender)
    case genderless
    
    public enum Gender: String, Codable, Hashable {
        case male
        case female
    }
    
    private enum CodingKeys: CodingKey {
        case base, gender
    }
    
    private enum Base: String, Codable {
        case hasGender, genderless
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let base = try container.decode(Base.self, forKey: .base)
        
        switch base {
        case .hasGender:
            let gender = try container.decode(Gender.self, forKey: .gender)
            self = .hasGender(gender)
        case .genderless:
            self = .genderless
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case let .hasGender(gender):
            try container.encode(Base.hasGender, forKey: .base)
            try container.encode(gender, forKey: .gender)
        case .genderless:
            try container.encode(Base.genderless, forKey: .base)
        }
    }
}

