//
//  Observer.swift
//  PokemonBattleEngineTest
//
//  Created by Rhys Morgan on 20/01/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

public protocol BattleEngineViewer: class {
	func queue(action: BattleAction)
	func disableButtons()
}
