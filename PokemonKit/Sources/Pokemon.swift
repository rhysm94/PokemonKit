//
//  Pokemon.swift
//  PokemonBattleEngineTest
//
//  Created by Rhys Morgan on 08/01/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

import Foundation

/// A Pokemon object refers to a specific instance of a Pokémon
///
public class Pokemon: Codable {
	private var _nickname: String?
	public var nickname: String {
		get {
			_nickname ?? species.name
		}
		set {
			_nickname = newValue
		}
	}

	public internal(set) var species: PokemonSpecies
	public let level: Int
	public let effortValues: Stats
	public let individualValues: Stats
	public internal(set) var attacks: [Attack]
	public internal(set) var status: Status
	public internal(set) var volatileStatus: Set<VolatileStatus> = Set()
	public let ability: Ability

	private lazy var _currentHP: Int = {
		baseStats.hp
	}()

	public internal(set) var currentHP: Int {
		get {
			_currentHP
		}
		set {
			if newValue < 0 {
				_currentHP = 0
			} else if newValue > baseStats.hp {
				_currentHP = baseStats.hp
			} else {
				_currentHP = newValue
			}

			if _currentHP == 0 {
				status = .fainted
			}
		}
	}

	public var baseStats: Stats {
		let baseStats = species.baseStats
		let hp = Pokemon.calculateHPStat(base: baseStats.hp, EV: effortValues.hp, IV: individualValues.hp, level: level)
		let atk = Pokemon.calculateOtherStats(
			base: baseStats.atk,
			EV: effortValues.atk,
			IV: individualValues.atk,
			level: level,
			natureModifier: nature.atkModifier
		)
		let def = Pokemon.calculateOtherStats(
			base: baseStats.def,
			EV: effortValues.def,
			IV: individualValues.def,
			level: level,
			natureModifier: nature.defModifier
		)
		let spAtk = Pokemon.calculateOtherStats(
			base: baseStats.spAtk,
			EV: effortValues.spAtk,
			IV: individualValues.spAtk,
			level: level,
			natureModifier: nature.spAtkModifier
		)
		let spDef = Pokemon.calculateOtherStats(
			base: baseStats.spDef,
			EV: effortValues.spDef,
			IV: individualValues.spDef,
			level: level,
			natureModifier: nature.spDefModifier
		)
		let spd = Pokemon.calculateOtherStats(
			base: baseStats.spd,
			EV: effortValues.spd,
			IV: individualValues.spd,
			level: level,
			natureModifier: nature.spdModifier
		)
		return Stats(hp: hp, atk: atk, def: def, spAtk: spAtk, spDef: spDef, spd: spd)
	}

	public var modifiedStats: Stats {
		let atkMod = Stats.statModifiers[statStages.atk] ?? 1
		let defMod = Stats.statModifiers[statStages.def] ?? 1
		let spAtkMod = Stats.statModifiers[statStages.spAtk] ?? 1
		let spDefMod = Stats.statModifiers[statStages.spDef] ?? 1
		let spdMod = Stats.statModifiers[statStages.spd] ?? 1

		let baseStats = species.baseStats
		let hp = Pokemon.calculateHPStat(base: baseStats.hp, EV: effortValues.hp, IV: individualValues.hp, level: level)
		let atk = Pokemon.calculateOtherStats(
			base: baseStats.atk,
			EV: effortValues.atk,
			IV: individualValues.atk,
			level: level,
			natureModifier: nature.atkModifier,
			statModifier: atkMod
		)
		let def = Pokemon.calculateOtherStats(
			base: baseStats.def,
			EV: effortValues.def,
			IV: individualValues.def,
			level: level,
			natureModifier: nature.defModifier,
			statModifier: defMod
		)
		let spAtk = Pokemon.calculateOtherStats(
			base: baseStats.spAtk,
			EV: effortValues.spAtk,
			IV: individualValues.spAtk,
			level: level,
			natureModifier: nature.spAtkModifier,
			statModifier: spAtkMod
		)
		let spDef = Pokemon.calculateOtherStats(
			base: baseStats.spDef,
			EV: effortValues.spDef,
			IV: individualValues.spDef,
			level: level,
			natureModifier: nature.spDefModifier,
			statModifier: spDefMod
		)
		let spd = Pokemon.calculateOtherStats(
			base: baseStats.spd,
			EV: effortValues.spd,
			IV: individualValues.spd,
			level: level,
			natureModifier: nature.spdModifier,
			statModifier: spdMod
		)
		return Stats(hp: hp, atk: atk, def: def, spAtk: spAtk, spDef: spDef, spd: spd)
	}

	private var _statStages = (atk: 0, def: 0, spAtk: 0, spDef: 0, spd: 0)
	public internal(set) var statStages: (atk: Int, def: Int, spAtk: Int, spDef: Int, spd: Int) {
		get {
			_statStages
		}
		set {
			_statStages.atk = newValue.atk
			_statStages.def = newValue.def
			_statStages.spAtk = newValue.spAtk
			_statStages.spDef = newValue.spDef
			_statStages.spd = newValue.spd

			if _statStages.atk > 6 {
				print("\(nickname)'s Attack can't go any higher!")
				_statStages.atk = 6
			} else if _statStages.atk < -6 {
				_statStages.atk = -6
			}

			if _statStages.def > 6 {
				_statStages.def = 6
			} else if _statStages.def < -6 {
				_statStages.def = -6
			}

			if _statStages.spAtk > 6 {
				_statStages.spAtk = 6
			} else if _statStages.spAtk < -6 {
				_statStages.spAtk = -6
			}

			if _statStages.spDef > 6 {
				_statStages.spDef = 6
			} else if _statStages.spDef < -6 {
				_statStages.spDef = -6
			}

			if _statStages.spd > 6 {
				_statStages.spd = 6
			} else if _statStages.spd < -6 {
				_statStages.spd = -6
			}
		}
	}

