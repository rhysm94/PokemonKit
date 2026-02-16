//
//  AccessTest.swift
//  PokemonKit
//
//  Created by Rhys Morgan on 15/11/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

import XCTest

@testable import PokemonKit

class AccessTest: XCTestCase {
	func testEvolutions() {
		let eevee = Pokedex.default.getPokemon(byIdentifier: "tyrogue")!
		let eeveeEvolutions = eevee.evolutions?.sorted { $1.evolvedPokemon.dexNum > $0.evolvedPokemon.dexNum }
		for evolution in eeveeEvolutions ?? [] {
			print("To evolve into: \(evolution.evolvedPokemon):")
			for condition in evolution.conditions {
				print(condition)
			}
		}
	}

	func testPreEvolutions() {
		let sylveon = Pokedex.default.getPokemon(byIdentifier: "sylveon")!
		guard let eevee = sylveon.evolvesFrom else {
			XCTFail("Couldn't unwrap sylveon.evolvesFrom")
			return
		}
		XCTAssertEqual(eevee.name, "Eevee")
	}

	func testFormAttributes() {
		let bulbasaur = Pokedex.default.getPokemon(byIdentifier: "bulbasaur")!
		XCTAssertFalse(bulbasaur.formAttributes.isMega)
	}

	func testAlternateFormCount() {
		let deoxys = Pokedex.default.getPokemon(byDexNumber: 386)!
		XCTAssertEqual(deoxys.forms.count, 3)
	}

	func testAlternateFormCountNone() {
		let bulbasaur = Pokedex.default.getPokemon(byIdentifier: "bulbasaur")!
		XCTAssertEqual(bulbasaur.forms.count, 0)
	}

	func testAlternateFormCountMany() {
		let pikachu = Pokedex.default.getPokemon(byIdentifier: "pikachu")!
		print(pikachu.forms)
		XCTAssertEqual(pikachu.forms.count, 13)
	}

	func testIsMega() {
		let sceptile = Pokedex.default.getPokemon(byIdentifier: "sceptile")!
		let megaSceptile = sceptile.forms[0]
		XCTAssertTrue(megaSceptile.formAttributes.isMega)
	}
}
