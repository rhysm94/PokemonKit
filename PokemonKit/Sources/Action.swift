//
//  Action.swift
//  PokemonBattleEngineTest
//
//  Created by Rhys Morgan on 19/02/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

public enum Action: Codable, Equatable {
	case attack(attack: Attack)
	case switchTo(Pokemon)
	case forceSwitch(Pokemon)
	case recharge
	case run
	
	private enum CodingKeys: String, CodingKey {
		case base
		case attack
		case pokemon
	}
	
	private enum Base: String, Codable {
		case attack, switchTo, forceSwitch, recharge, run
	}
	
	// MARK:- Codable
	// MARK: Encoder
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		switch self {
		case let .attack(attack):
			try container.encode(Base.attack, forKey: .base)
			try container.encode(attack, forKey: .attack)//(AttackParams(attack: attack), forKey: .attackParams)
		case .switchTo(let switchIn):
			try container.encode(Base.switchTo, forKey: .base)
			try container.encode(switchIn, forKey: .pokemon)
		case .forceSwitch(let switchIn):
			try container.encode(Base.forceSwitch, forKey: .base)
			try container.encode(switchIn, forKey: .pokemon)
		case .recharge:
			try container.encode(Base.recharge, forKey: .base)
		case .run:
			try container.encode(Base.run, forKey: .base)
		}
	}
	
	// MARK: Decodable
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let base = try container.decode(Base.self, forKey: .base)
		
		switch base {
		case .attack:
			let attack = try container.decode(Attack.self, forKey: .attack)
			self = .attack(attack: attack)
		case .switchTo:
			let pokemon = try container.decode(Pokemon.self, forKey: .pokemon)
			self = .switchTo(pokemon)
		case .forceSwitch:
			let pokemon = try container.decode(Pokemon.self, forKey: .pokemon)
			self = .forceSwitch(pokemon)
		case .recharge:
			self = .recharge
		case .run:
			self = .run
		}
	}
	
	public static func ==(lhs: Action, rhs: Action) -> Bool {
		switch (lhs, rhs) {
		case let (.attack(leftAttack), .attack(rightAttack)):
			return leftAttack == rightAttack
		case let (.switchTo(leftPokemon), .switchTo(rightPokemon)):
			return leftPokemon == rightPokemon
		case (.recharge, .recharge):
			return true
		case (.run, .run):
			return true
		default:
			return false
		}
	}
}
