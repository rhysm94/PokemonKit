//
//  Pokedex.swift
//  PokemonBattleEngineTest
//
//  Created by Rhys Morgan on 23/01/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

import SQLite

public class Pokedex {
	/// Shared resource for accessing the Pokedex
	///
	/// Contains all Pokémon, Abilities, and Attacks
	public static let `default`: Pokedex = {
		Pokedex()
	}()

	private static let dbPath = Bundle(for: Pokedex.self).path(forResource: "pokedex", ofType: "sqlite")!

	private static var databaseConnection: Connection = {
		var database = try! Connection(dbPath, readonly: true)
		return database
	}()

	public var pokemon: [PokemonSpecies] = []

	/// Array containing all Pokémon from the Kanto Pokédex, with National Dex numbers 1 - 151
	///
	/// i.e. Bulbasaur - Mew
	public var kantoPokemon: [PokemonSpecies] {
		pokemon.filter { $0.generation == .kanto }
	}

	/// Array containing all Pokémon from the Johto region, with National Dex numbers 152 - 251
	///
	/// i.e. Chikorita - Celebi
	public var johtoPokemon: [PokemonSpecies] {
		pokemon.filter { $0.generation == .johto }
	}

	/// Array containing all Pokémon from the Hoenn region, with National Dex numbers 252 - 386
	///
	/// i.e. Treecko - Deoxys
	public var hoennPokemon: [PokemonSpecies] {
		pokemon.filter { $0.generation == .hoenn }
	}

	/// Array containing all Pokémon from the Sinnoh region, with National Dex numbers 387 - 493
	///
	/// i.e. Turtwig - Arceus
	public var sinnohPokemon: [PokemonSpecies] {
		pokemon.filter { $0.generation == .sinnoh }
	}

	/// Array containing all Pokémon from the Unova region, with National Dex numbers 494 - 649
	///
	/// i.e. Victini - Genesect
	public var unovaPokemon: [PokemonSpecies] {
		pokemon.filter { $0.generation == .unova }
	}

	/// Array containing all Pokémon from the Kalos region, with National Dex numbers 650 - 721
	///
	/// i.e. Chespin - Volcanion
	public var kalosPokemon: [PokemonSpecies] {
		pokemon.filter { $0.generation == .kalos }
	}

	/// Array containing all Pokémon from the Alola region, with National Dex numbers 722 - 807
	///
	/// i.e. Rowlet - Zeraora
	public var alolaPokemon: [PokemonSpecies] {
		pokemon.filter { $0.generation == .alola }
	}

	/// Dictionary containing all Pokémon abilities, indexed by Ability name
	///
	/// Access an Ability like so:
	/// ```
	/// let protean = Pokedex.default.abilities["Protean"]
	/// ```
	public var abilities: [String: Ability] = [:]

	/// Dictionary containing all Pokémon attacks, indexed by Attack name
	///
	/// Access an Attack like so:
	/// ```
	/// let hyperBeam = Pokedex.default.attacks["Hyper Beam"]
	/// ```
	public var attacks: [String: Attack] = [:]

	init() {
		let queue = OperationQueue()

		let attackGetter = BlockOperation {
			self.attacks = Pokedex.getAttacks()
		}

		let abilityGetter = BlockOperation {
			self.abilities = Pokedex.getAbilities()
		}

		let pokemonGetter = BlockOperation {
			self.pokemon = Pokedex.getPokemon(abilities: self.abilities, attacks: self.attacks)
		}

		pokemonGetter.addDependency(attackGetter)
		pokemonGetter.addDependency(abilityGetter)

		queue.addOperations([pokemonGetter, abilityGetter, attackGetter], waitUntilFinished: true)
	}

	private static let protectBreakingMoves = ["Feint", "Hyperspace Fury", "Hyperspace Hole", "Phantom Force", "Shadow Force"]

