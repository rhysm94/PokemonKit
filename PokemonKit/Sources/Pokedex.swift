//
//  Pokedex.swift
//  PokemonBattleEngineTest
//
//  Created by Rhys Morgan on 23/01/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

import GameplayKit

class Pokedex {
	static var `default`: Pokedex!
	
	init() {
		print("init() for Pokedex run")
	}
    
	let attackBonuses: [String: Attack.BonusEffect] = [
		"Bullet Seed": .multiHitMove(minHits: 2, maxHits: 5),
		"Calm Mind": .singleTarget({
			$0.statStages.spAtk += 1
			$0.statStages.spDef += 1
		}),
		"Confuse Ray": .singleTarget({
			let diceRoll = Random.shared.confusion()
			$0.volatileStatus.insert(.confused(diceRoll))
			print("\($0.nickname) became confused for \(diceRoll) turns!")
		}),
		"Dark Pulse": .singleTarget({
			let diceRoll = Random.shared.d5Roll()
			if diceRoll == 1 {
				$0.volatileStatus.insert(.flinch)
			}
		}),
		"Double Slap": .multiHitMove(minHits: 2, maxHits: 2),
		"Extrasensory": .singleTarget({
			let diceRoll = Random.shared.d10Roll()
			if diceRoll == 1 {
				$0.volatileStatus.insert(.flinch)
				print("\($0.nickname) flinched!")
			}
		}),
		
		"Growl": .singleTarget({ $0.statStages.atk -= 1 }),
		"Hyper Beam": .singleTarget({ $0.volatileStatus.insert(.mustRecharge) }),
		"Ice Beam": .singleTarget({
			let diceRoll = Random.shared.d10Roll()
			if diceRoll == 1 && $0.status == .healthy {
				$0.status = .frozen
				print("\($0) was frozen!")
			}
		}),
		"Rain Dance": .setWeather(.rain),
		"Recover": .singleTarget({
			$0.currentHP += Int((0.5 * Double($0.baseStats.hp)))
			if $0.currentHP > $0.baseStats.hp {
				$0.currentHP = $0.baseStats.hp
			}
		}),
		"Sparkling Aria": .singleTarget({ if $0.status == .burned { $0.status = .healthy } }),
		"Sunny Day": .setWeather(.harshSunlight),
		"Swords Dance": .singleTarget({ $0.statStages.atk += 2 }),
		"Thunderbolt": .singleTarget({
			let diceRoll = Random.shared.d6Roll()
			if diceRoll == 1 && $0.status == .healthy {
				$0.status = .paralysed
			}
		})
	]
	
	let abilityDescription: [String: (Pokemon) -> String] = [
		"Protean": {
			return "\($0.nickname) became \(String(describing: $0.species.typeOne).capitalized) type"
		}
	]
}
