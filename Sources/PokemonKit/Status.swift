//
//  Status.swift
//  PokemonKit
//
//  Created by Rhys Morgan on 10/01/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

import Foundation

public enum Status: Equatable, Codable {
	case paralysed
	case poisoned
	case badlyPoisoned
	case burned
	case frozen
	case asleep(counter: Int)
	case fainted
	case healthy
}