	static let attackBonuses: [String: Attack.BonusEffect] = [
		"Bullet Seed": .multiHitMove(minHits: 2, maxHits: 5),
		"Calm Mind": .singleTarget {
			$0.statStages.spAtk += 1
			$0.statStages.spDef += 1
		},
		"Confuse Ray": .singleTarget {
			for case .confused in $0.volatileStatus { return }
			let diceRoll = Random.shared.confusion()
			$0.volatileStatus.insert(.confused(diceRoll))
			print("\($0.nickname) became confused for \(diceRoll) turns!")
		},
		"Dark Pulse": .singleTarget {
			let diceRoll = Random.shared.d5Roll()
			if diceRoll == 1 {
				$0.volatileStatus.insert(.flinch)
			}
		},
		"Double Slap": .multiHitMove(minHits: 2, maxHits: 2),
		"Extrasensory": .singleTarget {
			let diceRoll = Random.shared.d10Roll()
			if diceRoll == 1 {
				$0.volatileStatus.insert(.flinch)
				print("\($0.nickname) flinched!")
			}
		},
		"Giga Drain": .singleTargetUsingDamage { pokemon, damage in
			let restoreHP = Int(Double(damage) * 0.5)
			pokemon.currentHP += restoreHP

			print("\(pokemon.nickname) will restore by \(restoreHP) capped at their max. HP")
		},
		"Giga Impact": .singleTarget { $0.volatileStatus.insert(.mustRecharge) },
		"Growl": .singleTarget { $0.statStages.atk -= 1 },
		"Hyper Beam": .singleTarget { $0.volatileStatus.insert(.mustRecharge) },
		"Hypnosis": .singleTarget { pokemon in
			guard pokemon.status == .healthy else { return }

			let sleepTurns = Random.shared.between(minimum: 1, maximum: 3)

			pokemon.status = .asleep(sleepTurns)
		},
		"Rest": .singleTarget { pokemon in
			pokemon.currentHP = pokemon.baseStats.hp
			pokemon.status = .asleep(2)
		},
		"Ice Beam": .singleTarget {
			let diceRoll = Random.shared.d10Roll()
			if diceRoll == 1 && $0.status == .healthy {
				$0.status = .frozen
				print("\($0) was frozen!")
			}
		},
		"Protect": .singleTarget { $0.volatileStatus.insert(.protected) },
		"Rain Dance": .setWeather(.rain),
		"Recover": .singleTarget { pokemon in
			pokemon.currentHP += Int(0.5 * Double(pokemon.baseStats.hp))
		},
		"Sparkling Aria": .singleTarget { if $0.status == .burned { $0.status = .healthy } },
		"Solar Beam": .multiTurnMove(
			condition: { $0.weather == .harshSunlight || $0.weather == .extremelyHarshSunlight },
			addAttack: { attack, pokemon in
				pokemon.volatileStatus.insert(.preparingTo(attack.withoutBonusEffect()))
				return "\(pokemon.nickname) took in sunlight!"
			}
		),
		"Sunny Day": .setWeather(.harshSunlight),
		"Swords Dance": .singleTarget { $0.statStages.atk += 2 },
		"Thunderbolt": .singleTarget {
			let diceRoll = Random.shared.d6Roll()
			if diceRoll == 1 && $0.status == .healthy {
				$0.status = .paralysed
			}
		},
		"Thunder Wave": .singleTarget {
			if
				$0.species.typeOne != .electric &&
				$0.species.typeTwo != .electric &&
				$0.status == .healthy {
				$0.status = .paralysed
			}
		},
		"Topsy-Turvy": .singleTarget {
			var pokemonStatStages = $0.statStages
			let newAtk = -pokemonStatStages.atk
			let newDef = -pokemonStatStages.def
			let newSpAtk = -pokemonStatStages.spAtk
			let newSpDef = -pokemonStatStages.spDef
			let newSpd = -pokemonStatStages.spd
			$0.statStages = (atk: newAtk, def: newDef, spAtk: newSpAtk, spDef: newSpDef, spd: newSpd)
		},
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
		"Thunder Wave": .defender,
	]

	static let activationMessage: [String: (Pokemon) -> String] = [
		"Protean": {
			"\($0.nickname) became \(String(describing: $0.species.typeOne).capitalized) type"
		},
	]

