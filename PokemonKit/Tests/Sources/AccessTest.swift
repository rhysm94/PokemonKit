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
	override func setUp() {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testEvolutions() {
		let eevee = Pokedex.default.pokemon["tyrogue"]!
		let eeveeEvolutions = eevee.evolutions?.sorted { $1.evolvedPokemon.dexNum > $0.evolvedPokemon.dexNum }
		for evolution in eeveeEvolutions ?? [] {
			print("To evolve into: \(evolution.evolvedPokemon):")
			for condition in evolution.conditions {
				print(condition)
			}
		}
	}

	func testPreEvolutions() {
		let sylveon = Pokedex.default.pokemon["sylveon"]!
		guard let eevee = sylveon.evolvesFrom else {
			XCTFail("Couldn't unwrap sylveon.evolvesFrom")
			return
		}
		XCTAssertEqual(eevee.name, "Eevee")
	}

	func testFormAttributes() {
		let bulbasaur = Pokedex.default.pokemon["bulbasaur"]!
		XCTAssertFalse(bulbasaur.formAttributes.isMega)
	}

	func testAlternateFormCount() {
		let deoxys = Pokedex.default.pokemon[385]
		XCTAssertEqual(deoxys.forms.count, 3)
	}

	func testAlternateFormCountNone() {
		let bulbasaur = Pokedex.default.pokemon["bulbasaur"]!
		XCTAssertEqual(bulbasaur.forms.count, 0)
	}

	func testAlternateFormCountMany() {
		let pikachu = Pokedex.default.pokemon["pikachu"]!
		print(pikachu.forms)
		XCTAssertEqual(pikachu.forms.count, 13)
	}

	func testIsMega() {
		let sceptile = Pokedex.default.pokemon["sceptile"]!
		let megaSceptile = sceptile.forms[0]
		XCTAssertTrue(megaSceptile.formAttributes.isMega)
	}
}