	public internal(set) var nature: Nature

	public init(
		species: PokemonSpecies,
		level: Int = 50,
		ability: Ability = Ability(name: "Some ability", description: "Some Description"),
		nature: Nature,
		effortValues: Stats,
		individualValues: Stats,
		attacks: [Attack]
	) {
		self.species = species
		self.level = level
		self.effortValues = effortValues
		self.individualValues = individualValues
		self.nature = nature
		self.ability = ability
		self.attacks = attacks
		self.status = .healthy
	}

	static func calculateHPStat(base: Int, EV: Int, IV: Int, level: Int) -> Int {
		let top = (2 * base + IV + Int(floor(Double(EV) / 4))) * level
		let result = Int(floor(Double(top) / 100)) + level + 10
		return result
	}

	static func calculateOtherStats(base: Int, EV: Int, IV: Int, level: Int, natureModifier: Double, statModifier: Double = 1) -> Int {
		let top = (2 * base + IV + Int(floor(Double(EV) / 4))) * level
		let brackets = floor(Double(top) / 100) + 5
		return Int(floor(brackets * natureModifier * statModifier))
	}

	func damage(_ damage: Int) {
		currentHP -= damage
	}

	enum CodingKeys: CodingKey {
		case nickname
		case species
		case level
		case effortValues
		case individualValues
		case statStages
		case attacks
		case nature
		case ability
		case status
	}

	enum StatStagesCodingKeys: CodingKey {
		case atk, def, spAtk, spDef, spd
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(_nickname, forKey: .nickname)
		try container.encode(species, forKey: .species)
		try container.encode(level, forKey: .level)
		try container.encode(effortValues, forKey: .effortValues)
		try container.encode(individualValues, forKey: .individualValues)
		try container.encode(attacks, forKey: .attacks)
		try container.encode(nature, forKey: .nature)
		try container.encode(ability, forKey: .ability)
		try container.encode(status, forKey: .status)

		var statStagesContainer = encoder.container(keyedBy: StatStagesCodingKeys.self)
		let statStagesStruct = StatStages(atk: _statStages.atk, def: _statStages.def, spAtk: _statStages.spAtk, spDef: _statStages.spDef, spd: _statStages.spd)
		try statStagesContainer.encode(statStagesStruct.atk, forKey: .atk)
		try statStagesContainer.encode(statStagesStruct.def, forKey: .def)
		try statStagesContainer.encode(statStagesStruct.spAtk, forKey: .spAtk)
		try statStagesContainer.encode(statStagesStruct.spDef, forKey: .spDef)
		try statStagesContainer.encode(statStagesStruct.spd, forKey: .spd)
	}

	private struct StatStages: Codable {
		var atk: Int
		var def: Int
		var spAtk: Int
		var spDef: Int
		var spd: Int
	}

	public required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self._nickname = try container.decode(String?.self, forKey: .nickname)
		self.species = try container.decode(PokemonSpecies.self, forKey: .species)
		self.level = try container.decode(Int.self, forKey: .level)
		self.effortValues = try container.decode(Stats.self, forKey: .effortValues)
		self.individualValues = try container.decode(Stats.self, forKey: .individualValues)
		self.attacks = try container.decode([Attack].self, forKey: .attacks)
		self.nature = try container.decode(Nature.self, forKey: .nature)
		self.ability = try container.decode(Ability.self, forKey: .ability)
		self.status = try container.decode(Status.self, forKey: .status)

		let statStageContainer = try decoder.container(keyedBy: StatStagesCodingKeys.self)
		let atkStage = try statStageContainer.decode(Int.self, forKey: .atk)
		let defStage = try statStageContainer.decode(Int.self, forKey: .def)
		let spAtkStage = try statStageContainer.decode(Int.self, forKey: .spAtk)
		let spDefStage = try statStageContainer.decode(Int.self, forKey: .spDef)
		let spdStage = try statStageContainer.decode(Int.self, forKey: .spd)
		self._statStages = (atk: atkStage, def: defStage, spAtk: spAtkStage, spDef: spDefStage, spd: spdStage)
	}

	/// Copy constructor for a Pokemon
	///
	/// - parameter pokemon: The Pokemon object you want a copy of
	public init(pokemon: Pokemon) {
		self.species = pokemon.species
		self._nickname = pokemon._nickname
		self._statStages = pokemon._statStages
		self.ability = pokemon.ability
		self.attacks = pokemon.attacks
		self.level = pokemon.level
		self.effortValues = pokemon.effortValues
		self.individualValues = pokemon.individualValues
		self.status = pokemon.status
		self.volatileStatus = pokemon.volatileStatus
		self.nature = pokemon.nature
		self._currentHP = pokemon._currentHP
	}
}

extension Pokemon: CustomStringConvertible {
	public var description: String {
		nickname
	}
}

extension Pokemon: Equatable {
	public static func == (lhs: Pokemon, rhs: Pokemon) -> Bool {
		lhs.species == rhs.species &&
			lhs._nickname == rhs._nickname &&
			lhs._statStages == rhs._statStages &&
			lhs.ability == rhs.ability &&
			lhs.attacks == rhs.attacks &&
			lhs.level == rhs.level &&
			lhs.effortValues == rhs.effortValues &&
			lhs.individualValues == rhs.individualValues &&
			lhs.status == rhs.status &&
			lhs.volatileStatus == rhs.volatileStatus &&
			lhs.nature == rhs.nature &&
			lhs._currentHP == rhs._currentHP
	}
}
