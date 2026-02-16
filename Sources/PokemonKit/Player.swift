//
//  Player.swift
//  PokemonKit
//
//  Created by Rhys Morgan on 17/01/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

import Foundation
import GameplayKit

public class Player: NSObject, Codable, GKGameModelPlayer {
	public let name: String
	public internal(set) var team = [Pokemon]()

	public lazy var playerId: Int = GKRandomSource.sharedRandom().nextInt()

	public var activePokemon: Pokemon {
		team[0]
	}

	public var teamMembers: Int {
		team.count
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
	}

	public init(copying: Player) {
		self.name = copying.name
		self.team = copying.team.map { Pokemon(pokemon: $0) }

		super.init()

		self.playerId = copying.playerId
	}

	public var allFainted: Bool {
		team.allSatisfy { $0.status == .fainted }
	}

	public func switchPokemon(pokemon: Pokemon) {
		if let firstIndex = team.firstIndex(of: pokemon) {
			(team[0], team[firstIndex]) = (team[firstIndex], team[0])
		}
	}
}

extension Player {
	public static func == (lhs: Player, rhs: Player) -> Bool {
		lhs.name == rhs.name &&
			lhs.playerId == rhs.playerId &&
			lhs.team == rhs.team
	}

	public static func == (lhs: Player, rhs: GKGameModelPlayer) -> Bool {
		guard let right = rhs as? Player else { return false }
		return lhs == right
	}

	public static func == (lhs: GKGameModelPlayer, rhs: Player) -> Bool {
		guard let left = lhs as? Player else { return false }
		return left == rhs
	}
}
