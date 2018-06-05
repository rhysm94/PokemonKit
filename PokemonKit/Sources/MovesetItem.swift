//
//  MovesetItem.swift
//  PokemonBattleEngineTest
//
//  Created by Rhys Morgan on 31/01/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

public struct MovesetItem: Codable, Equatable {
	public enum MoveLearnMethod: Codable, Equatable {
		case levelUp(Int)
		case technicalMachine(Int)
		case hiddenMachine(Int)
		case egg
		case moveTutor
		
		private enum Base: String, Codable {
			case levelUp, tm, hm, egg, moveTutor
		}
		
		enum CodingKeys: CodingKey {
			case base, levelUp, machine
		}
		
		public func encode(to encoder: Encoder) throws {
			var encoder = encoder.container(keyedBy: CodingKeys.self)
			switch self {
			case .levelUp(let level):
				try encoder.encode(Base.levelUp, forKey: .base)
				try encoder.encode(level, forKey: .levelUp)
			case .technicalMachine(let machine):
				try encoder.encode(Base.tm, forKey: .base)
				try encoder.encode(machine, forKey: .machine)
			case .hiddenMachine(let machine):
				try encoder.encode(Base.hm, forKey: .base)
				try encoder.encode(machine, forKey: .machine)
			case .egg:
				try encoder.encode(Base.egg, forKey: .base)
			case .moveTutor:
				try encoder.encode(Base.moveTutor, forKey: .base)
			}
		}
		
		public init(from decoder: Decoder) throws {
			let decoder = try decoder.container(keyedBy: CodingKeys.self)
			let base = try decoder.decode(Base.self, forKey: .base)
			
			switch base {
			case .levelUp:
				let level = try decoder.decode(Int.self, forKey: .levelUp)
				self = .levelUp(level)
			case .tm:
				let machine = try decoder.decode(Int.self, forKey: .machine)
				self = .technicalMachine(machine)
			case .hm:
				let machine = try decoder.decode(Int.self, forKey: .machine)
				self = .hiddenMachine(machine)
			case .egg:
				self = .egg
			case .moveTutor:
				self = .moveTutor
			}
		}
	}
	
	public let move: Attack
	public let moveLearnMethod: MoveLearnMethod
}
