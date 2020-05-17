//
//  PokemonType.swift
//  PokemonKit
//
//  Created by Rhys Morgan on 17/01/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

public enum Type: String, Codable, Hashable {
	case normal = "Normal"
	case fire = "Fire"
	case water = "Water"
	case electric = "Electric"
	case grass = "Grass"
	case ice = "Ice"
	case fighting = "Fighting"
	case poison = "Poison"
	case ground = "Ground"
	case flying = "Flying"
	case psychic = "Psychic"
	case bug = "Bug"
	case rock = "Rock"
	case ghost = "Ghost"
	case dragon = "Dragon"
	case dark = "Dark"
	case steel = "Steel"
	case fairy = "Fairy"
	case typeless = "Typeless"

	public enum Effectiveness: Double, CustomStringConvertible {
		public var description: String {
			switch self {
			case .normallyEffective:
				return "Normally Effective"
			case .notEffective:
				return "Not Effective"
			case .superEffective:
				return "Super Effective"
			case .notVeryEffective:
				return "Not Very Effective"
			}
		}

		case normallyEffective = 1.0
		case superEffective = 2.0
		case notVeryEffective = 0.5
		case notEffective = 0
	}

	public init(using number: Int) {
		switch number {
		case 1: self = .normal
		case 2: self = .fighting
		case 3: self = .flying
		case 4: self = .poison
		case 5: self = .ground
		case 6: self = .rock
		case 7: self = .bug
		case 8: self = .ghost
		case 9: self = .steel
		case 10: self = .fire
		case 11: self = .water
		case 12: self = .grass
		case 13: self = .electric
		case 14: self = .psychic
		case 15: self = .ice
		case 16: self = .dragon
		case 17: self = .dark
		case 18: self = .fairy
		default: self = .typeless
		}
	}

	static let typeEffectiveness: [Type: [Effectiveness: [Type]]] = [
		.normal: [
			.notVeryEffective: [.rock, .steel],
			.notEffective: [.ghost]
		],
		.fire: [
			.superEffective: [.grass, .ice, .steel, .bug],
			.notVeryEffective: [.fire, .water, .rock, .dragon]
		],
		.water: [
			.superEffective: [.fire, .ground, .rock],
			.notVeryEffective: [.water, .grass, .dragon]
		],
		.electric: [
			.superEffective: [.water, .flying],
			.notVeryEffective: [.electric, .grass, .dragon],
			.notEffective: [.ground]
		],
		.grass: [
			.superEffective: [.water, .ground, .rock],
			.notVeryEffective: [.fire, .grass, .poison, .flying, .bug, .dragon, .steel]
		],
		.ice: [
			.superEffective: [.grass, .ground, .flying],
			.notVeryEffective: [.fire, .water, .ice, .steel]
		],
		.fighting: [
			.superEffective: [.normal, .ice, .rock, .dark, .steel],
			.notVeryEffective: [.poison, .flying, .psychic, .bug, .fairy],
			.notEffective: [.ghost]
		],
		.poison: [
			.superEffective: [.grass, .fairy],
			.notVeryEffective: [.poison, .ground, .rock, .ghost],
			.notEffective: [.steel]
		],
		.ground: [
			.superEffective: [.fire, .electric, .poison, .rock, .steel],
			.notVeryEffective: [.grass, .bug],
			.notEffective: [.flying]
		],
		.flying: [
			.superEffective: [.grass, .fighting],
			.notVeryEffective: [.electric, .rock, .steel]
		],
		.psychic: [
			.superEffective: [.fighting, .poison],
			.notVeryEffective: [.psychic, .steel],
			.notEffective: [.dark]
		],
		.bug: [
			.superEffective: [.grass, .psychic, .dark],
			.notVeryEffective: [.fire, .fighting, .flying, .poison, .ghost, .steel, .fairy]
		],
		.rock: [
			.superEffective: [.fire, .ice, .flying, .bug],
			.notVeryEffective: [.fighting, .ground, .steel]
		],
		.ghost: [
			.superEffective: [.psychic, .ghost],
			.notVeryEffective: [.dark],
			.notEffective: [.normal]
		],
		.dragon: [
			.superEffective: [.dragon],
			.notVeryEffective: [.steel],
			.notEffective: [.fairy]
		],
		.dark: [
			.superEffective: [.psychic, .ghost],
			.notVeryEffective: [.fighting, .dark, .fairy]
		],
		.steel: [
			.superEffective: [.ice, .rock, .fairy],
			.notVeryEffective: [.fire, .water, .electric, .steel]
		],
		.fairy: [
			.superEffective: [.fighting, .dragon, .dark],
			.notVeryEffective: [.fire, .poison, .steel]
		]
	]

	public func typeEffectiveness(recipient: Type) -> Effectiveness {
		guard let effectivenessTable = Type.typeEffectiveness[self] else {
			return .normallyEffective
		}

		let key = effectivenessTable
			.filter { $1.contains(recipient) }
			.first?
			.key

		return key ?? .normallyEffective
	}
}
