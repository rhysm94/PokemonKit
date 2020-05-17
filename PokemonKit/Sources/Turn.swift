//
//  Turn.swift
//  PokemonKit
//
//  Created by Rhys Morgan on 10/01/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

import GameplayKit

public class Turn: NSObject, Codable, GKGameModelUpdate {
	public let player: Player
	let action: Action

	public var value: Int = 0 {
		didSet {
			print("Value for \(self) = \(value)")
		}
	}

	var playerSpeed: Int {
		switch action {
		case .attack:
			if player.activePokemon.status == .paralysed {
				return player.activePokemon.baseStats.spd / 2
			} else {
				return player.activePokemon.baseStats.spd
			}
		default:
			return 0
		}
	}

	var priority: Int {
		switch action {
		case let .attack(attack):
			return attack.priority
		case .switchTo:
			return 6
		case .forceSwitch:
			return 7
		case .run:
			return 7
		case .recharge:
			return 0
		}
	}

	public init(player: Player, action: Action) {
		self.player = player
		self.action = action
	}

	init(turn: Turn) {
		self.player = Player(copying: turn.player)
		self.action = turn.action
	}
}

extension Turn {
	public static func == (lhs: Turn, rhs: Turn) -> Bool {
		lhs.playerSpeed == rhs.playerSpeed &&
			lhs.priority == rhs.priority &&
			lhs.action == rhs.action
	}
}

extension Turn {
	override public var description: String {
		switch action {
		case let .attack(attack):
			return "\(player.name)'s \(player.activePokemon.nickname) is going to use attack \(attack.name)"
		case let .switchTo(pokemon):
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
