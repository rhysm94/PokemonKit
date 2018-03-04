//
//  PokemonSpecies.swift
//  PokemonBattleEngineTest
//
//  Created by Rhys Morgan on 07/01/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

import Foundation

public struct PokemonSpecies: Codable {
	let dexNum: Int
	let identifier: String
	let name: String
	let baseStats: Stats
	var typeOne: Type
	var typeTwo: Type?
//	let abilityOne: Ability
//	let abilityTwo: Ability?
//	let hiddenAbility: Ability?
	
	public init(dexNum: Int, identifier: String, name: String, typeOne: Type, typeTwo: Type?, stats: Stats) {
		self.dexNum = dexNum
		self.identifier = identifier
		self.name = name
		self.typeOne = typeOne
		self.typeTwo = typeTwo
		self.baseStats = stats
	}
	
	public init(dexNum: Int, identifier: String, name: String, type: Type, stats: Stats) {
		self.init(dexNum: dexNum, identifier: identifier, name: name, typeOne: type, typeTwo: nil, stats: stats)
	}
	
}

extension PokemonSpecies: Equatable {
	public static func ==(lhs: PokemonSpecies, rhs: PokemonSpecies) -> Bool {
		return lhs.dexNum == rhs.dexNum && lhs.name == rhs.name && lhs.typeOne == rhs.typeOne && lhs.typeTwo == rhs.typeTwo && lhs.baseStats == rhs.baseStats
	}
}
