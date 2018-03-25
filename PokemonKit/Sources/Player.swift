//
//  Player.swift
//  PokemonBattleEngineTest
//
//  Created by Rhys Morgan on 17/01/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

import Foundation

public class Player: Codable {
	public let name: String
	internal(set) public var team = [Pokemon]()
	
	internal(set) public lazy var activePokemon: Pokemon = {
		return self.team[0]
	}()
	
	public var teamMembers: Int {
		return team.count
	}
	
	public func add(pokemon: Pokemon) {
		if team.count < 6 {
			team.append(pokemon)
		} else {
			print("Team full!")
		}
	}
	
	public init(name: String) {
		self.name = name
//		activePokemon = team.first
	}
	
	public var allFainted: Bool {
		return team.reduce(false, { $1.status == .fainted })
	}
}

extension Player: Equatable {
	public static func ==(lhs: Player, rhs: Player) -> Bool {
		return lhs.name == rhs.name && lhs.team == rhs.team && lhs.activePokemon == rhs.activePokemon
	}
}
