//
//  StatusTests.swift
//  PokemonKit
//
//  Created by Rhys Morgan on 09/04/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

import XCTest

class StatusTests: XCTestCase {
	
	var bulbasaur: Pokemon!
	var pikachu: Pokemon!
	let rhys = Player(name: "Rhys")
	let joe = Player(name: "Joe")
	
	var engine: BattleEngine!
	
	let sludgeBomb = Pokedex.default.attacks["Sludge Bomb"]!
	let gigaDrain = Pokedex.default.attacks["Giga Drain"]!
	let thunderbolt = Pokedex.default.attacks["Thunderbolt"]!
	let thunder = Pokedex.default.attacks["Thunder"]!
	let tackle = Pokedex.default.attacks["Tackle"]!
	
    override func setUp() {
        super.setUp()
		
		Random.shared = Random(seed: UUID().uuidString)
		
		let bulbasaurSpecies = Pokedex.default.pokemon["bulbasaur"]!
		bulbasaur = Pokemon(species: bulbasaurSpecies, level: 50, nature: .modest, effortValues: Stats(hp: 0, atk: 0, def: 4, spAtk: 252, spDef: 0, spd: 252), individualValues: .fullIVs, attacks: [sludgeBomb, gigaDrain])
		
		let pikachuSpecies = Pokedex.default.pokemon["pikachu"]!
		pikachu = Pokemon(species: pikachuSpecies, level: 50, nature: .timid, effortValues: Stats(hp: 0, atk: 0, def: 4, spAtk: 252, spDef: 0, spd: 252), individualValues: .fullIVs, attacks: [thunderbolt, thunder])
		
		rhys.add(pokemon: bulbasaur)
		joe.add(pokemon: pikachu)
		
		engine = BattleEngine(playerOne: rhys, playerTwo: joe)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	func testParalysisApplied() {
		Random.shared = Random(seed: "willhit")
		
		engine.addTurn(Turn(player: joe, action: .attack(attack: Pokedex.default.attacks["Thunder Wave"]!)))
		engine.addTurn(Turn(player: rhys, action: .attack(attack: rhys.activePokemon.attacks[0])))
		
		XCTAssert(rhys.activePokemon.status == .paralysed)
	}
	
	func testConfusedVolatileStatus() {
		var confusion = VolatileStatus.confused(1)
		confusion = confusion.turn()
		
		XCTAssertEqual(VolatileStatus.confused(0), confusion)
		XCTAssertNotEqual(VolatileStatus.confused(1), confusion)
	}
	
	func testConfusion() {
		// Seed guaranteed to cause Joe's active Pokémon to hurt itself in its confusion
		Random.shared = Random(seed: "confused")
		
		joe.activePokemon.volatileStatus.insert(.confused(3))
		
		engine.addTurn(Turn(player: joe, action: .attack(attack: joe.activePokemon.attacks[0])))
		engine.addTurn(Turn(player: rhys, action: .attack(attack: tackle)))
		
		// This is true when Joe's Pokémon hasn't been able to attack - e.g. due to confusion
		XCTAssertEqual(rhys.activePokemon.currentHP, rhys.activePokemon.baseStats.hp)
	}
	
	func testConfusionWearsOff() {
		Random.shared = Random(seed: "confused")
		
		joe.activePokemon.volatileStatus.insert(.confused(1))
		
		XCTAssertTrue(joe.activePokemon.volatileStatus.contains(.confused(1)))
		XCTAssertFalse(joe.activePokemon.volatileStatus.contains(.confused(0)))
		
		engine.addTurn(Turn(player: rhys, action: .attack(attack: tackle)))
		engine.addTurn(Turn(player: joe, action: .attack(attack: joe.activePokemon.attacks[0])))
		
		XCTAssertFalse(joe.activePokemon.volatileStatus.contains(.confused(1)))
		XCTAssertTrue(joe.activePokemon.volatileStatus.contains(.confused(0)))
		
		engine.addTurn(Turn(player: rhys, action: .attack(attack: tackle)))
		engine.addTurn(Turn(player: joe, action: .attack(attack: tackle)))
		
		var containsConfused = false
		// Checks for *any* occurence of confusion in Pokémon's volatile status
		for case let .confused(number) in joe.activePokemon.volatileStatus {
			print(".confused(\(number))")
			containsConfused = true
		}
		
		XCTAssertFalse(containsConfused)
	}
	
	func testConfusionAppliesOnce() {
		Random.shared = Random(seed: "confused")
		
		joe.activePokemon.volatileStatus.insert(.confused(2))
		
		let confuseRay = Pokedex.default.attacks["Confuse Ray"]!
		
		engine.addTurn(Turn(player: rhys, action: .attack(attack: confuseRay)))
		engine.addTurn(Turn(player: joe, action: .attack(attack: joe.activePokemon.attacks[0])))
		
		var confusionOccurences = 0
		
		for case let .confused(number) in joe.activePokemon.volatileStatus {
			print(".confused(\(number))")
			confusionOccurences += 1
		}
		
		XCTAssertEqual(confusionOccurences, 1)
	}
	
	func testConfusionPreventsBonusEffect() {
		// Seed guaranteed to cause Joe's active Pokémon to hurt itself in its confusion
		Random.shared = Random(seed: "confused")
		let hypnosis = Pokedex.default.attacks["Hypnosis"]!
		
		joe.activePokemon.volatileStatus.insert(.confused(3))
		
		engine.addTurn(Turn(player: joe, action: .attack(attack: hypnosis)))
		engine.addTurn(Turn(player: rhys, action: .attack(attack: tackle)))
		
		if case .asleep = rhys.activePokemon.status {
			XCTFail("Rhys's Pokémon is asleep despite Joe's Pokémon not attacking")
		}
	}
	
	func testSleepPreventsAttack() {
		joe.activePokemon.status = .asleep(1)
		
		engine.addTurn(Turn(player: rhys, action: .attack(attack: tackle)))
		engine.addTurn(Turn(player: joe, action: .attack(attack: tackle)))
		
		XCTAssertEqual(rhys.activePokemon.currentHP, rhys.activePokemon.baseStats.hp)
	}
	
	func testSleepExpires() {
		joe.activePokemon.status = .asleep(0)
		
		engine.addTurn(Turn(player: rhys, action: .attack(attack: tackle)))
		engine.addTurn(Turn(player: joe, action: .attack(attack: tackle)))
		
		XCTAssertEqual(joe.activePokemon.status, .healthy)
	}
}
