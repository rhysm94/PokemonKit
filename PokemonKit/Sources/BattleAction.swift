//
//  BattleAction.swift
//  PokemonKit
//
//  Created by Rhys Morgan on 11/02/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

public enum BattleAction {
	case switchTo(Pokemon, for: Player)
	case displayText(String)
	case useAttack(attacker: Pokemon, defender: Pokemon, attack: Attack)
	case confusedAttack(Pokemon)
	case statusDamage(Status, Pokemon, Int)
	case abilityActivation(Ability, Pokemon)
	case fainted(Pokemon)
	case notifyOfWinner(Player)
	case weatherUpdate(Weather)
	case terrainUpdate(Terrain)
	case clear
}
