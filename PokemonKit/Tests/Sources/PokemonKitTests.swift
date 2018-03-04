//
//  PokemonKit_iOSTests.swift
//  PokemonKit_iOSTests
//
//  Created by Rhys Morgan on 28/02/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

import XCTest
@testable import PokemonKit

class PokemonKitTests: XCTestCase {
	
	var bulbasaur: Pokemon!
	var pikachu: Pokemon!
	let rhys = Player(name: "Rhys")
	let joe = Player(name: "Joe")
	
	var engine: BattleEngine!
	
	let sludgeBomb = Attack(name: "Sludge Bomb", power: 90, basePP: 1, maxPP: 1, priority: 0, type: .poison, category: .special)
	let gigaDrain = Attack(name: "Giga Drain", power: 75, basePP: 1, maxPP: 1, priority: 0, type: .grass, category: .special, effectTarget: .attacker)
	let bulletSeed = Attack(name: "Bullet Seed", power: 25, basePP: 1, maxPP: 1, priority: 0, type: .grass, category: .physical)
	let thunderbolt = Attack(name: "Thunderbolt", power: 90, basePP: 1, maxPP: 1, priority: 0, type: .electric, category: .special)
	
	let testAbility = Ability(name: "Test", description: "Test")
	
    override func setUp() {
        super.setUp()
		
		let bulbasaurSpecies = PokemonSpecies(dexNum: 1, identifier: "bulbasaur", name: "Bulbasaur", typeOne: .grass, typeTwo: .poison, stats: Stats(hp: 45, atk: 49, def: 49, spAtk: 65, spDef: 65, spd: 45), abilityOne: testAbility)
		bulbasaur = Pokemon(species: bulbasaurSpecies, level: 50, nature: .modest, effortValues: Stats(hp: 0, atk: 0, def: 4, spAtk: 252, spDef: 0, spd: 252), individualValues: .fullIVs, attacks: [gigaDrain])
		
		let pikachuSpecies = PokemonSpecies(dexNum: 25, identifier: "pikachu", name: "Pikachu", type: .electric, stats: Stats(hp: 35, atk: 55, def: 40, spAtk: 50, spDef: 50, spd: 90), abilityOne: testAbility)
		pikachu = Pokemon(species: pikachuSpecies, level: 50, nature: .timid, effortValues: Stats(hp: 0, atk: 0, def: 4, spAtk: 252, spDef: 0, spd: 252), individualValues: .fullIVs, attacks: [thunderbolt])
		
		rhys.add(pokemon: bulbasaur)
		joe.add(pokemon: pikachu)
		
		engine = BattleEngine(playerOne: rhys, playerTwo: joe, battleType: .single)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	func testBulbasaurName() {
		XCTAssertEqual(bulbasaur.nickname, "Bulbasaur")
	}
	
	func testHPStatCalculation() {
		let calculatedStat = bulbasaur.calculateHPStat(base: 45, EV: 0, IV: 31, level: 50)
		XCTAssertEqual(calculatedStat, 120)
	}
	
	func testAttackStatCalculation() {
		let calculatedAttack = floor(bulbasaur.calculateOtherStats(base: 49, EV: 0, IV: 31, level: 50, natureModifier: Nature.modest.atkModifier))
		XCTAssertEqual(calculatedAttack, 62)
	}
	
	func testDefStatCalculation() {
		let calculatedDef = floor(bulbasaur.calculateOtherStats(base: 49, EV: 4, IV: 31, level: 50, natureModifier: Nature.modest.defModifier))
		XCTAssertEqual(calculatedDef, 70)
	}
	
	func testSpAtkStatCalculation() {
		let calculatedSpAtk = floor(bulbasaur.calculateOtherStats(base: 65, EV: 252, IV: 31, level: 50, natureModifier: Nature.modest.spAtkModifier))
		XCTAssertEqual(calculatedSpAtk, 128)
	}
	
	func testSpDefStatCalculation() {
		let calculatedSpDef = floor(bulbasaur.calculateOtherStats(base: 65, EV: 0, IV: 31, level: 50, natureModifier: Nature.modest.spDefModifier))
		XCTAssertEqual(calculatedSpDef, 85)
	}
	
	func testSpeedStatCalculation() {
		let calculatedSpeed = floor(bulbasaur.calculateOtherStats(base: 45, EV: 252, IV: 31, level: 50, natureModifier: Nature.modest.spdModifier))
		XCTAssertEqual(calculatedSpeed, 97)
	}
	
	func testFullStats() {
		XCTAssertEqual(bulbasaur.baseStats, Stats(hp: 120, atk: 62, def: 70, spAtk: 128, spDef: 85, spd: 97))
	}
	
	func testGigaDrainDamage() {
		let (damage, _) = engine.calculateDamage(attacker: bulbasaur, defender: pikachu, attack: gigaDrain)
		
		XCTAssertGreaterThanOrEqual(damage, 78)
		XCTAssertLessThanOrEqual(damage, 93)
	}
	
	func testSludgeBombDamage() {
		let (damage, _) = engine.calculateDamage(attacker: bulbasaur, defender: pikachu, attack: sludgeBomb)
		XCTAssertGreaterThanOrEqual(damage, 93)
		XCTAssertLessThanOrEqual(damage, 111)
	}
	
	func testThunderboltDamage() {
		let (damage, _) = engine.calculateDamage(attacker: pikachu, defender: bulbasaur, attack: thunderbolt)
		XCTAssertGreaterThanOrEqual(damage, 30)
		XCTAssertLessThanOrEqual(damage, 36)
	}
	
	func testBulletSeedDamage() {
		let (damage, _) = engine.calculateDamage(attacker: bulbasaur, defender: pikachu, attack: bulletSeed)
		XCTAssertGreaterThanOrEqual(damage, 16)
		XCTAssertLessThanOrEqual(damage, 19)
	}
	
	func testPikachuHP() {
		XCTAssertEqual(pikachu.currentHP, 110)
	}
	
	func testBattleEngineAppliesDamage() {
		let activePokemon = \Player.activePokemon
		
		Random.shared = Random(seed: "Testing")
		
		engine.addTurn(Turn(player: rhys, action: .attack(attacker: rhys[keyPath: activePokemon], defender: .defender, attack: rhys[keyPath: activePokemon].attacks[0])))
		engine.addTurn(Turn(player: joe, action: .attack(attacker: joe[keyPath: activePokemon], defender: .defender, attack: joe[keyPath: activePokemon].attacks[0])))
		
		XCTAssertGreaterThanOrEqual(rhys[keyPath: activePokemon].currentHP, 84)
		XCTAssertLessThanOrEqual(rhys[keyPath: activePokemon].currentHP, 90)
		
		XCTAssertGreaterThanOrEqual(joe[keyPath: activePokemon].currentHP, 17)
		XCTAssertLessThanOrEqual(joe[keyPath: activePokemon].currentHP, 32)
	}
	
	func testProteanMessage() {
		let greninjaSpecies = PokemonSpecies(dexNum: 658, identifier: "greninja", name: "Greninja", typeOne: .water, typeTwo: .dark, stats: Stats(hp: 72, atk: 95, def: 67, spAtk: 103, spDef: 71, spd: 122), abilityOne: Ability(name: "Some", description: "Ability"), hiddenAbility: Ability(name: "Protean", description: "Changes Pokémon type to move type", activationMessage: Pokedex.activationMessage["Protean"]))
		let greninja = Pokemon(species: greninjaSpecies, level: 100, ability: greninjaSpecies.hiddenAbility!, nature: .timid, effortValues: .empty, individualValues: .fullIVs, attacks: [])
		
		greninja.species.typeOne = .grass
		greninja.species.typeTwo = nil
		
		guard let activationMessage = greninja.ability.activationMessage?(greninja) else {
			XCTFail()
			return
		}
		
		XCTAssertEqual(activationMessage, "Greninja became Grass type")
	}
	
	func testImportingFromDatabase() {
		XCTAssertEqual(Pokedex.default.pokemon.count, 802)
		let charizardSpecies = Pokedex.default.pokemon["charizard"]
		XCTAssertNotNil(charizardSpecies)
	}
}
