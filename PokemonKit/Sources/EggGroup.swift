//
//  EggGroup.swift
//  PokemonKit
//
//  Created by Rhys Morgan on 07/06/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

import Foundation

public enum EggGroup: String, Codable {
	case amorphous
	case bug
	case dragon
	case fairy
	case field
	case flying
	case grass
	case humanlike
	case mineral
	case monster
	case water1
	case water2
	case water3
	case ditto
	case undiscovered
	
	init(using number: Int) {
		switch number {
		case 1: self = .monster
		case 2: self = .water1
		case 3: self = .bug
		case 4: self = .flying
		case 5: self = .field
		case 6: self = .fairy
		case 7: self = .grass
		case 8: self = .humanlike
		case 9: self = .water3
		case 10: self = .mineral
		case 11: self = .amorphous
		case 12: self = .water2
		case 13: self = .ditto
		case 14: self = .dragon
		case 15: self = .undiscovered
		default: self = .undiscovered
		}
	}
}
