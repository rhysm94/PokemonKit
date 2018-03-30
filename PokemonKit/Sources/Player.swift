//
//  Player.swift
//  PokemonBattleEngineTest
//
//  Created by Rhys Morgan on 17/01/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

import Foundation
import GameplayKit

public class Player: NSObject, Codable {
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
	}
	
	public init(player: Player) {
		self.name = player.name
		self.team = player.team
	}
	
	public var allFainted: Bool {
		return team.reduce(false, { $1.status == .fainted })
	}
}

extension Player: GKGameModelPlayer {
	public var playerId: Int {
		return self.name.hashValue
	}
}

extension Player {
	public static func ==(lhs: Player, rhs: Player) -> Bool {
		return lhs.name == rhs.name &&
			lhs.team == rhs.team &&
			lhs.activePokemon == rhs.activePokemon
	}
	
	public static func !=(lhs: Player, rhs: Player) -> Bool {
		return !(lhs == rhs)
	}
	
	public static func ==(lhs: Player, rhs: GKGameModelPlayer) -> Bool {
		if let right = rhs as? Player {
			return lhs == right
		} else {
			return false
		}
	}
	
	public static func ==(lhs: GKGameModelPlayer, rhs: Player) -> Bool {
		if let left = lhs as? Player {
			return left == rhs
		} else {
			return false
		}
	}
	
	public static func !=(lhs: Player, rhs: GKGameModelPlayer) -> Bool {
		if let right = rhs as? Player {
			return lhs != right
		} else {
			return false
		}
	}

	public static func !=(lhs: GKGameModelPlayer, rhs: Player) -> Bool {
		if let left = lhs as? Player {
			return left != rhs
		} else {
			return false
		}
	}
}


