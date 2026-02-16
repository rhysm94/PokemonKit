//
//  Ability.swift
//  PokemonKit
//
//  Created by Rhys Morgan on 22/01/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

import Foundation
import Tagged

public struct Ability: Codable, Identifiable {
	public typealias ID = Tagged<Ability, Int64>

	public let id: ID
	public let name: String
	public let description: String
	public let activationMessage: ((Pokemon) -> String)?

	public init(id: ID, name: String, description: String, activationMessage: ((Pokemon) -> String)? = nil) {
		self.id = id
		self.name = name
		self.description = description
		self.activationMessage = activationMessage
	}

	enum CodingKeys: CodingKey {
		case id, name, description
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(name, forKey: .name)
		try container.encode(description, forKey: .description)
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(ID.self, forKey: .id)
		self.name = try container.decode(String.self, forKey: .name)
		self.description = try container.decode(String.self, forKey: .description)
		self.activationMessage = Pokedex.activationMessage[name]
	}
}

extension Ability: Hashable {
	public static func == (lhs: Ability, rhs: Ability) -> Bool {
		lhs.id == rhs.id
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}
