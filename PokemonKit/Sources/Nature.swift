//
//  Nature.swift
//  PokemonBattleEngineTest
//
//  Created by Rhys Morgan on 08/01/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

import Foundation

public enum Nature: String, Codable {
	case adamant
	case bashful
	case bold
	case brave
	case calm
	case careful
	case docile
	case gentle
	case hardy
	case hasty
	case impish
	case jolly
	case lax
	case lonely
	case mild
	case modest
	case naive
	case naughty
	case quiet
	case quirky
	case rash
	case relaxed
	case sassy
	case serious
	case timid

	var atkModifier: Double {
		switch self {
		case .lonely, .adamant, .naughty, .brave:
			return 1.1
		case .bold, .modest, .calm, .timid:
			return 0.9
		default:
			return 1
		}
	}

	var defModifier: Double {
		switch self {
		case .bold, .impish, .lax, .relaxed:
			return 1.1
		case .lonely, .mild, .gentle, .hasty:
			return 0.9
		default:
			return 1
		}
	}

	var spAtkModifier: Double {
		switch self {
		case .modest, .mild, .rash, .quiet:
			return 1.1
		case .adamant, .impish, .careful, .jolly:
			return 0.9
		default:
			return 1
		}
	}

	var spDefModifier: Double {
		switch self {
		case .calm, .gentle, .careful, .sassy:
			return 1.1
		case .naughty, .lax, .rash, .naive:
			return 0.9
		default:
			return 1
		}
	}

	var spdModifier: Double {
		switch self {
		case .timid, .hasty, .jolly, .naive:
			return 1.1
		case .brave, .relaxed, .quiet, .sassy:
			return 0.9
		default:
			return 1
		}
	}
}
