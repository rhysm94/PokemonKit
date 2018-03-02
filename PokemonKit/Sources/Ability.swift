//
//  Ability.swift
//  PokemonBattleEngineTest
//
//  Created by Rhys Morgan on 22/01/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

import Foundation

public struct Ability: Codable {
	public let name: String
	public let activationMessage: ((Pokemon) -> String)?
	
	public init(name: String, activationMessage: ((Pokemon) -> String)? = nil) {
		self.name = name
		self.activationMessage = activationMessage
	}
	
	enum CodingKeys: CodingKey {
		case name
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(name, forKey: .name)
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.name = try container.decode(String.self, forKey: .name)
		self.activationMessage = Pokedex.default.abilityDescription[self.name]
	}
}

extension Ability: Equatable {
	public static func ==(lhs: Ability, rhs: Ability) -> Bool {
		return lhs.name == rhs.name
	}
}
