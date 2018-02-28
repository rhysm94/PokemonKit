//
//  Stats.swift
//  PokemonBattleEngineTest
//
//  Created by Rhys Morgan on 08/01/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

struct Stats: Codable {
	let hp, atk, def, spAtk, spDef, spd: Int
	static let statModifiers = [-6: 0.25, -5: 0.285, -4: 0.33, -3: 0.4, -2: 0.5, -1: 0.66, 0: 1, 1: 1.5, 2: 2, 3: 2.5, 4: 3, 5: 3.5, 6: 4]
}

extension Stats: Equatable {
	static func ==(lhs: Stats, rhs: Stats) -> Bool {
		return lhs.hp == rhs.hp && lhs.atk == rhs.atk && lhs.spAtk == rhs.spAtk && lhs.spDef == rhs.spDef && lhs.spd == rhs.spd
	}
}
