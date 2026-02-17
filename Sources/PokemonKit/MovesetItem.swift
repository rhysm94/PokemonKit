//
//  MovesetItem.swift
//  PokemonKit
//
//  Created by Rhys Morgan on 31/01/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

public struct MovesetItem: Codable, Hashable, Comparable {
	public enum MoveLearnMethod: Codable, Hashable, Comparable {
		case levelUp(level: Int)
		case machine
		case egg
		case moveTutor
		case lightBallEgg
		case formChange
	}

	public let move: Attack
	public let moveLearnMethod: MoveLearnMethod

	public static func < (lhs: Self, rhs: Self) -> Bool {
		if lhs.moveLearnMethod != rhs.moveLearnMethod {
			return lhs.moveLearnMethod < rhs.moveLearnMethod
		}
		return lhs.move.name < rhs.move.name
	}
}
