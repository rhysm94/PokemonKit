//
//  MovesetItem.swift
//  PokemonKit
//
//  Created by Rhys Morgan on 31/01/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

public struct MovesetItem: Codable, Hashable {
	public enum MoveLearnMethod: Codable, Hashable {
		case levelUp(level: Int)
		case machine
		case egg
		case moveTutor
		case lightBallEgg
		case formChange
	}

	public let move: Attack
	public let moveLearnMethod: MoveLearnMethod
}
