//
//  MovesetItem.swift
//  PokemonKit
//
//  Created by Rhys Morgan on 31/01/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

public struct MovesetItem: Codable, Hashable {
	public enum MoveLearnMethod: Codable, Hashable {
		case levelUp(Int)
		case machine
		case egg
		case moveTutor
		case lightBallEgg
		case formChange

		private enum Base: String, Codable {
			case levelUp, machine, egg, moveTutor, lightBallEgg, formChange
		}

		enum CodingKeys: CodingKey {
			case base, levelUp
		}

		public func encode(to encoder: Encoder) throws {
			var encoder = encoder.container(keyedBy: CodingKeys.self)
			switch self {
			case let .levelUp(level):
				try encoder.encode(Base.levelUp, forKey: .base)
				try encoder.encode(level, forKey: .levelUp)
			case .machine:
				try encoder.encode(Base.machine, forKey: .base)
			case .egg:
				try encoder.encode(Base.egg, forKey: .base)
			case .moveTutor:
				try encoder.encode(Base.moveTutor, forKey: .base)
			case .formChange:
				try encoder.encode(Base.formChange, forKey: .base)
			case .lightBallEgg:
				try encoder.encode(Base.lightBallEgg, forKey: .base)
			}
		}

		public init(from decoder: Decoder) throws {
			let decoder = try decoder.container(keyedBy: CodingKeys.self)
			let base = try decoder.decode(Base.self, forKey: .base)

			switch base {
			case .levelUp:
				let level = try decoder.decode(Int.self, forKey: .levelUp)
				self = .levelUp(level)
			case .machine:
				self = .machine
			case .egg:
				self = .egg
			case .moveTutor:
				self = .moveTutor
			case .formChange:
				self = .formChange
			case .lightBallEgg:
				self = .lightBallEgg
			}
		}
	}

	public let move: Attack
	public let moveLearnMethod: MoveLearnMethod
}
