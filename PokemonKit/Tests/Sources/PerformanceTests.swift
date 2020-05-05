//
//  PerformanceTests.swift
//  PokemonKit
//
//  Created by Rhys Morgan on 16/07/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

import XCTest

class PerformanceTests: XCTestCase {
	func testSpeedCreatePokedex() {
		measure {
			_ = Pokedex()
		}
	}

	func testSpeedGetAttacks() {
		measure {
			_ = Pokedex.getAttacks()
		}
	}

	func testSpeedGetAbilities() {
		measure {
			_ = Pokedex.getAbilities()
		}
	}

	func testSpeedGetPokemon() {
		let attacks = Pokedex.getAttacks()
		let abilities = Pokedex.getAbilities()

		measure {
			_ = Pokedex.getPokemon(abilities: abilities, attacks: attacks)
		}
	}
}
