//
//  Gender.swift
//  PokemonKit
//
//  Created by Rhys Morgan on 10/11/2018.
//  Copyright © 2018 Rhys Morgan. All rights reserved.
//

/// Pokémon genders
public enum Gender: Hashable {
	case hasGender(Gender)
	case genderless
	
	public enum Gender: Hashable {
		case male
		case female
	}
}

