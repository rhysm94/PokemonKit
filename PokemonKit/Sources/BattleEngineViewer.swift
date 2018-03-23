//
//  Observer.swift
//  PokemonBattleEngineTest
//
//  Created by Rhys Morgan on 20/01/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

public protocol BattleEngineViewer: class {
	func update(with state: BattleEngine)
	func receive(message: String)
	func clear()
	func notifyFainted(player: Player, pokemon: Pokemon)
	func display(weather: Weather)
	func queue(action: BattleAction)
	func notifyOfWinner(_ winner: Player)
	func disableButtons()
}
