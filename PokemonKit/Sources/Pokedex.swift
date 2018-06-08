//
//  Pokedex.swift
//  PokemonBattleEngineTest
//
//  Created by Rhys Morgan on 23/01/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

import GameplayKit
import SQLite

public class Pokedex {
	public static let `default`: Pokedex = {
		return Pokedex()
	}()

	static let dbPath = Bundle(for: Pokedex.self).path(forResource: "pokedex", ofType: "sqlite")
	
	public let pokemon: [PokemonSpecies]
	
	public var kantoPokemon: [PokemonSpecies] {
		return pokemon.filter { $0.generation == .kanto }
	}
	public var johtoPokemon: [PokemonSpecies] {
		return pokemon.filter { $0.generation == .johto }
	}
	public var hoennPokemon: [PokemonSpecies] {
		return pokemon.filter { $0.generation == .hoenn }
	}
	public var sinnohPokemon: [PokemonSpecies] {
		return pokemon.filter { $0.generation == .sinnoh }
	}
	public var unovaPokemon: [PokemonSpecies] {
		return pokemon.filter { $0.generation == .unova }
	}
	public var kalosPokemon: [PokemonSpecies] {
		return pokemon.filter { $0.generation == .kalos }
	}
	public var alolaPokemon: [PokemonSpecies] {
		return pokemon.filter { $0.generation == .alola }
	}
	
	public let abilities: [String: Ability]
	public let attacks: [String: Attack]
	
	init() {
		self.attacks = Pokedex.getAttacks()
		self.abilities = Pokedex.getAbilities()
		self.pokemon = Pokedex.getPokemon(abilities: abilities, attacks: attacks)
	}
	
	private static let protectBreakingMoves = ["Feint", "Hyperspace Fury", "Hyperspace Hole", "Phantom Force", "Shadow Force"]
    
	static let attackBonuses: [String: Attack.BonusEffect] = [
		"Bullet Seed": .multiHitMove(minHits: 2, maxHits: 5),
		"Calm Mind": .singleTarget({
			$0.statStages.spAtk += 1
			$0.statStages.spDef += 1
		}),
		"Confuse Ray": .singleTarget({
			for case .confused(_) in $0.volatileStatus { return	}
			let diceRoll = Random.shared.confusion()
			$0.volatileStatus.insert(.confused(diceRoll))
			print("\($0.nickname) became confused for \(diceRoll) turns!")
		}),
		"Dark Pulse": .singleTarget({
			let diceRoll = Random.shared.d5Roll()
			if diceRoll == 1 {
				$0.volatileStatus.insert(.flinch)
			}
		}),
		"Double Slap": .multiHitMove(minHits: 2, maxHits: 2),
		"Extrasensory": .singleTarget({
			let diceRoll = Random.shared.d10Roll()
			if diceRoll == 1 {
				$0.volatileStatus.insert(.flinch)
				print("\($0.nickname) flinched!")
			}
		}),
		"Giga Drain": .singleTargetUsingDamage({ pokemon, damage in
			let restoreHP = Int(Double(damage) * 0.5)
			pokemon.currentHP += restoreHP
			
			print("\(pokemon.nickname) will restore by \(restoreHP) capped at their max. HP")
		}),
		"Growl": .singleTarget({ $0.statStages.atk -= 1 }),
		"Hyper Beam": .singleTarget({ $0.volatileStatus.insert(.mustRecharge) }),
		"Hypnosis": .singleTarget({ pokemon in
			guard pokemon.status == .healthy else { return }
			
			let sleepTurns = Random.shared.between(minimum: 1, maximum: 3)
			
			pokemon.status = .asleep(sleepTurns)
		}),
		"Rest": .singleTarget({ pokemon in
			pokemon.currentHP = pokemon.baseStats.hp
			pokemon.status = .asleep(2)
		}),
		"Ice Beam": .singleTarget({
			let diceRoll = Random.shared.d10Roll()
			if diceRoll == 1 && $0.status == .healthy {
				$0.status = .frozen
				print("\($0) was frozen!")
			}
		}),
		"Protect": .singleTarget({ $0.volatileStatus.insert(.protected) }),
		"Rain Dance": .setWeather(.rain),
		"Recover": .singleTarget({ pokemon in
			pokemon.currentHP += Int((0.5 * Double(pokemon.baseStats.hp)))
		}),
		"Sparkling Aria": .singleTarget({ if $0.status == .burned { $0.status = .healthy } }),
		"Solar Beam": .multiTurnMove(
			condition: { return $0.weather == .harshSunlight || $0.weather == .extremelyHarshSunlight },
			addAttack: { attack, pokemon in
				pokemon.volatileStatus.insert(.preparingTo(attack.withoutBonusEffect()))
				return "\(pokemon.nickname) took in sunlight!"
			}
		),
		"Sunny Day": .setWeather(.harshSunlight),
		"Swords Dance": .singleTarget({ $0.statStages.atk += 2 }),
		"Thunderbolt": .singleTarget({
			let diceRoll = Random.shared.d6Roll()
			if diceRoll == 1 && $0.status == .healthy {
				$0.status = .paralysed
			}
		}),
		"Thunder Wave": .singleTarget({
			if
				$0.species.typeOne != .electric &&
				$0.species.typeTwo != .electric &&
				$0.status == .healthy
			{
				$0.status = .paralysed
			}
		}),
		"Topsy-Turvy": .singleTarget({
			var pokemonStatStages = $0.statStages
			let newAtk = -pokemonStatStages.atk
			let newDef = -pokemonStatStages.def
			let newSpAtk = -pokemonStatStages.spAtk
			let newSpDef = -pokemonStatStages.spDef
			let newSpd = -pokemonStatStages.spd
			$0.statStages = (atk: newAtk, def: newDef, spAtk: newSpAtk, spDef: newSpDef, spd: newSpd)
		})
	]
	
