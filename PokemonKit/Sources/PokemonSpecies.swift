//
//  PokemonSpecies.swift
//  PokemonBattleEngineTest
//
//  Created by Rhys Morgan on 07/01/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

import Foundation

public struct PokemonSpecies: Codable, Hashable {
	public let dexNum: Int
	public let generation: Generation
	public let identifier: String
	public let name: String
	public let baseStats: Stats
	internal(set) public var typeOne: Type
	internal(set) public var typeTwo: Type?
	public let abilityOne: Ability
	public let abilityTwo: Ability?
	public let hiddenAbility: Ability?
	public let eggGroupOne: EggGroup
	public let eggGroupTwo: EggGroup?
	public let moveset: [MovesetItem]
	internal(set) public var evolutions: Set<PokemonEvolution>?
	
	public init(dexNum: Int, identifier: String, name: String, typeOne: Type, typeTwo: Type? = nil, stats: Stats, abilityOne: Ability, abilityTwo: Ability? = nil, hiddenAbility: Ability? = nil, eggGroupOne: EggGroup, eggGroupTwo: EggGroup? = nil, moveset: [MovesetItem] = []) {
		self.dexNum = dexNum
		self.identifier = identifier
		self.name = name
		self.typeOne = typeOne
		self.typeTwo = typeTwo
		self.baseStats = stats
		self.abilityOne = abilityOne
		self.abilityTwo = abilityTwo
		self.hiddenAbility = hiddenAbility
		self.eggGroupOne = eggGroupOne
		self.eggGroupTwo = eggGroupTwo
		self.generation = Generation(with: dexNum)
		self.moveset = moveset
	}
	
	public init(dexNum: Int, identifier: String, name: String, type: Type, stats: Stats, abilityOne: Ability, abilityTwo: Ability? = nil, hiddenAbility: Ability? = nil, eggGroupOne: EggGroup, eggGroupTwo: EggGroup? = nil, moveset: [MovesetItem] = []) {
		self.init(dexNum: dexNum, identifier: identifier, name: name, typeOne: type, typeTwo: nil, stats: stats, abilityOne: abilityOne, abilityTwo: abilityTwo, hiddenAbility: hiddenAbility, eggGroupOne: eggGroupOne, eggGroupTwo: eggGroupTwo, moveset: moveset)
	}
}

extension PokemonSpecies: CustomStringConvertible {
	public var description: String {
		return "Pokémon Species: \(name)"
	}
}
