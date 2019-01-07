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
	
	let sludgeBomb = Pokedex.default.attacks["Sludge Bomb"]!
	let gigaDrain = Pokedex.default.attacks["Giga Drain"]!
	let bulletSeed = Pokedex.default.attacks["Bullet Seed"]!
	let thunderbolt = Pokedex.default.attacks["Thunderbolt"]!
	let thunder = Pokedex.default.attacks["Thunder"]!
	let tackle = Pokedex.default.attacks["Tackle"]!
	
	let testAbility = Ability(name: "Test", description: "Test")
	
    override func setUp() {
        super.setUp()
		
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
	
	func testEncodingAndDecodingTeam() {
		let team = [bulbasaur!, pikachu!]
		var decodedTeamData = [Pokemon]()
		do {
			let encodedTeamData = try JSONEncoder().encode(team)
			print(String(decoding: encodedTeamData, as: UTF8.self))
			decodedTeamData = try JSONDecoder().decode([Pokemon].self, from: encodedTeamData)
		} catch let error {
			XCTFail(error.localizedDescription)
		}
		XCTAssertEqual(team, decodedTeamData)
	}
	
	func testFamily() {
		let pikachu = Pokedex.default.kantoPokemon[25]
		
		print(pikachu.family)
	}
	
	func testActivePokemon() {
		XCTAssertTrue(rhys.activePokemon === rhys.team[0])
	}
	
	func testBulbasaurName() {
		XCTAssertEqual(bulbasaur.nickname, "Bulbasaur")
	}
	
	func testHPStatCalculation() {
		let calculatedStat = Pokemon.calculateHPStat(base: 45, EV: 0, IV: 31, level: 50)
		XCTAssertEqual(calculatedStat, 120)
	}
	
	func testAttackStatCalculation() {
		let calculatedAttack = floor(Pokemon.calculateOtherStats(base: 49, EV: 0, IV: 31, level: 50, natureModifier: Nature.modest.atkModifier))
		XCTAssertEqual(calculatedAttack, 62)
	}
	
	func testDefStatCalculation() {
		let calculatedDef = floor(Pokemon.calculateOtherStats(base: 49, EV: 4, IV: 31, level: 50, natureModifier: Nature.modest.defModifier))
		XCTAssertEqual(calculatedDef, 70)
	}
	
	func testSpAtkStatCalculation() {
		let calculatedSpAtk = floor(Pokemon.calculateOtherStats(base: 65, EV: 252, IV: 31, level: 50, natureModifier: Nature.modest.spAtkModifier))
		XCTAssertEqual(calculatedSpAtk, 128)
	}
	
	func testSpDefStatCalculation() {
		let calculatedSpDef = floor(Pokemon.calculateOtherStats(base: 65, EV: 0, IV: 31, level: 50, natureModifier: Nature.modest.spDefModifier))
		XCTAssertEqual(calculatedSpDef, 85)
	}
	
	func testSpeedStatCalculation() {
		let calculatedSpeed = floor(Pokemon.calculateOtherStats(base: 45, EV: 252, IV: 31, level: 50, natureModifier: Nature.modest.spdModifier))
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
		print("Thunderbolt damage: \(damage)")
	}
	
	func testBulletSeedDamage() {
		let (damage, _) = engine.calculateDamage(attacker: bulbasaur, defender: pikachu, attack: bulletSeed)
		XCTAssertGreaterThanOrEqual(damage, 16)
		XCTAssertLessThanOrEqual(damage, 19)
	}
	
	func testPikachuHP() {
		XCTAssertEqual(pikachu.currentHP, 110)
	}
	
	func testEeveeEggGroup() {
		XCTAssertEqual(Pokedex.default.pokemon[132].eggGroupOne, .field)
		XCTAssertNil(Pokedex.default.pokemon[132].eggGroupTwo)
	}
	
	func testPikachuEggGroup() {
		XCTAssertEqual(pikachu.species.eggGroupOne, .field)
		XCTAssertEqual(pikachu.species.eggGroupTwo, .fairy)
	}
	
	func testBattleEngineAppliesDamage() {
		engine.addTurn(Turn(player: rhys, action: .attack(attack: rhys.activePokemon.attacks[0])))
		engine.addTurn(Turn(player: joe, action: .attack(attack: joe.activePokemon.attacks[0])))
		
		XCTAssertGreaterThanOrEqual(rhys.activePokemon.currentHP, 84)
		XCTAssertLessThanOrEqual(rhys.activePokemon.currentHP, 90)
		
		XCTAssertGreaterThanOrEqual(joe.activePokemon.currentHP, 0)
		XCTAssertLessThanOrEqual(joe.activePokemon.currentHP, 17)
	}
	
	func testProteanMessage() {
		let greninjaSpecies = PokemonSpecies(dexNum: 658, identifier: "greninja", name: "Greninja", typeOne: .water, typeTwo: .dark, stats: Stats(hp: 72, atk: 95, def: 67, spAtk: 103, spDef: 71, spd: 122), abilityOne: Ability(name: "Some", description: "Ability"), hiddenAbility: Ability(name: "Protean", description: "Changes Pokémon type to move type", activationMessage: Pokedex.activationMessage["Protean"]), eggGroupOne: .water1)
		let greninja = Pokemon(species: greninjaSpecies, level: 100, ability: greninjaSpecies.hiddenAbility!, nature: .timid, effortValues: .empty, individualValues: .fullIVs, attacks: [])
		
		greninja.species.typeOne = .grass
		greninja.species.typeTwo = nil
		
		guard let activationMessage = greninja.ability.activationMessage?(greninja) else {
			XCTFail()
			return
		}
		
		XCTAssertEqual(activationMessage, "Greninja became Grass type")
	}
	
	func testAllFainted() {
		let greninjaSpecies = PokemonSpecies(dexNum: 658, identifier: "greninja", name: "Greninja", typeOne: .water, typeTwo: .dark, stats: Stats(hp: 72, atk: 95, def: 67, spAtk: 103, spDef: 71, spd: 122), abilityOne: Ability(name: "Some", description: "Ability"), hiddenAbility: Ability(name: "Protean", description: "Changes Pokémon type to move type", activationMessage: Pokedex.activationMessage["Protean"]), eggGroupOne: .water1)
		let greninja = Pokemon(species: greninjaSpecies, level: 100, ability: greninjaSpecies.hiddenAbility!, nature: .timid, effortValues: .empty, individualValues: .fullIVs, attacks: [])
		
		rhys.add(pokemon: greninja)
		
		XCTAssertFalse(rhys.allFainted)
		
		rhys.activePokemon.currentHP = 0
		
		XCTAssertFalse(rhys.allFainted)
		
		rhys.switchPokemon(pokemon: greninja)
		
		rhys.activePokemon.currentHP = 0
		
		XCTAssertTrue(rhys.allFainted)
	}
	
	func testImportingFromDatabase() {
		XCTAssertEqual(Pokedex.default.pokemon.count, 807)
		let charizardSpecies = Pokedex.default.pokemon["charizard"]
		XCTAssertNotNil(charizardSpecies)
	}
	
	func testPichuMovesetCount() {
		XCTAssertEqual(Pokedex.default.pokemon["pichu"]!.moveset.count, 48)
	}
	
	func testAddingMultipleAttacks() {
		engine.addTurn(Turn(player: joe, action: .attack(attack: Pokedex.default.attacks["Thunder Wave"]!)))
		engine.addTurn(Turn(player: joe, action: .attack(attack: Pokedex.default.attacks["Thunderbolt"]!)))
		XCTAssert(engine.turns.count == 1)
	}
	
	func testAddingSwitchTurn() {
		engine.addTurn(Turn(player: joe, action: .attack(attack: Pokedex.default.attacks["Thunder Wave"]!)))
		engine.addTurn(Turn(player: joe, action: .switchTo(bulbasaur)))
		
		XCTAssert(engine.turns.count == 1)
	}
	
	func testAddingForceSwitch() {
		let gengarSpecies = Pokedex.default.pokemon[93]
		let gengar = Pokemon(species: gengarSpecies, level: 50, ability: gengarSpecies.abilityOne, nature: .modest, effortValues: Stats(hp: 0, atk: 0, def: 0, spAtk: 252, spDef: 6, spd: 252), individualValues: .fullIVs, attacks: [sludgeBomb])
		
		joe.add(pokemon: gengar)
		
		engine.state = .awaitingSwitch
		
		joe.activePokemon.currentHP = 0
		
		engine.addTurn(Turn(player: joe, action: .forceSwitch(gengar)))
		
		XCTAssertEqual(joe.activePokemon, gengar)
		XCTAssertEqual(engine.turns.count, 0)
		XCTAssertEqual(engine.state, .running)
	}
	
	func testHealingMove() {
		// Rhys's Pokémon - Bulbasaur - is slower, so Joe's Pokémon - Pikachu - will attack first
		// As established in a previous test, the damage is less than half of Bulbasaur's HP
		// Then Bulbasaur will use Recover, an attack which recovers half a Pokémon's HP, up to their max. HP
		// Bulbasaur's HP should be fully recovered by this point
		
		engine.addTurn(Turn(player: joe, action: .attack(attack: thunderbolt)))
		engine.addTurn(Turn(player: rhys, action: .attack(attack: Pokedex.default.attacks["Recover"]!)))
		
		XCTAssertEqual(rhys.activePokemon.currentHP, rhys.activePokemon.baseStats.hp)
	}
	
	func testNeedToRecharge() {
		Random.shared = Random(seed: "willhit")
		
		let hyperBeam = Pokedex.default.attacks["Hyper Beam"]!

		engine.addTurn(Turn(player: joe, action: .attack(attack: hyperBeam)))
		engine.addTurn(Turn(player: rhys, action: .attack(attack: gigaDrain)))
		
		XCTAssert(joe.activePokemon.volatileStatus.contains(.mustRecharge))
	}
	
	func testSwordsDance() {
		let swordsDance = Pokedex.default.attacks["Swords Dance"]!

		engine.addTurn(Turn(player: rhys, action: .attack(attack: swordsDance)))
		engine.addTurn(Turn(player: joe, action: .attack(attack: thunderbolt)))
		
		XCTAssertEqual(rhys.activePokemon.statStages.atk, 2)

	}
	
	func testTopsyTurvy() {
		let swordsDance = Pokedex.default.attacks["Swords Dance"]!
		let topsyTurvy = Pokedex.default.attacks["Topsy-Turvy"]!
		
		engine.addTurn(Turn(player: rhys, action: .attack(attack: swordsDance)))
		engine.addTurn(Turn(player: joe, action: .attack(attack: thunderbolt)))
		engine.addTurn(Turn(player: rhys, action: .attack(attack: gigaDrain)))
		engine.addTurn(Turn(player: joe, action: .attack(attack: topsyTurvy)))
		
		XCTAssertEqual(rhys.activePokemon.statStages.atk, -2)
	}
	
	func testGigaDrain() {
		
		let beforeTurnHP = rhys.activePokemon.currentHP
		
		engine.addTurn(Turn(player: joe, action: .attack(attack: thunderbolt)))
		engine.addTurn(Turn(player: rhys, action: .attack(attack: gigaDrain)))
		
		print("Before Turn: \(rhys.activePokemon.nickname)'s HP: \(beforeTurnHP)")
		print("After Turn: \(rhys.activePokemon.nickname)'s HP: \(rhys.activePokemon.currentHP)")
		
		XCTAssertEqual(rhys.activePokemon.currentHP, beforeTurnHP)
	}
	
	func testBulletSeedHitsWithSlowerPokemon() {
		engine.addTurn(Turn(player: joe, action: .attack(attack: tackle)))
		engine.addTurn(Turn(player: rhys, action: .attack(attack: bulletSeed)))
		
		XCTAssertNotEqual(joe.activePokemon.currentHP, joe.activePokemon.baseStats.hp)
		XCTAssertNotEqual(rhys.activePokemon.currentHP, rhys.activePokemon.baseStats.hp)
	}
	
	func testSuperEffectiveDamage() {
		let flamethrower = Pokedex.default.attacks["Flamethrower"]!
		let (_, effectiveness) = engine.calculateDamage(attacker: rhys.activePokemon, defender: bulbasaur, attack: flamethrower)
		XCTAssertEqual(effectiveness, Type.Effectiveness.superEffective)
	}
	
	func testNotEffectiveDamage() {
		let gengarSpecies = Pokedex.default.pokemon[93]
		let gengar = Pokemon(species: gengarSpecies, level: 50, ability: gengarSpecies.abilityOne, nature: .modest, effortValues: Stats(hp: 0, atk: 0, def: 0, spAtk: 252, spDef: 6, spd: 252), individualValues: .fullIVs, attacks: [])
		
		let eeveeSpecies = Pokedex.default.pokemon[132]
		let eevee = Pokemon(species: eeveeSpecies, level: 50, ability: eeveeSpecies.abilityOne, nature: .hardy, effortValues: .empty, individualValues: .fullIVs, attacks: [])
		let tackle = Pokedex.default.attacks["Tackle"]!
		
		let (_, effectiveness) = engine.calculateDamage(attacker: eevee, defender: gengar, attack: tackle)
		
		XCTAssertEqual(effectiveness, Type.Effectiveness.notEffective)
	}
	
	/// Checks that Solar Beam applies the correct volatile status to the Pokémon that uses it, and does no damage on the first turn
	func testSolarBeamFirstTurn() {
		let solarBeam = Pokedex.default.attacks["Solar Beam"]!
		engine.addTurn(Turn(player: rhys, action: .attack(attack: solarBeam)))
		engine.addTurn(Turn(player: joe, action: .attack(attack: joe.activePokemon.attacks[0])))
		
		print(rhys.activePokemon.volatileStatus)
		print(joe.activePokemon.currentHP)
		
		XCTAssertTrue(rhys.activePokemon.volatileStatus.contains(.preparingTo(solarBeam.withoutBonusEffect())))
		XCTAssertEqual(joe.activePokemon.currentHP, joe.activePokemon.baseStats.hp)
	}
	
	// Checks that Solar Beam applies the correct volatile status, does
	func testSolarBeamTwoTurns() {
		let solarBeam = Pokedex.default.attacks["Solar Beam"]!
		engine.addTurn(Turn(player: rhys, action: .attack(attack: solarBeam)))
		engine.addTurn(Turn(player: joe, action: .attack(attack: joe.activePokemon.attacks[0])))
		
		XCTAssertEqual(joe.activePokemon.currentHP, joe.activePokemon.baseStats.hp)
		XCTAssertTrue(rhys.activePokemon.volatileStatus.contains(.preparingTo(solarBeam.withoutBonusEffect())))

		engine.addTurn(Turn(player: rhys, action: .attack(attack: solarBeam.withoutBonusEffect())))
		engine.addTurn(Turn(player: joe, action: .attack(attack: joe.activePokemon.attacks[0])))
		
		XCTAssertNotEqual(joe.activePokemon.currentHP, joe.activePokemon.baseStats.hp)
		XCTAssertFalse(rhys.activePokemon.volatileStatus.contains(.preparingTo(solarBeam.withoutBonusEffect())))
	}
	
	func testSolarBeamUnderSunlight() {
		let solarBeam = Pokedex.default.attacks["Solar Beam"]!
		engine.setWeather(.harshSunlight)
		engine.addTurn(Turn(player: rhys, action: .attack(attack: solarBeam)))
		engine.addTurn(Turn(player: joe, action: .attack(attack: joe.activePokemon.attacks[0])))
		
		XCTAssertNotEqual(joe.activePokemon.currentHP, joe.activePokemon.baseStats.hp)
		XCTAssertFalse(rhys.activePokemon.volatileStatus.contains(.preparingTo(solarBeam.withoutBonusEffect())))
	}
		
	func testSolarBeamUnderSunlightAndConfusion() {
		Random.shared = Random(seed: "Testing")
		// Main seed ensures Rhys's Pokémon won't hurt itself in confusion
		
		let solarBeam = Pokedex.default.attacks["Solar Beam"]!
		engine.setWeather(.harshSunlight)
		rhys.activePokemon.volatileStatus.insert(.confused(3))
		engine.addTurn(Turn(player: rhys, action: .attack(attack: solarBeam)))
		engine.addTurn(Turn(player: joe, action: .attack(attack: joe.activePokemon.attacks[0])))
		
		XCTAssertNotEqual(joe.activePokemon.currentHP, joe.activePokemon.baseStats.hp)
		XCTAssertFalse(rhys.activePokemon.volatileStatus.contains(.preparingTo(solarBeam.withoutBonusEffect())))
	}
	
	func testSolarBeamNoPreparingToAppliesWhenConfused() {
		// Tests the condition where a Pokémon is confused, and will hurt themselves in their confusion
		// having selected a multi-turn attack
		// Will verify that the bonus effect for said multiTurnAttack *isn't* run
		
		// Seed guaranteed to have Rhys's active Pokémon hurt itself in confusion
		Random.shared = Random(seed: "HurtSelfConfusion")
		
		let solarBeam = Pokedex.default.attacks["Solar Beam"]!
		engine.setWeather(.harshSunlight)
		rhys.activePokemon.volatileStatus.insert(.confused(3))
		engine.addTurn(Turn(player: rhys, action: .attack(attack: solarBeam)))
		engine.addTurn(Turn(player: joe, action: .attack(attack: joe.activePokemon.attacks[0])))
		
		print(rhys.activePokemon.volatileStatus)
		
		XCTAssertFalse(rhys.activePokemon.volatileStatus.contains(.preparingTo(solarBeam.withoutBonusEffect())))
	}
	
	func testProtectFasterPokemon() {
		let protect = Pokedex.default.attacks["Protect"]!
		
		engine.addTurn(Turn(player: joe, action: .attack(attack: protect)))
		engine.addTurn(Turn(player: rhys, action: .attack(attack: gigaDrain)))
		
		XCTAssertEqual(joe.activePokemon.currentHP, joe.activePokemon.baseStats.hp)
	}
	
	func testProtectSlowerPokemon() {
		let protect = Pokedex.default.attacks["Protect"]!
		engine.addTurn(Turn(player: joe, action: .attack(attack: thunderbolt)))
		engine.addTurn(Turn(player: rhys, action: .attack(attack: protect)))
		
		XCTAssertFalse(rhys.activePokemon.volatileStatus.contains(.protected))
	}
	
	func testRandomD3() {
		var generated = [Int]()
		
		for _ in 1...1000 {
			generated.append(Random.shared.d3Roll())
		}
		
		XCTAssertFalse(generated.contains(0))
		XCTAssertTrue(generated.contains(1))
		XCTAssertTrue(generated.contains(2))
		XCTAssertTrue(generated.contains(3))
		XCTAssertFalse(generated.contains(4))
	}
	
	func testRandomD5() {
		var generated = [Int]()
		
		for _ in 1...1000 {
			generated.append(Random.shared.d5Roll())
		}
		
		XCTAssertFalse(generated.contains(0))
		XCTAssertTrue(generated.contains(1))
		XCTAssertTrue(generated.contains(2))
		XCTAssertTrue(generated.contains(3))
		XCTAssertTrue(generated.contains(4))
		XCTAssertTrue(generated.contains(5))
		XCTAssertFalse(generated.contains(6))
	}
	
	func testBattleRNG() {
		var generated = [Double]()
		
		for _ in 1...2000 {
			generated.append(Random.shared.battleRNG())
		}
		
		XCTAssertFalse(generated.contains(84))
		XCTAssertTrue(generated.contains(85))
		XCTAssertTrue(generated.contains(90))
		XCTAssertTrue(generated.contains(95))
		XCTAssertTrue(generated.contains(100))
		XCTAssertFalse(generated.contains(101))
	}
	
	func testRandomBetween() {
		var generated = [Int]()
		
		for _ in 1...1000 {
			generated.append(Random.shared.between(minimum: 2, maximum: 5))
		}
		
		XCTAssertFalse(generated.contains(1))
		XCTAssertTrue(generated.contains(2))
		XCTAssertTrue(generated.contains(3))
		XCTAssertTrue(generated.contains(4))
		XCTAssertTrue(generated.contains(5))
		XCTAssertFalse(generated.contains(6))
	}
	
	/// Tests accuracy of a low-accuracy move, such as Fissure (30% chance of hitting)
	///
	/// Test's Random seed is known to cause attack to miss
	func testAccuracyLowAccuracyMove() {
		Random.shared = Random(seed: "Testing")
		let fissure = Pokedex.default.attacks["Fissure"]!
		
		engine.addTurn(Turn(player: rhys, action: .attack(attack: fissure)))
		engine.addTurn(Turn(player: joe, action: .attack(attack: gigaDrain)))
		
		XCTAssertEqual(joe.activePokemon.currentHP, joe.activePokemon.baseStats.hp)
	}
	
	func testAccuracyPerfectAccuracy() {
		let aerialAce = Pokedex.default.attacks["Aerial Ace"]!
		
		engine.addTurn(Turn(player: rhys, action: .attack(attack: aerialAce)))
		engine.addTurn(Turn(player: joe, action: .attack(attack: gigaDrain)))
		
		XCTAssertNotEqual(joe.activePokemon.currentHP, joe.activePokemon.baseStats.hp)
	}
	
	func testCopy() {
		engine.addTurn(Turn(player: rhys, action: .attack(attack: thunderbolt)))
		engine.addTurn(Turn(player: joe, action: .attack(attack: gigaDrain)))
		
		let copy = engine.copy() as? BattleEngine
		
		if let copy = copy, let engine = self.engine {
			XCTAssertTrue(copy == engine)
		} else {
			XCTFail()
		}
	}
	
	func testPlayerIDValues() {
		print(rhys.playerId)
		print(joe.playerId)
		XCTAssertNotEqual(rhys.playerId, joe.playerId)
	}
	
	// MARK: - GKMinmaxStrategist tests

	func testAICanMakeTurn() {
		joe.activePokemon.attacks.append(Pokedex.default.attacks["Hyper Beam"]!)
		joe.activePokemon.attacks.append(Pokedex.default.attacks["Protect"]!)
		
		engine.addTurn(Turn(player: rhys, action: .attack(attack: gigaDrain)))
		
		let ai = GKMinmaxStrategist()
		ai.maxLookAheadDepth = 3
		ai.gameModel = engine
		ai.randomSource = GKARC4RandomSource()
		
		var turn: GKGameModelUpdate?
		
		turn = ai.bestMove(for: self.joe)
		
		if let turn = turn as? Turn {
			print("Best Move: \(turn)")
			print("Move Value: \(turn.value)")
		} else {
			dump(turn)
			XCTFail()
		}
	}
	
	func testAIWillForceSwitch() {
		let gengarSpecies = Pokedex.default.pokemon[93]
		let gengar = Pokemon(species: gengarSpecies, level: 50, ability: gengarSpecies.abilityOne, nature: .modest, effortValues: Stats(hp: 0, atk: 0, def: 0, spAtk: 252, spDef: 6, spd: 252), individualValues: .fullIVs, attacks: [sludgeBomb])
		
		joe.add(pokemon: gengar)
		
		// Set up engine as if a turn had occurred, and Rhys knocked out Joe's active Pokémon
		joe.activePokemon.currentHP = 0
		engine.state = .awaitingSwitch
		engine.activePlayer = engine.playerTwo
		
		// Set up AI
		let ai = GKMinmaxStrategist()
		ai.maxLookAheadDepth = 3
		ai.gameModel = engine
		ai.randomSource = GKARC4RandomSource()
		
		var turn: GKGameModelUpdate?
		
		DispatchQueue.global().sync { [unowned self] in
			turn = ai.bestMove(for: self.joe)
		}
		
		if let turn = turn as? Turn {
			print("Best Move: \(turn)")
			print("Move Value: \(turn.value)")
			engine.addTurn(turn)
		} else {
			XCTFail()
		}
		
		XCTAssertEqual(joe.activePokemon, gengar)
		XCTAssertTrue(engine.turns.count == 0)
	}
	
	// MARK: - Test Copy Constructors
	
	func testPokemonCopyConstructor() {
		bulbasaur.volatileStatus.insert(.flinch)
		bulbasaur.volatileStatus.insert(.mustRecharge)
		
		let bulbasaurCopy = Pokemon(pokemon: bulbasaur)
		
		XCTAssertEqual(bulbasaur, bulbasaurCopy)
	}
	
	func testPokemonCopyConstructorTwo() {
		let bulbasaurCopy = Pokemon(pokemon: bulbasaur)
		
		bulbasaur.volatileStatus.insert(.flinch)
		bulbasaur.volatileStatus.insert(.mustRecharge)
		
		XCTAssertNotEqual(bulbasaur, bulbasaurCopy)
	}
	
	// MARK: - Weather Tests
	func testFireMoveInSunlight() {
		engine.weather = .harshSunlight
		
		let (damage, _) = engine.calculateDamage(attacker: pikachu, defender: bulbasaur, attack: Pokedex.default.attacks["Flamethrower"]!)

		XCTAssertGreaterThanOrEqual(damage, 124)
		XCTAssertLessThanOrEqual(damage, 146)
	}
	
	func testFireMoveInRain() {
		engine.weather = .rain
		
		let (damage, _) = engine.calculateDamage(attacker: pikachu, defender: bulbasaur, attack: Pokedex.default.attacks["Flamethrower"]!)
		
		XCTAssertGreaterThanOrEqual(damage, 40)
		XCTAssertLessThanOrEqual(damage, 48)
	}
	
	func testFireMoveInExtremelyHarshSunlight() {
		engine.weather = .extremelyHarshSunlight
		
		let (damage, _) = engine.calculateDamage(attacker: pikachu, defender: bulbasaur, attack: Pokedex.default.attacks["Flamethrower"]!)
		
		XCTAssertGreaterThanOrEqual(damage, 124)
		XCTAssertLessThanOrEqual(damage, 146)
	}
	
	func testFireMoveInHeavyRain() {
		engine.weather = .heavyRain
		
		let (damage, _) = engine.calculateDamage(attacker: pikachu, defender: bulbasaur, attack: Pokedex.default.attacks["Flamethrower"]!)
		
		XCTAssertGreaterThanOrEqual(damage, 0)
		XCTAssertLessThanOrEqual(damage, 0)
	}
	
	func testWaterMoveInSunlight() {
		engine.weather = .harshSunlight
		
		let (damage, _) = engine.calculateDamage(attacker: bulbasaur, defender: pikachu, attack: Pokedex.default.attacks["Hydro Pump"]!)
		
		XCTAssertGreaterThanOrEqual(damage, 38)
		XCTAssertLessThanOrEqual(damage, 45)
	}
	
	func testWaterMoveInRain() {
		engine.weather = .rain
		
		let (damage, _) = engine.calculateDamage(attacker: bulbasaur, defender: pikachu, attack: Pokedex.default.attacks["Hydro Pump"]!)
		
		XCTAssertGreaterThanOrEqual(damage, 114)
		XCTAssertLessThanOrEqual(damage, 135)
	}
	
	func testWaterMoveInExtremelyHarshSunlight() {
		engine.weather = .extremelyHarshSunlight
		
		let (damage, _) = engine.calculateDamage(attacker: bulbasaur, defender: pikachu, attack: Pokedex.default.attacks["Hydro Pump"]!)
		
		XCTAssertGreaterThanOrEqual(damage, 0)
		XCTAssertLessThanOrEqual(damage, 0)
	}
	
	func testWaterMoveInHeavyRain() {
		engine.weather = .heavyRain
		
		let (damage, _) = engine.calculateDamage(attacker: bulbasaur, defender: pikachu, attack: Pokedex.default.attacks["Hydro Pump"]!)
		
		XCTAssertGreaterThanOrEqual(damage, 114)
		XCTAssertLessThanOrEqual(damage, 135)
	}
	
	func testRandomCopy() {
		let randomCopy = Random.shared.copy()
		
		var sharedNumbers: [Int] = []
		var copyNumbers: [Int] = []
		
		for _ in 1...10 {
			sharedNumbers.append(Random.shared.d10Roll())
			copyNumbers.append(randomCopy.d10Roll())
		}
		print(sharedNumbers)
		print(copyNumbers)
		XCTAssertEqual(sharedNumbers, copyNumbers)
	}
	
	func testPikachuAbilityOne() {
		XCTAssertEqual(pikachu.species.abilityOne.name, "Static")
	}
	
	func testZeraoraHasThunderbolt() {
		let zeraora = Pokedex.default.pokemon["zeraora"]!
		let moveset = zeraora.moveset
		
		let thunderbolt = moveset.filter { $0.move.name == "Thunderbolt" }
		XCTAssertNotEqual(thunderbolt.count, 0)
		XCTAssertEqual(zeraora.abilityOne.name, "Volt Absorb")
	}
	
	func testCheckAllAttacks() {
		for pokemon in Pokedex.default.pokemon {
//			print("\(pokemon.name)'s attack count: \(pokemon.moveset.count)")
			for move in pokemon.moveset where move.move.name == "Dummy" {
				print("Dummy attack!")
			}
		}
	}
}