	private static let targets: [String: Attack.EffectTarget] = [
		"Confuse Ray": .defender,
		"Giga Drain": .attacker,
		"Hyper Beam": .attacker,
		"Protect": .attacker,
		"Recover": .attacker,
		"Hypnosis": .defender,
		"Rest": .attacker,
		"Solar Beam": .attacker,
		"Swords Dance": .attacker,
		"Topsy-Turvy": .defender,
		"Thunder Wave": .defender
	]
	
	static let activationMessage: [String: (Pokemon) -> String] = [
		"Protean": {
			return "\($0.nickname) became \(String(describing: $0.species.typeOne).capitalized) type"
		}
	]
	
	static func getAbilities() -> [String: Ability] {
		var abilities = [String: Ability]()
		var database: Connection?
		
		guard let dbPath = dbPath else {
			print("Failed at dbPath = dbPath in getAbilities")
			return [:]
		}
		
		database = try? Connection(dbPath, readonly: true)
		
		guard let db = database else {
			print("Failed at db = database in getAbilities")
			return [:]
		}
		
		let abilityTable = Table("abilities")
		let abilityNames = Table("ability_names")
		let abilityFlavorText = Table("ability_flavor_text")
		
		let id = Expression<Int>("id")
		let abilityID = Expression<Int>("ability_id")
		let abilityName = Expression<String>("name")
		let languageID = Expression<Int>("language_id")
		let localLanguageID = Expression<Int>("local_language_id")
		let flavorText = Expression<String>("flavor_text")
		
		let query = abilityTable.select(abilityNames[abilityName], abilityFlavorText[flavorText])
			.join(abilityNames, on: abilityTable[id] == abilityNames[abilityID])
			.join(abilityFlavorText, on: abilityTable[id] == abilityFlavorText[abilityID])
			.filter(abilityNames[localLanguageID] == 9 && abilityFlavorText[languageID] == 9)
		
		do {
			for row in try db.prepare(query) {
				let abilityName = row[abilityName]
				
				let ability = Ability(name: abilityName, description: row[flavorText], activationMessage: activationMessage[abilityName])
				abilities[abilityName] = ability
			}
		} catch let error {
			print("getAbilities() error: \(error)")
		}
		
		return abilities
	}
	
