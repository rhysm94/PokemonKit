//
//  VolatileStatus.swift
//  PokemonKit
//
//  Created by Rhys Morgan on 31/03/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

public enum VolatileStatus: Codable, CustomStringConvertible, Hashable {
	case confused(Int)
	case protected
	case flinch
	case mustRecharge
	case preparingTo(Attack)
	
	public static func ==(lhs: VolatileStatus, rhs: VolatileStatus) -> Bool {
		switch (lhs, rhs) {
		case let (.confused(leftConfused), .confused(rightConfused)):
			switch (leftConfused, rightConfused) {
			case (0, 0):
				return true
			case (0, _), (_, 0):
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
		case let (.preparingTo(leftAttack), .preparingTo(rightAttack)):
			return leftAttack == rightAttack
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
		case .preparingTo(let attack):
			return "preparing to use \(attack.name)"
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
		case base, counter, attack
	}
	
	private enum Base: String, Codable {
		case confused, protected, flinch, mustRecharge, preparingTo
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
		case .preparingTo:
			let attack = try container.decode(Attack.self, forKey: .attack)
			self = .preparingTo(attack)
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
		case .preparingTo(let attack):
			try container.encode(Base.preparingTo, forKey: .base)
			try container.encode(attack, forKey: .attack)
		}
	}
}
