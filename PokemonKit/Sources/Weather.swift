//
//  Weather.swift
//  PokemonBattleEngineTest
//
//  Created by Rhys Morgan on 04/02/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

enum Weather: CustomStringConvertible {
	case none
	case harshSunlight
	case extremelyHarshSunlight
	case rain
	case heavyRain
	case sandstorm
	case hail
	
	var description: String {
		switch self {
		case .harshSunlight:
			return "harsh sunlight"
		case .extremelyHarshSunlight:
			return "extremely harsh sunlight"
		case .rain:
			return "rain"
		case .heavyRain:
			return "heavy rain"
		case .sandstorm:
			return "sandstorm"
		case .hail:
			return "hail"
		case .none:
			return "no active weather"
		}
	}
	
//	var fireModifier: Double {
//		switch self {
//		case .harshSunlight, .extremelyHarshSunlight: return 1.5
//		case .rain, .heavyRain: return 0.5
//		default: return 1
//		}
//	}
//
//	var waterModifier: Double {
//		switch self {
//		case .rain, .heavyRain: return 1.5
//		case .harshSunlight, .extremelyHarshSunlight: return 0.5
//		default: return 1
//		}
//	}
}
