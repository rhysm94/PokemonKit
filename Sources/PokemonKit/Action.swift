//
//  Action.swift
//  PokemonKit
//
//  Created by Rhys Morgan on 19/02/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

public enum Action: Codable, Equatable {
	case attack(attack: Attack)
	case switchTo(pokemon: Pokemon)
	case forceSwitch(pokemon: Pokemon)
	case recharge
	case run
}