	static func getAbilities() -> [String: Ability] {
		var abilities = [String: Ability]()
		let db = databaseConnection

		let abilityTable = Table("abilities")
		let abilityNames = Table("ability_names")
		let abilityFlavorText = Table("ability_flavor_text")

		let id = Expression<Int>("id")
		let abilityID = Expression<Int>("ability_id")
		let abilityName = Expression<String>("name")
		let languageID = Expression<Int>("language_id")
		let localLanguageID = Expression<Int>("local_language_id")
		let flavorText = Expression<String>("flavor_text")
		let mainSeries = Expression<Int>("is_main_series")
		let versionGroupID = Expression<Int>("version_group_id")

		// Filter is split into two discrete expressions to satisfy type-checker
		// Seemingly, Swift 5.1 introduced a regression which meant this couldn't be evaluated in time
		let filterPartOne = Expression<Bool>(
			abilityNames[localLanguageID] == 9 &&
				abilityFlavorText[languageID] == 9 &&
				abilityTable[mainSeries] == 1
		)

		let filterPartTwo = Expression<Bool>(
			abilityFlavorText[versionGroupID] == 17
		)

		let query = abilityTable.select(abilityNames[abilityName], abilityFlavorText[flavorText])
			.join(abilityNames, on: abilityTable[id] == abilityNames[abilityID])
			.join(abilityFlavorText, on: abilityTable[id] == abilityFlavorText[abilityID])
			.filter(filterPartOne && filterPartTwo)

		do {
			for row in try db.prepare(query) {
				let abilityName = row[abilityName]

				let ability = Ability(name: abilityName, description: row[flavorText], activationMessage: activationMessage[abilityName])
				abilities[abilityName] = ability
			}
		} catch {
			print("getAbilities() error: \(error)")
		}

		return abilities
	}

