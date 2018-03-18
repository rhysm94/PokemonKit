//
//  Action.swift
//  PokemonBattleEngineTest
//
//  Created by Rhys Morgan on 19/02/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

public enum Action: Codable, Equatable {
	case attack(defender: Attack.EffectTarget, attack: Attack)
	case switchTo(Pokemon, from: Pokemon)
	case forceSwitch(Pokemon)
	case recharge
	case run
	
	private struct AttackParams: Codable {
//		let attacker: Pokemon
		let defender: Attack.EffectTarget
		let attack: Attack
	}
	
	private struct SwitchToParams: Codable {
		let pokemon: Pokemon
		let from: Pokemon
	}
	
	private struct ForceSwitchParams: Codable {
		let pokemon: Pokemon
	}
	
	private enum CodingKeys: String, CodingKey {
		case base
		case attackParams
		case switchToParams
		case forceSwitchParams
	}
	
	private enum Base: String, Codable {
		case attack, switchTo, forceSwitch, recharge, run
	}
	
	// MARK:- Codable
	// MARK: Encoder
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		switch self {
		case let .attack(defender, attack):
			try container.encode(Base.attack, forKey: .base)
			try container.encode(AttackParams(defender: defender, attack: attack), forKey: .attackParams)
		case let .switchTo(switchIn, switchOut):
			try container.encode(Base.switchTo, forKey: .base)
			try container.encode(SwitchToParams(pokemon: switchIn, from: switchOut), forKey: .switchToParams)
		case let .forceSwitch(switchIn):
			try container.encode(Base.forceSwitch, forKey: .base)
			try container.encode(ForceSwitchParams(pokemon: switchIn), forKey: .forceSwitchParams)
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
			let attackerParams = try container.decode(AttackParams.self, forKey: .attackParams)
			self = .attack(/*attacker: attackerParams.attacker,*/ defender: attackerParams.defender, attack: attackerParams.attack)
		case .switchTo:
			let switchToParams = try container.decode(SwitchToParams.self, forKey: .switchToParams)
			self = .switchTo(switchToParams.pokemon, from: switchToParams.from)
		case .forceSwitch:
			let forceSwitchParams = try container.decode(ForceSwitchParams.self, forKey: .forceSwitchParams)
			self = .forceSwitch(forceSwitchParams.pokemon)
		case .recharge:
			self = .recharge
		case .run:
			self = .run
		}
	}
	
	public static func ==(lhs: Action, rhs: Action) -> Bool {
		switch (lhs, rhs) {
		case let (.attack(leftDefender, leftAttack), .attack(rightDefender, rightAttack)):
			return leftDefender == rightDefender && leftAttack == rightAttack
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