	static func getPokemon(abilities: [String: Ability], attacks: [String: Attack]) -> [PokemonSpecies] {
		var pokemon = [PokemonSpecies]()
		var database: Connection?
		
		guard let dbPath = dbPath else { return [] }
		
		database = try? Connection(dbPath, readonly: true)
		
		guard let db = database else { return [] }
		
		do {
			let pokemonTable = Table("pokemon_species")
			let pokeID = Expression<Int>("id")
			let identifier = Expression<String>("identifier")
			let name = Expression<String>("name")
			
			let statTable = Table("pokemon_stats")
			let pokemonID = Expression<Int>("pokemon_id")
			let s1 = statTable.alias("s1")
			
			let stat = Expression<Int>("stat_id")
			let baseStat = Expression<Int>("base_stat")
			let statHP = Expression<Int>("stat_HP")
			
			let pokemonSpeciesNames = Table("pokemon_species_names")
			let speciesID = Expression<Int>("pokemon_species_id")
			
			let languageID = Expression<Int>("local_language_id")
			
			let query = """
			select p.id, p.identifier, ps.name,
			(select tn.name from type_names as tn
			join pokemon_types as pt on pt.type_id = tn.type_id
			where pt.pokemon_id = p.id and tn.local_language_id = 9 and pt.slot = 1) as typeOne,
			(select tn.name from type_names as tn
			join pokemon_types as pt on pt.type_id = tn.type_id
			where pt.pokemon_id = p.id and tn.local_language_id = 9 and pt.slot = 2) as typeTwo,
			(select pokestat.base_stat from pokemon_stats as pokestat
			where pokestat.pokemon_id = p.id and pokestat.stat_id = 1) as stat_hp,
			(select pokestat.base_stat from pokemon_stats as pokestat
			where pokestat.pokemon_id = p.id and pokestat.stat_id = 2) as stat_atk,
			(select pokestat.base_stat from pokemon_stats as pokestat
			where pokestat.pokemon_id = p.id and pokestat.stat_id = 3) as stat_def,
			(select pokestat.base_stat from pokemon_stats as pokestat
			where pokestat.pokemon_id = p.id and pokestat.stat_id = 4) as stat_spAtk,
			(select pokestat.base_stat from pokemon_stats as pokestat
			where pokestat.pokemon_id = p.id and pokestat.stat_id = 5) as stat_spDef,
			(select pokestat.base_stat from pokemon_stats as pokestat
			where pokestat.pokemon_id = p.id and pokestat.stat_id = 6) as stat_spd,
			(select an.name from ability_names as an join pokemon_abilities as pa on an.ability_id = pa.ability_id where pa.pokemon_id = p.id and an.local_language_id = 9 and pa.slot=1) as ability_one,
			(select an.name from ability_names as an join pokemon_abilities as pa on an.ability_id = pa.ability_id where pa.pokemon_id = p.id and an.local_language_id = 9 and pa.slot=2) as ability_two,
			(select an.name from ability_names as an join pokemon_abilities as pa on an.ability_id = pa.ability_id where pa.pokemon_id = p.id and an.local_language_id = 9 and pa.slot=3) as ability_hidden
			from pokemon as p
			join pokemon_species_names as ps on p.id=ps.pokemon_species_id
			where ps.local_language_id = 9;
			"""
			
			for row in try db.prepare(query) {
				
				guard let pokedexNumber = row[0] as? Int64 else {
					print("Failed to get ID")
					break
				}
				
				guard let identifier = row[1] as? String else {
					print("Failed to get identifier")
					break
				}
				guard let pokemonName = row[2] as? String else {
					print("Failed to get Name")
					break
				}
				guard let typeOneString = row[3] as? String else {
					print("Failed to do Type One")
					break
				}
				let typeTwoString = row[4] as? String
				guard let hp = row[5] as? Int64 else { break }
				guard let atk = row[6] as? Int64 else { break }
				guard let def = row[7] as? Int64 else { break }
				guard let spAtk = row[8] as? Int64 else { break }
				guard let spDef = row[9] as? Int64 else { break }
				guard let spd = row[10] as? Int64 else { break }
				guard let ability1Name = row[11] as? String else { break }
				let ability2Name = row[12] as? String
				let hiddenAbilityName = row[13] as? String
				
				let ability1 = abilities[ability1Name] ?? Ability(name: "Dummy", description: "Dummy")
				var ability2: Ability? {
					guard let value = ability2Name else { return nil }
					return abilities[value]
				}
				
				var hiddenAbility: Ability? {
					guard let value = hiddenAbilityName else { return nil }
					return abilities[value]
				}
				
				guard let typeOne = Type(rawValue: typeOneString) else { break }
				var typeTwo: Type? {
					guard let value = typeTwoString else { return nil }
					
					return Type(rawValue: value)
				}
				
				let eggGroupTable = Table("pokemon_egg_groups")
				let speciesID = Expression<Int>("species_id")
				let eggGroupID = Expression<Int>("egg_group_id")
				let eggGroupQuery = eggGroupTable.select(speciesID, eggGroupID).filter(speciesID == Int(pokedexNumber))
				let eggGroups = Array(try db.prepare(eggGroupQuery))
				
				let eggGroupOne = EggGroup(using: eggGroups[0][eggGroupID])
				var eggGroupTwo: EggGroup? {
					if eggGroups.indices.contains(1) {
						return EggGroup(using: eggGroups[1][eggGroupID])
					} else {
						return nil
					}
				}
				
				let moveset = Pokedex.getAttacksForPokemon(Int(pokedexNumber), database: db, attacks: attacks).sorted { first, second in
					switch (first.moveLearnMethod, second.moveLearnMethod) {
					case let (.levelUp(left), .levelUp(right)):
						return left < right
					case (.levelUp(_), .machine):
						return true
					case (.machine, .egg):
						return true
					case (.egg, .lightBallEgg):
						return true
					case (.lightBallEgg, .moveTutor):
						return true
					case (.egg, .moveTutor):
						return true
					case (.moveTutor, .formChange):
						return true
					case (.machine, .moveTutor):
						return true
					default:
						return false
					}
				}
				
				let pokemonSpecies = PokemonSpecies(dexNum: Int(pokedexNumber), identifier: identifier, name: pokemonName, typeOne: typeOne, typeTwo: typeTwo, stats: Stats(hp: Int(hp), atk: Int(atk), def: Int(def), spAtk: Int(spAtk), spDef: Int(spDef), spd: Int(spd)), abilityOne: ability1, abilityTwo: ability2, hiddenAbility: hiddenAbility, eggGroupOne: eggGroupOne, eggGroupTwo: eggGroupTwo, moveset: moveset)
				
				pokemon.append(pokemonSpecies)
			}
		} catch let error {
			print("getPokemon() error: \(error)")
		}
		return pokemon
	}
	
