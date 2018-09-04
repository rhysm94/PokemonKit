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
		self.measure {
			_ = Pokedex()
		}
	}
	
	func testSpeedGetAttacks() {
		self.measure {
			_ = Pokedex.getAttacks()
		}
	}
	
	func testSpeedGetAbilities() {
		self.measure {
			_ = Pokedex.getAbilities()
		}
	}
	
	func testSpeedGetPokemon() {
		let attacks = Pokedex.getAttacks()
		let abilities = Pokedex.getAbilities()
		
		self.measure {
			_ = Pokedex.getPokemon(abilities: abilities, attacks: attacks)
		}
	}
    
}
