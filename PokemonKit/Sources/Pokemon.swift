//
//  Pokemon.swift
//  PokemonBattleEngineTest
//
//  Created by Rhys Morgan on 08/01/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

import Foundation

public class Pokemon: Codable {
	private var _nickname: String?
	public var nickname: String {
		get {
			return _nickname ?? species.name
		}
		set {
			_nickname = newValue
		}
	}
	internal(set) public var species: PokemonSpecies
	public let level: Int
	public let effortValues: Stats
	public let individualValues: Stats
	internal(set) public var attacks: [Attack]
	internal(set) public var status: Status {
		didSet {
			print("\(nickname)'s status became \(status)")
		}
	}
	internal(set) public var volatileStatus: Set<VolatileStatus> = Set()
	public let ability: Ability
//	private(set) var moveset: [MovesetItem] = []
	
	private lazy var _currentHP: Int = {
		return baseStats.hp
	}()
	
	internal(set) public var currentHP: Int {
		get {
			return _currentHP
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
				print("\(nickname) has fainted!")
			}
		}
	}
	
	public var baseStats: Stats {
		let baseStats = species.baseStats
		let hp = Pokemon.calculateHPStat(base: baseStats.hp, EV: effortValues.hp, IV: individualValues.hp, level: level)
		let atk = Int(floor(Pokemon.calculateOtherStats(base: baseStats.atk, EV: effortValues.atk, IV: individualValues.atk, level: level, natureModifier: nature.atkModifier)))
		let def = Int(floor(Pokemon.calculateOtherStats(base: baseStats.def, EV: effortValues.def, IV: individualValues.def, level: level, natureModifier: nature.defModifier)))
		let spAtk = Int(floor(Pokemon.calculateOtherStats(base: baseStats.spAtk, EV: effortValues.spAtk, IV: individualValues.spAtk, level: level, natureModifier: nature.spAtkModifier)))
		let spDef = Int(floor(Pokemon.calculateOtherStats(base: baseStats.spDef, EV: effortValues.spDef, IV: individualValues.spDef, level: level, natureModifier: nature.spDefModifier)))
		let spd = Int(floor(Pokemon.calculateOtherStats(base: baseStats.spd, EV: effortValues.spd, IV: individualValues.spd, level: level, natureModifier: nature.spdModifier)))
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
		let atk = Int(floor(Pokemon.calculateOtherStats(base: baseStats.atk, EV: effortValues.atk, IV: individualValues.atk, level: level, natureModifier: nature.atkModifier) * atkMod))
		let def = Int(floor(Pokemon.calculateOtherStats(base: baseStats.def, EV: effortValues.def, IV: individualValues.def, level: level, natureModifier: nature.defModifier) * defMod))
		let spAtk = Int(floor(Pokemon.calculateOtherStats(base: baseStats.spAtk, EV: effortValues.spAtk, IV: individualValues.spAtk, level: level, natureModifier: nature.spAtkModifier) * spAtkMod))
		let spDef = Int(floor(Pokemon.calculateOtherStats(base: baseStats.spDef, EV: effortValues.spDef, IV: individualValues.spDef, level: level, natureModifier: nature.spDefModifier) * spDefMod))
		let spd = Int(floor(Pokemon.calculateOtherStats(base: baseStats.spd, EV: effortValues.spd, IV: individualValues.spd, level: level, natureModifier: nature.spdModifier) * spdMod))
		return Stats(hp: hp, atk: atk, def: def, spAtk: spAtk, spDef: spDef, spd: spd)
	}
	
	private var _statStages = (atk: 0, def: 0, spAtk: 0, spDef: 0, spd: 0)
	internal(set) public var statStages: (atk: Int, def: Int, spAtk: Int, spDef: Int, spd: Int) {
		get {
			return _statStages
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
	
	internal(set) public var nature: Nature
	
	public init(species: PokemonSpecies, level: Int = 50, ability: Ability = Ability(name: "Some ability", description: "Some Description"), nature: Nature, effortValues: Stats, individualValues: Stats, attacks: [Attack]) {
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
	
	static func calculateOtherStats(base: Int, EV: Int, IV: Int, level: Int, natureModifier: Double) -> Double {
		let top = (2 * base + IV + Int(floor(Double(EV) / 4))) * level
		let brackets = floor(Double(top) / 100) + 5
		return floor(brackets * natureModifier)
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
}

extension Pokemon: CustomStringConvertible {
	public var description: String {
		return "\(nickname) - Lv. \(level): \(currentHP)/\(baseStats.hp)"
	}
}

extension Pokemon: Equatable {
	public static func ==(lhs: Pokemon, rhs: Pokemon) -> Bool {
		return lhs.species == rhs.species &&
			lhs._currentHP == rhs._currentHP &&
			lhs._nickname == rhs._nickname &&
			lhs._statStages == rhs._statStages &&
			lhs.ability == rhs.ability &&
			lhs.baseStats == rhs.baseStats
	}
}


