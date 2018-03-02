//
//  Status.swift
//  PokemonBattleEngineTest
//
//  Created by Rhys Morgan on 10/01/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

import Foundation

public enum Status: Codable, Equatable {
	enum CodingKeys: CodingKey {
		case base, counter
	}
	
	private enum Base: String, Codable {
		case paralysed
		case poisoned
		case badlyPoisoned
		case burned
		case frozen
		case asleep
		case fainted
		case healthy
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let returnValue = try container.decode(Base.self, forKey: .base)
		
		switch returnValue {
		case .paralysed:
			self = .paralysed
		case .poisoned:
			self = .poisoned
		case .badlyPoisoned:
			self = .badlyPoisoned
		case .burned:
			self = .burned
		case .frozen:
			self = .frozen
		case .asleep:
			let counter = try container.decode(Int.self, forKey: .counter)
			self = .asleep(counter)
		case .fainted:
			self = .fainted
		case .healthy:
			self = .healthy
		}
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		switch self {
		case .paralysed:
			try container.encode(Base.paralysed, forKey: .base)
		case .poisoned:
			try container.encode(Base.poisoned, forKey: .base)
		case .badlyPoisoned:
			try container.encode(Base.badlyPoisoned, forKey: .base)
		case .burned:
			try container.encode(Base.burned, forKey: .base)
		case .frozen:
			try container.encode(Base.frozen, forKey: .base)
		case .asleep(let counter):
			try container.encode(Base.asleep, forKey: .base)
			try container.encode(counter, forKey: .counter)
		case .fainted:
			try container.encode(Base.fainted, forKey: .base)
		case .healthy:
			try container.encode(Base.healthy, forKey: .base)
		}
	}
	
    case paralysed
    case poisoned
    case badlyPoisoned
    case burned
    case frozen
    case asleep(Int)
    case fainted
    case healthy
    
    public static func ==(lhs: Status, rhs: Status) -> Bool {
        switch (lhs, rhs) {
        case (.paralysed, .paralysed):
            return true
        case (.poisoned, .poisoned):
            return true
        case (.badlyPoisoned, .badlyPoisoned):
            return true
        case (.burned, .burned):
            return true
        case (.frozen, .frozen):
            return true
        case let (.asleep(leftSleep), .asleep(rightSleep)):
            return leftSleep == rightSleep
        case (.fainted, .fainted):
            return true
        case (.healthy, .healthy):
            return true
        default:
            return false
        }
    }
}

public enum VolatileStatus: Codable, CustomStringConvertible, Hashable {
	case confused(Int)
	case protected
	case flinch
	case mustRecharge
	
	public static func ==(lhs: VolatileStatus, rhs: VolatileStatus) -> Bool {
		switch (lhs, rhs) {
		case let (.confused(leftConfused), .confused(rightConfused)):
			switch (leftConfused, rightConfused) {
			case (0, 0):
				return true
			case (0, _):
				return false
			case (_, 0):
				return false
			case (_, _):
				return true
			}
		case (.protected, .protected):
			return true
		case (.flinch, .flinch):
			return true
		case (.mustRecharge, .mustRecharge):
			return true
		default:
			return false
		}
	}
	
	public var description: String {
		switch self {
		case .confused(let turns):
			return "confused for \(turns) more turns"
		case .protected:
			return "protected"
		case .flinch:
			return "flinch"
		case .mustRecharge:
			return "must recharge"
		}
	}
	
	public var hashValue: Int {
		return self.description.hashValue
	}
	
	public func turn() -> VolatileStatus {
		switch self {
		case .confused(let c):
			return .confused(c - 1)
		default:
			return self
		}
	}
	
	// MARK:- Codable implementation
	enum CodingKeys: CodingKey {
		case base, counter
	}
	
	private enum Base: String, Codable {
		case confused, protected, flinch, mustRecharge
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let returnValue = try container.decode(Base.self, forKey: .base)
		
		switch returnValue {
		case .confused:
			let counter = try container.decode(Int.self, forKey: .counter)
			self = .confused(counter)
		case .protected:
			self = .protected
		case .flinch:
			self = .flinch
		case .mustRecharge:
			self = .mustRecharge
		}
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		switch self {
		case .confused(let counter):
			try container.encode(Base.confused, forKey: .base)
			try container.encode(counter, forKey: .counter)
		case .protected:
			try container.encode(Base.protected, forKey: .base)
		case .flinch:
			try container.encode(Base.flinch, forKey: .base)
		case .mustRecharge:
			try container.encode(Base.mustRecharge, forKey: .base)
		}
	}
}