	static func getPokemon(abilities: [String: Ability], attacks: [String: Attack]) -> [PokemonSpecies] {
		var pokemon = [PokemonSpecies]()
		let db = databaseConnection

		do {
			let query = """
			select
			p.id,
			p.identifier,
			ps.name,
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
			(select an.name from ability_names as an join pokemon_abilities as pa on an.ability_id = pa.ability_id where pa.pokemon_id = p.id and an.local_language_id = 9 and pa.slot=3) as ability_hidden,
			(select pAlias.identifier from pokemon_species as pAlias join pokemon_species as p2 on p2.evolves_from_species_id = pAlias.id where p2.id = p.id) as evolves_from,
			(select pfn.form_name from pokemon_form_names as pfn
			join pokemon_forms as pf on p.id = pf.pokemon_id
			where pf.id = pfn.pokemon_form_id
			and pfn.local_language_id = 9
			and pf.is_default = 1) as form_name
			from pokemon as p
			join pokemon_species_names as ps on p.id = ps.pokemon_species_id
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
				let evolvesFrom = row[14] as? String
				let formName = row[15] as? String

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

				let moveset = Pokedex.getAttacksForPokemon(Int(pokedexNumber), attacks: attacks).sorted { first, second in
					switch (first.moveLearnMethod, second.moveLearnMethod) {
					case let (.levelUp(left), .levelUp(right)):
						return left < right
					case (.levelUp, .machine):
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

				let stats = Stats(hp: Int(hp), atk: Int(atk), def: Int(def), spAtk: Int(spAtk), spDef: Int(spDef), spd: Int(spd))
				let formAttributes = PokemonSpecies.FormAttributes(formName: formName)

				let pokemonSpecies = PokemonSpecies(dexNum: Int(pokedexNumber), identifier: identifier, name: pokemonName, typeOne: typeOne, typeTwo: typeTwo, stats: stats, abilityOne: ability1, abilityTwo: ability2, hiddenAbility: hiddenAbility, eggGroupOne: eggGroupOne, eggGroupTwo: eggGroupTwo, evolvesFrom: evolvesFrom, formAttributes: formAttributes, moveset: moveset)

				pokemon.append(pokemonSpecies)
			}
		} catch {
			print("getPokemon() error: \(error)")
		}
		return pokemon
	}

	public func getEvolutionFor(pokemon: PokemonSpecies) -> [PokemonEvolution]? {
		let db = Pokedex.databaseConnection

		var evolutions: Set<PokemonEvolution> = []

		let evolution = Table("pokemon_evolution")
		let species = Table("pokemon_species")
		let id = Expression<Int>("id")
		let identifier = Expression<String>("identifier")
		let evolvedID = Expression<Int>("evolved_species_id")
		let evolutionTriggerID = Expression<Int>("evolution_trigger_id")
		let minimumLevel = Expression<Int?>("minimum_level")
		let genderID = Expression<Int?>("gender_id")
		let locationID = Expression<Int?>("location_id")
		let triggerItemID = Expression<Int?>("trigger_item_id")
		let heldItemID = Expression<Int?>("held_item_id")
		let timeOfDay = Expression<String?>("time_of_day")
		let knownMoveID = Expression<Int?>("known_move_id")
		let knownMoveTypeID = Expression<Int?>("known_move_type_id")
		let minimumHappiness = Expression<Int?>("minimum_happiness")
		let minimumBeauty = Expression<Int?>("minimum_beauty")
		let minimumAffection = Expression<Int?>("minimum_affection")
		let physicalStats = Expression<Int?>("relative_physical_stats")
		let partySpeciesID = Expression<Int?>("party_species_id")
		let partyTypeID = Expression<Int?>("party_type_id")
		let tradeSpeciesID = Expression<Int?>("trade_species_id")
		let needsOverworldRain = Expression<Bool>("needs_overworld_rain")
		let upsideDown = Expression<Bool>("turn_upside_down")

		let evolvesFrom = Expression<Int>("evolves_from_species_id")

		let query = evolution.select(
			identifier, evolvedID, evolutionTriggerID, minimumLevel, triggerItemID, genderID,
			locationID, heldItemID, timeOfDay, knownMoveID, knownMoveTypeID, minimumHappiness,
			minimumBeauty, minimumAffection, physicalStats, partySpeciesID, partyTypeID,
			tradeSpeciesID, needsOverworldRain, upsideDown
		)
		.join(species, on: species[id] == evolution[evolvedID])
		.filter(species[evolvesFrom] == pokemon.dexNum)

		do {
			for row in try db.prepare(query) {
				var evolutionConditions = Set<PokemonEvolution.EvolutionConditions>()

				guard let evolution = self.pokemon[row[identifier]] else { break }

				if let level = row[minimumLevel] {
					evolutionConditions.insert(.levelUp(.minimumLevel(level)))
				}

				if row[evolutionTriggerID] == 2 {
					evolutionConditions.insert(.trade)
				}

				if row[heldItemID] != nil || row[triggerItemID] != nil {
					evolutionConditions.insert(.item)
				}

				if let gender = row[genderID] {
					let genderToInsert: Gender = {
						switch gender {
						case 1:
							return .female
						case 2:
							return .male
						default:
							return .genderless
						}
					}()

					evolutionConditions.insert(.gender(genderToInsert))
				}

				if let locationID = row[locationID] {
					switch locationID {
					case 8, 375, 650:
						// Moss Rock for Leafeon
						evolutionConditions.insert(.levelUp(.inArea(.mossRock)))
					case 10, 379, 629:
						// Mt Coronet for Magnetic Field Pokémon
						evolutionConditions.insert(.levelUp(.inArea(.magneticField)))
					case 48, 380, 649:
						// Icy Rock for Glaceon
						evolutionConditions.insert(.levelUp(.inArea(.icyRock)))
					default:
						break
					}
				}

				if let timeOfDay = row[timeOfDay] {
					if timeOfDay == "day" {
						evolutionConditions.insert(.timeOfDay(.day))
					} else if timeOfDay == "night" {
						evolutionConditions.insert(.timeOfDay(.night))
					}
				}

				if let moveTypeID = row[knownMoveTypeID] {
					let type = Type(using: moveTypeID)
					evolutionConditions.insert(.levelUp(.knowsAttackType(type)))
				}

				if row[minimumHappiness] != nil {
					evolutionConditions.insert(.levelUp(.happiness))
				}

				if row[minimumBeauty] != nil {
					evolutionConditions.insert(.levelUp(.beauty))
				}

				if row[minimumAffection] != nil {
					evolutionConditions.insert(.affection)
				}

				if row[needsOverworldRain] {
					evolutionConditions.insert(.weather(.rain))
				}

				if row[upsideDown] {
					evolutionConditions.insert(.upsideDown)
				}

				if let stats = row[physicalStats] {
					if stats == -1 {
						evolutionConditions.insert(.physicalStats(.defenseHigher))
					} else if stats == 0 {
						evolutionConditions.insert(.physicalStats(.equal))
					} else if stats == 1 {
						evolutionConditions.insert(.physicalStats(.attackHigher))
					}
				}

				let knownMoveName = Pokedex.getMoveName(moveID: row[knownMoveID])
				if let moveName = knownMoveName,
					let attack = attacks[moveName] {
					evolutionConditions.insert(.levelUp(.knowsAttack(attack)))
				}

				evolutions.insert(PokemonEvolution(evolvedPokemon: evolution, conditions: evolutionConditions))
			}
		} catch {
			print("Error!")
		}

		if !evolutions.isEmpty {
			return Array(evolutions).sorted(by: { $0.evolvedPokemon.dexNum < $1.evolvedPokemon.dexNum })
		} else {
			return nil
		}
	}

	public func getAlternateFormsFor(pokemon: PokemonSpecies) -> [PokemonSpecies] {
		let db = Pokedex.databaseConnection

		var alternateForms: [PokemonSpecies] = []

		let query = """
		select
		p.id,
		p.species_id,
		psn.name,
		(select tn.name from type_names as tn join pokemon_types as pt on pt.type_id = tn.type_id where pt.pokemon_id = p.id and tn.local_language_id = 9 and pt.slot = 1) as typeOne,
		(select tn.name from type_names as tn join pokemon_types as pt on pt.type_id = tn.type_id where pt.pokemon_id = p.id and tn.local_language_id = 9 and pt.slot = 2) as typeTwo,
		(select base_stat from pokemon_stats as stats where stat_id = 1 and stats.pokemon_id = p.id) as hp,
		(select base_stat from pokemon_stats as stats where stat_id = 2 and stats.pokemon_id = p.id) as atk,
		(select base_stat from pokemon_stats as stats where stat_id = 3 and stats.pokemon_id = p.id) as def,
		(select base_stat from pokemon_stats as stats where stat_id = 4 and stats.pokemon_id = p.id) as spAtk,
		(select base_stat from pokemon_stats as stats where stat_id = 5 and stats.pokemon_id = p.id) as spDef,
		(select base_stat from pokemon_stats as stats where stat_id = 6 and stats.pokemon_id = p.id) as spd,
		(select an.name from ability_names as an join pokemon_abilities as pa on an.ability_id = pa.ability_id where pa.pokemon_id = p.id and an.local_language_id = 9 and pa.slot=1) as ability_one,
		(select an.name from ability_names as an join pokemon_abilities as pa on an.ability_id = pa.ability_id where pa.pokemon_id = p.id and an.local_language_id = 9 and pa.slot=2) as ability_two,
		(select an.name from ability_names as an join pokemon_abilities as pa on an.ability_id = pa.ability_id where pa.pokemon_id = p.id and an.local_language_id = 9 and pa.slot=3) as ability_hidden,
		pfn.pokemon_name,
		pfn.form_name,
		pf.identifier,
		pf.form_order,
		pf.is_battle_only,
		pf.is_mega
		from pokemon p
		join pokemon_forms pf on p.id = pf.pokemon_id
		join pokemon_form_names pfn on pf.id = pfn.pokemon_form_id
		join pokemon_species ps on ps.id = p.species_id
		join pokemon_species_names psn on psn.pokemon_species_id = ps.id
		where species_id = \(pokemon.dexNum)
		and pfn.local_language_id = 9 and psn.local_language_id = 9;
		"""

		do {
			for row in try db.prepare(query) {
				guard let dbId = row[0] as? Int64 else { break }
				guard let dexNum = row[1] as? Int64 else { break }
				guard let name = row[2] as? String else { break }
				guard let typeOneString = row[3] as? String else { break }
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
				let pokemonFormName = row[14] as? String
				let formName = row[15] as? String
				guard let identifier = row[16] as? String else { break }
				guard let formOrder = row[17] as? Int64 else { break }
				guard let isBattleOnly = row[18] as? Int64 else { break }
				guard let isMega = row[19] as? Int64 else { break }

				guard let typeOne = Type(rawValue: typeOneString) else { break }
				var typeTwo: Type? {
					guard let value = typeTwoString else { return nil }
					return Type(rawValue: value)
				}

				let ability1 = abilities[ability1Name] ?? Ability(name: "Dummy", description: "Dummy")
				var ability2: Ability? {
					guard let value = ability2Name else { return nil }
					return abilities[value]
				}

				var hiddenAbility: Ability? {
					guard let value = hiddenAbilityName else { return nil }
					return abilities[value]
				}

				let eggGroupTable = Table("pokemon_egg_groups")
				let speciesID = Expression<Int>("species_id")
				let eggGroupID = Expression<Int>("egg_group_id")
				let eggGroupQuery = eggGroupTable.select(speciesID, eggGroupID).filter(speciesID == Int(dexNum))
				let eggGroups = Array(try db.prepare(eggGroupQuery))

				let eggGroupOne = EggGroup(using: eggGroups[0][eggGroupID])
				var eggGroupTwo: EggGroup? {
					guard eggGroups.indices.contains(1) else {
						return nil
					}

					return EggGroup(using: eggGroups[1][eggGroupID])
				}

				let moveset = Pokedex.getAttacksForPokemon(Int(dbId), attacks: attacks).sorted { first, second in
					switch (first.moveLearnMethod, second.moveLearnMethod) {
					case let (.levelUp(left), .levelUp(right)):
						return left < right
					case (.levelUp, .machine):
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

				let stats = Stats(hp: Int(hp), atk: Int(atk), def: Int(def), spAtk: Int(spAtk), spDef: Int(spDef), spd: Int(spd))
				let formAttributes = PokemonSpecies.FormAttributes(formName: formName, formOrder: Int(formOrder), isMega: isMega == 1, isBattleOnly: isBattleOnly == 1, isDefault: false)

				let form = PokemonSpecies(dexNum: Int(dexNum), identifier: identifier, name: name, typeOne: typeOne, typeTwo: typeTwo, stats: stats, abilityOne: ability1, abilityTwo: ability2, hiddenAbility: hiddenAbility, eggGroupOne: eggGroupOne, eggGroupTwo: eggGroupTwo, formAttributes: formAttributes, moveset: moveset)

				if formName != pokemon.formAttributes.formName {
					alternateForms.append(form)
				}
			}
		} catch {
			print(error.localizedDescription)
		}

		return alternateForms
	}

	static func getAttacks() -> [String: Attack] {
		let db = databaseConnection

		var attacks = [String: Attack]()

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
		} catch {
			print("getAbilities() error: \(error)")
		}

		return attacks
	}

	static func getAttacksForPokemon(_ pokemon: Int, attacks: [String: Attack]) -> [MovesetItem] {
		let db = databaseConnection
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
			for row in try db.prepare(query) {
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
		} catch {
			print(error)
		}

		return moveset
	}

	private static func getMoveName(moveID: Int?) -> String? {
		let db = databaseConnection

		let moveNames = Table("move_names")
		let name = Expression<String>("name")
		let moveRowID = Expression<Int>("move_id")
		let languageID = Expression<Int>("local_language_id")

		guard let id = moveID else { return nil }
		let moveQuery = moveNames.select(name).filter(languageID == 9 && moveRowID == id)

		do {
			guard let moveNameRow = try db.pluck(moveQuery) else { return nil }

			let moveName = moveNameRow[name]

			return moveName

		} catch {
			return nil
		}
	}
}

extension Array where Element == PokemonSpecies {
	public subscript(_ identifier: String) -> PokemonSpecies? {
		self.filter { $0.identifier == identifier }.first
	}
}
