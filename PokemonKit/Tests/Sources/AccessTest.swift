//
//  AccessTest.swift
//  PokemonKit
//
//  Created by Rhys Morgan on 15/11/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

import XCTest

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
        XCTAssert(eevee.name == "Eevee")
    }
    
}
