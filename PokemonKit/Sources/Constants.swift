//
//  Constants.swift
//  PokemonKit
//
//  Created by Rhys Morgan on 21/03/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

import Darwin.C

func gameFreakRound(_ value: Double) -> Double {
	if value > 0.5 {
		return ceil(value)
	} else {
		return floor(value)
	}
}
