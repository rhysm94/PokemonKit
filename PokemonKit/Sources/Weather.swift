//
//  Weather.swift
//  PokemonBattleEngineTest
//
//  Created by Rhys Morgan on 04/02/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

public enum Weather: CustomStringConvertible {
	case none
	case harshSunlight
	case extremelyHarshSunlight
	case rain
	case heavyRain
	case sandstorm
	case hail
	
	public var description: String {
		switch self {
		case .harshSunlight:
			return "The sunlight turned harsh!"
		case .extremelyHarshSunlight:
			return "The sunlight turned extremely harsh!"
		case .rain:
			return "It started to rain!"
		case .heavyRain:
			return "A heavy rain started to fall!"
		case .sandstorm:
			return "A sandstorm kicked up!"
		case .hail:
			return "It started to hail!"
		case .none:
			return "no active weather"
		}
	}
	
	public var disappearMessage: String {
		switch self {
		case .none:
			return "This shouldn't occur"
		case .harshSunlight:
			return "The sunlight faded."
		case .extremelyHarshSunlight:
			return "The harsh sunlight faded."
		case .rain:
			return "The rain stopped."
		case .heavyRain:
			return "The heavy rain has lifted!"
		case .sandstorm:
			return "The sandstorm subsided."
		case .hail:
			return "The hail stopped."
		}
	}
	
	var fireModifier: Double {
		switch self {
		case .harshSunlight, .extremelyHarshSunlight: return 1.5
		case .rain: return 0.5
		case .heavyRain: return 0
		default: return 1
		}
	}

	var waterModifier: Double {
		switch self {
		case .rain, .heavyRain: return 1.5
		case .harshSunlight: return 0.5
		case .extremelyHarshSunlight: return 0
		default: return 1
		}
	}
	
	func blocks(type: Type) -> Bool {
		switch(self, type) {
		case (.heavyRain, .fire):
			return true
		case (.extremelyHarshSunlight, .water):
			return true
		case(_,_):
			return false
		}
	}
	
	var blockMessage: String? {
		switch self {
		case .extremelyHarshSunlight:
			return ""
		case .heavyRain:
			return "The Fire-type attack fizzled out in the heavy rain!"
		default:
			return nil
		}
	}
}
