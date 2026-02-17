//
//  VolatileStatus.swift
//  PokemonKit
//
//  Created by Rhys Morgan on 31/03/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

public enum VolatileStatus: Codable, Equatable, Hashable {
	case confused(counter: Int)
	case protected
	case flinch
	case mustRecharge
	case preparingTo(attack: Attack)

	public var next: VolatileStatus {
		switch self {
		case let .confused(counter):
			return .confused(counter: counter - 1)
		default:
			return self
		}
	}
}
