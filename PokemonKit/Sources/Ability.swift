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
	public let description: String
	public let activationMessage: ((Pokemon) -> String)?

	public init(name: String, description: String, activationMessage: ((Pokemon) -> String)? = nil) {
		self.name = name
		self.description = description
		self.activationMessage = activationMessage
	}

	enum CodingKeys: CodingKey {
		case name, description
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(name, forKey: .name)
		try container.encode(description, forKey: .description)
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.name = try container.decode(String.self, forKey: .name)
		self.description = try container.decode(String.self, forKey: .description)
		self.activationMessage = Pokedex.activationMessage[name]
	}
}

extension Ability: Hashable {
	public static func == (lhs: Ability, rhs: Ability) -> Bool {
		lhs.name == rhs.name && lhs.description == rhs.description
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(name)
		hasher.combine(description)
	}
}