	static func getAttacks() -> [String: Attack] {
		var attacks = [String: Attack]()
		var database: Connection?
		
		guard let dbPath = dbPath else {
			print("Failed at dbPath = dbPath in getAbilities")
			return [:]
		}
		
		database = try? Connection(dbPath, readonly: true)
		
		guard let db = database else {
			print("Failed at db = database in getAbilities")
			return [:]
		}
		
		let moveTable = Table("moves")
		let moveNames = Table("move_names")
		
		let id = Expression<Int>("id")
		let moveID = Expression<Int>("move_id")
		let moveName = Expression<String>("name")
		let power = Expression<Int?>("power")
		let pp = Expression<Int>("pp")
		let type = Expression<Int>("type_id")
		let category = Expression<Int>("damage_class_id")
		let accuracy = Expression<Int?>("accuracy")
		let priority = Expression<Int>("priority")
		let localLanguageID = Expression<Int>("local_language_id")
		
		let query = moveTable.select(moveNames[moveName], moveTable[power], moveTable[type], moveTable[category], moveTable[pp], moveTable[accuracy], moveTable[priority])
			.join(moveNames, on: moveTable[id] == moveNames[moveID])
			.filter(moveNames[localLanguageID] == 9 && moveTable[type] != 10002)
		
		do {
			for row in try db.prepare(query) {
				let moveName = row[moveName]
				
				let type = Type(using: row[type])
				let category = Attack.DamageCategory(with: row[category])
				
				let breaksProtect = Pokedex.protectBreakingMoves.contains(moveName)
				let effectTarget = Pokedex.targets[moveName]
				let attack = Attack(name: moveName, power: row[power] ?? 0, basePP: row[pp], maxPP: row[pp], accuracy: row[accuracy], priority: row[priority], type: type, breaksProtect: breaksProtect, category: category, effectTarget: effectTarget, bonusEffect: Pokedex.attackBonuses[moveName])
				attacks[moveName] = attack
			}
		} catch let error {
			print("getAbilities() error: \(error)")
		}
		
		return attacks
	}
	
