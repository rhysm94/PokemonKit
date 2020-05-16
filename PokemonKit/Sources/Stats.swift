//
//  Stats.swift
//  PokemonBattleEngineTest
//
//  Created by Rhys Morgan on 08/01/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

public struct Stats: Codable, Hashable {
	public let hp, atk, def, spAtk, spDef, spd: Int
	static let statModifiers = [
		-6: 0.25,
		-5: 0.285,
		-4: 0.33,
		-3: 0.4,
		-2: 0.5,
		-1: 0.66,
		0: 1,
		1: 1.5,
		2: 2,
		3: 2.5,
		4: 3,
		5: 3.5,
		6: 4
	]

	public init(hp: Int, atk: Int, def: Int, spAtk: Int, spDef: Int, spd: Int) {
		self.hp = hp
		self.atk = atk
		self.def = def
		self.spAtk = spAtk
		self.spDef = spDef
		self.spd = spd
	}

	public static let fullIVs = Stats(hp: 31, atk: 31, def: 31, spAtk: 31, spDef: 31, spd: 31)
	public static let empty = Stats(hp: 0, atk: 0, def: 0, spAtk: 0, spDef: 0, spd: 0)
}
