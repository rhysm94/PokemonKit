//
//  PerformanceTests.swift
//  PokemonKit
//
//  Created by Rhys Morgan on 16/07/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

import XCTest
@testable import PokemonKit

class PerformanceTests: XCTestCase {
	// Old performance tests removed - they tested loading all data into memory
	// which is no longer the architecture (now using query-based API)

	func testQuerySinglePokemon() {
		measure {
			_ = Pokedex.default.getPokemon(byIdentifier: "pikachu")
		}
	}

	func testQuerySingleAbility() {
		measure {
			_ = Pokedex.default.getAbility(named: "Protean")
		}
	}

	func testQuerySingleAttack() {
		measure {
			_ = Pokedex.default.getAttack(named: "Thunderbolt")
		}
	}
}
