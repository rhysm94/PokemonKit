//
//  Observer.swift
//  PokemonBattleEngineTest
//
//  Created by Rhys Morgan on 20/01/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

/// A BattleEngineViewer should implement a queue for storing battle actions.
///
/// It should also implement a `disableButtons()` method, for disabling user interaction
/// during states of play where users should not be able to enter attacks
public protocol BattleEngineViewer: AnyObject {
	func queue(action: BattleAction)
	func disableButtons()
}
