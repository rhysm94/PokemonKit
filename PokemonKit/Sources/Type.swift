//
//  PokemonType.swift
//  PokemonBattleEngineTest
//
//  Created by Rhys Morgan on 17/01/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

public enum Type: String, Codable {
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
		
		case normallyEffective = 1
		case superEffective = 1.5
		case notVeryEffective = 0.5
		case notEffective = 0
	}
	
	public init(from number: Int) {
		switch number {
		case 1: self = .normal
		default: self = .typeless
		}
	}
	
	public func typeEffectiveness(recipient: Type) -> Effectiveness {
		switch self {
		case .normal:
			if [.ghost].contains(recipient) {
				return .notEffective
			} else if [.rock, .steel].contains(recipient) {
				return .notVeryEffective
			} else {
				return .normallyEffective
			}
		case .fire:
			if [.grass, .ice, .steel, .bug].contains(recipient) {
				return .superEffective
			} else if [.fire, .water, .rock, .dragon].contains(recipient) {
				return .notVeryEffective
			} else {
				return .normallyEffective
			}
		case .water:
			if [.fire, .ground, .rock].contains(recipient) {
				return .superEffective
			} else if [.water, .grass, .dragon].contains(recipient) {
				return .notVeryEffective
			} else {
				return .normallyEffective
			}
		case .electric:
			if [.ground].contains(recipient) {
				return .notEffective
			} else if [.water, .flying].contains(recipient) {
				return .superEffective
			} else if [.electric, .grass, .dragon].contains(recipient) {
				return .notVeryEffective
			} else {
				return .normallyEffective
			}
		case .grass:
			if [.water, .ground, .rock].contains(recipient) {
				return .superEffective
			} else if [.fire, .grass, .poison, .flying, .bug, .dragon, .steel].contains(recipient) {
				return .notVeryEffective
			} else {
				return .normallyEffective
			}
		case .ice:
			if [.grass, .ground, .flying].contains(recipient) {
				return .superEffective
			} else if [.fire, .water, .ice, .steel].contains(recipient) {
				return .notVeryEffective
			} else {
				return .normallyEffective
			}
		case .fighting:
			if [.ghost].contains(recipient) {
				return .notEffective
			} else if [.normal, .ice, .rock, .dark, .steel].contains(recipient) {
				return .superEffective
			} else if [.poison, .flying, .psychic, .bug, .fairy].contains(recipient) {
				return .notVeryEffective
			} else {
				return .normallyEffective
			}
		case .poison:
			if [.steel].contains(recipient) {
				return .notEffective
			} else if [.grass, .fairy].contains(recipient) {
				return .superEffective
			} else if [.poison, .ground, .rock, .ghost].contains(recipient) {
				return .notVeryEffective
			} else {
				return .normallyEffective
			}
		case .ground:
			if [.flying].contains(recipient) {
				return .notEffective
			} else if [.fire, .electric, .poison, .rock, .steel].contains(recipient) {
				return .superEffective
			} else if [.grass, .bug].contains(recipient) {
				return .notVeryEffective
			} else {
				return .normallyEffective
			}
		case .flying:
			if [.grass, .fighting].contains(recipient) {
				return .superEffective
			} else if [.electric, .rock, .steel].contains(recipient) {
				return .notVeryEffective
			} else {
				return .normallyEffective
			}
		case .psychic:
			if [.dark].contains(recipient) {
				return .notEffective
			} else if [.fighting, .poison].contains(recipient) {
				return .superEffective
			} else if [.psychic, .steel].contains(recipient) {
				return .notVeryEffective
			} else {
				return .normallyEffective
			}
		case .bug:
			if [.grass, .psychic, .dark].contains(recipient) {
				return .superEffective
			} else if [.fire, .fighting, .flying, .poison, .ghost, .steel, .fairy].contains(recipient) {
				return .notVeryEffective
			} else {
				return .normallyEffective
			}
		case .rock:
			if [.fire, .ice, .flying, .bug].contains(recipient) {
				return .superEffective
			} else if [.fighting, .ground, .steel].contains(recipient) {
				return .notVeryEffective
			} else {
				return .normallyEffective
			}
		case .ghost:
			if [.normal].contains(recipient) {
				return .notEffective
			} else if [.psychic, .ghost].contains(recipient) {
				return .superEffective
			} else if [.dark].contains(recipient) {
				return .notVeryEffective
			} else {
				return .normallyEffective
			}
		case .dragon:
			if [.fairy].contains(recipient) {
				return .notEffective
			} else if [.dragon].contains(recipient) {
				return .superEffective
			} else if [.steel].contains(recipient) {
				return .notVeryEffective
			} else {
				return .normallyEffective
			}
		case .dark:
			if [.psychic, .ghost].contains(recipient) {
				return .superEffective
			} else if [.fighting, .dark, .fairy].contains(recipient) {
				return .notVeryEffective
			} else {
				return .normallyEffective
			}
		case .steel:
			if [.ice, .rock, .fairy].contains(recipient) {
				return .superEffective
			} else if [.fire, .water, .electric, .steel].contains(recipient) {
				return .notVeryEffective
			} else {
				return .normallyEffective
			}
		case .fairy:
			if [.fighting, .dragon, .dark].contains(recipient) {
				return .superEffective
			} else if [.fire, .poison, .steel].contains(recipient) {
				return .notVeryEffective
			} else {
				return .normallyEffective
			}
		case .typeless:
			return .normallyEffective
		}
	}
}