	static func getAttacksForPokemon(_ pokemon: Int, database: Connection, attacks: [String: Attack]) -> [MovesetItem] {
		var moveset: [MovesetItem] = []
		
		let pokemonMoves = Table("pokemon_moves")
		let pokemonNames = Table("pokemon_species_names")
		let moveNames = Table("move_names")
		
		let id = Expression<Int>("pokemon_id")
		let speciesID = Expression<Int>("pokemon_species_id")
		let moveID = Expression<Int>("move_id")
		let name = Expression<String>("name")
		let learnMethod = Expression<Int>("pokemon_move_method_id")
		let learnLevel = Expression<Int>("level")
		let version = Expression<Int>("version_group_id")
		let language = Expression<Int>("local_language_id")
		
		let query = pokemonMoves.select(pokemonNames[name], moveNames[name], pokemonMoves[learnMethod], pokemonMoves[learnLevel])
			.join(pokemonNames, on: pokemonMoves[id] == pokemonNames[speciesID])
			.join(moveNames, on: pokemonMoves[moveID] == moveNames[moveID])
			.filter(pokemonMoves[version] == 18 && pokemonNames[language] == 9 && moveNames[language] == 9 && pokemonMoves[id] == pokemon)
		
		do {
			for row in try database.prepare(query) {
				let attackName = row[moveNames[name]]
				let learnMethod = row[learnMethod]
				let level = row[learnLevel]
				
				let attack = attacks[attackName, default: Attack(name: "Dummy", power: 0, basePP: 0, maxPP: 0, priority: 0, type: .typeless, category: .status)]
				let moveLearnMethod: MovesetItem.MoveLearnMethod
				
				switch learnMethod {
				case 1: moveLearnMethod = .levelUp(level)
				case 2: moveLearnMethod = .egg
				case 3: moveLearnMethod = .moveTutor
				case 4: moveLearnMethod = .machine
				case 6: moveLearnMethod = .lightBallEgg
				case 10: moveLearnMethod = .formChange
				default: moveLearnMethod = .levelUp(0)
				}
				
				moveset.append(MovesetItem(move: attack, moveLearnMethod: moveLearnMethod))
			}
		} catch let error {
			print(error)
		}
		
		return moveset
	}
}

extension Array where Element == PokemonSpecies {
	public subscript(_ identifier: String) -> PokemonSpecies? {
		return self.filter { $0.identifier == identifier }.first
	}
}
