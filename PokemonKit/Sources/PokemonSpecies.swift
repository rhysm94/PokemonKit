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
    private let _evolvesFrom: String?
	public let eggGroupOne: EggGroup
	public let eggGroupTwo: EggGroup?
	public let moveset: [MovesetItem]
	
	public struct FormAttributes: Codable, Hashable {
		public let formName: String?
		public let formOrder: Int
		public let isMega: Bool
		public let isBattleOnly: Bool
		public let isDefault: Bool
		
		public init(formName: String?, formOrder: Int, isMega: Bool, isBattleOnly: Bool, isDefault: Bool) {
			self.formName = formName
			self.formOrder = formOrder
			self.isMega = isMega
			self.isBattleOnly = isBattleOnly
			self.isDefault = isDefault
		}
		
		public init(formName: String?) {
			self.init(formName: formName, formOrder: 1, isMega: false, isBattleOnly: false, isDefault: true)
		}
	}

	public let formAttributes: FormAttributes
	
    public var evolvesFrom: PokemonSpecies? {
        guard let preEvo = _evolvesFrom else { return nil }
        return Pokedex.default.pokemon[preEvo]
    }
    
    public var evolutions: [PokemonEvolution]? {
		return Pokedex.default.getEvolutionFor(pokemon: self)
    }
	
	public var family: [PokemonSpecies] {
		var preEvo = evolvesFrom
		
		while preEvo?.evolvesFrom != nil {
			preEvo = preEvo?.evolvesFrom
		}
		
		func createFamily(for pokemon: PokemonSpecies, family: [PokemonSpecies] = []) -> [PokemonSpecies] {
			var family = family
			
			family.append(pokemon)
			for evolution in (pokemon.evolutions?.compactMap { $0.evolvedPokemon } ?? [])
				where !family.contains(evolution) {
				family = createFamily(for: evolution, family: family)
			}
			
			return family
		}
		
		return Array(createFamily(for: preEvo ?? self))
	}
	
	public var forms: [PokemonSpecies] {
		return Pokedex.default.getAlternateFormsFor(pokemon: self)
	}
	
	public init(dexNum: Int, identifier: String, name: String, typeOne: Type, typeTwo: Type? = nil, stats: Stats, abilityOne: Ability, abilityTwo: Ability? = nil, hiddenAbility: Ability? = nil, eggGroupOne: EggGroup, eggGroupTwo: EggGroup? = nil, evolvesFrom: String? = nil, formAttributes: FormAttributes, moveset: [MovesetItem] = []) {
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
        self._evolvesFrom = evolvesFrom
		self.formAttributes = formAttributes
		self.generation = Generation(with: dexNum)
		self.moveset = moveset
	}
	
	public init(dexNum: Int, identifier: String, name: String, type: Type, stats: Stats, abilityOne: Ability, abilityTwo: Ability? = nil, hiddenAbility: Ability? = nil, eggGroupOne: EggGroup, eggGroupTwo: EggGroup? = nil, evolvesFrom: String? = nil, formAttributes: FormAttributes, moveset: [MovesetItem] = []) {
		self.init(dexNum: dexNum, identifier: identifier, name: name, typeOne: type, typeTwo: nil, stats: stats, abilityOne: abilityOne, abilityTwo: abilityTwo, hiddenAbility: hiddenAbility, eggGroupOne: eggGroupOne, eggGroupTwo: eggGroupTwo, evolvesFrom: evolvesFrom, formAttributes: formAttributes, moveset: moveset)
	}
}

extension PokemonSpecies: CustomStringConvertible {
	public var description: String {
		return "Pokémon Species: \(name)"
	}
}
