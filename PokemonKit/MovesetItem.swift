//
//  MovesetItem.swift
//  PokemonBattleEngineTest
//
//  Created by Rhys Morgan on 31/01/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

struct MovesetItem {
	enum MoveLearnMethod {
		case levelUp(Int)
		case machine
		case egg
		case moveTutor
	}
	
	let move: Attack
	let moveLearnMethod: MoveLearnMethod
}
