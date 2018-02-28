//
//  Turn.swift
//  PokemonBattleEngineTest
//
//  Created by Rhys Morgan on 10/01/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

class Turn: Codable {
	var player: Player
	var playerSpeed: Int {
		switch action {
		case let .attack(attacker,_,_):
			return attacker.baseStats.spd
		default:
			return 0
		}
	}
	var priority: Int {
		switch action {
		case let .attack(_, _, attack):
			return attack.priority
		case .switchTo(_):
			return 6
		case .forceSwitch(_):
			return 7
		case .run:
			return 7
		case .recharge:
			return 0
		}
	}

	var action: Action
	
	init(player: Player, action: Action) {
		self.player = player
		self.action = action
	}
	
	
}

extension Turn: Equatable {
	static func ==(lhs: Turn, rhs: Turn) -> Bool {
		return lhs.playerSpeed == rhs.playerSpeed &&
			lhs.priority == rhs.priority &&
			lhs.action == rhs.action
	}
}

extension Turn: CustomStringConvertible {
	var description: String {
		
		switch action {
		case let .attack(attacker, _, attack):			
			return "\(player.name)'s \(attacker.nickname) is going to use attack \(attack.name)"// against \(defender.nickname)"
		case let .switchTo(pokemon, _):
			return "\(player.name) is going to switch to \(pokemon.nickname)"
		case let .forceSwitch(pokemon):
			return "\(player.name) had to switch in \(pokemon.nickname)"
		case .run:
			return "\(player.name) is going to run"
		case .recharge:
			return "\(player.activePokemon.nickname) must recharge!"
		}
	}
}
