//
//  Player.swift
//  PokemonBattleEngineTest
//
//  Created by Rhys Morgan on 17/01/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

import Foundation

class Player: Codable {
	var name: String
	var team = [Pokemon]() {
		didSet {
//			print("Setting active Pokémon for \(name) to \(team.first?.species.name ?? "nothing")")
			activePokemon = team.first
		}
	}
	
	var activePokemon: Pokemon!
	var teamMembers: Int {
		return team.count
	}
	
	func add(pokemon: Pokemon) {
		if team.count < 6 {
			team.append(pokemon)
		} else {
			print("Team full!")
		}
	}
	
	init(name: String) {
		self.name = name
		activePokemon = team.first
	}
	
	var allFainted: Bool {
		return team.reduce(false, { $1.status == .fainted })
	}
}

extension Player: Equatable {
	static func ==(lhs: Player, rhs: Player) -> Bool {
		return lhs.name == rhs.name && lhs.team == rhs.team && lhs.activePokemon == rhs.activePokemon
	}
}

enum PlayerErrors: Error {
	case TeamFull
}
